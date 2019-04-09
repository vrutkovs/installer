#!/usr/bin/env bash

ARTIFACTS="${1:-/tmp/artifacts}"
mkdir -p "${ARTIFACTS}"

echo "Gathering bootstrap journals ..."
mkdir -p "${ARTIFACTS}/bootstrap/journals"
for service in bootkube openshift kubelet crio
do
    journalctl --boot --no-pager --output=short --unit="${service}" > "${ARTIFACTS}/bootstrap/journals/${service}.log"
done

echo "Gathering bootstrap containers ..."
mkdir -p "${ARTIFACTS}/bootstrap/containers"
for container in $(crictl ps --all --quiet)
do
    container_name=$(crictl ps -a --id ${container} -v | grep -oP "Name: \K(.*)")
    crictl logs "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container_name}.log"
    crictl inspect "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container_name}.inspect"
done
mkdir -p "${ARTIFACTS}/bootstrap/containers"
for container in $(podman ps --all --quiet)
do
    podman logs "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container}.log"
    podman inspect "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container}.inspect"
done

# Collect cluster data
function queue() {
    local TARGET="${ARTIFACTS}/${1}"
    shift
    local LIVE="$(jobs | wc -l)"
    while [[ "${LIVE}" -ge 45 ]]; do
    sleep 1
    LIVE="$(jobs | wc -l)"
    done
    # echo "${@}"
    if [[ -n "${FILTER}" ]]; then
    "${@}" | "${FILTER}" >"${TARGET}" &
    else
    "${@}" >"${TARGET}" &
    fi
}
OC="oc --config=/etc/kubernetes/kubeconfig --insecure-skip-tls-verify --request-timeout=5s"

mkdir -p "${ARTIFACTS}/control-plane" "${ARTIFACTS}/workers" "${ARTIFACTS}/resources/pods" "${ARTIFACTS}/resources/network" "${ARTIFACTS}/resources/nodes"

echo "Gathering cluster resources ..."
queue resources/nodes.list ${OC} get nodes -o jsonpath --template '{range .items[*]}{.metadata.name}{"\n"}{end}'
queue resources/containers ${OC} get pods --all-namespaces --template '{{ range .items }}{{ $name := .metadata.name }}{{ $ns := .metadata.namespace }}{{ range .spec.containers }}-n {{ $ns }} {{ $name }} -c {{ .name }}{{ "\n" }}{{ end }}{{ range .spec.initContainers }}-n {{ $ns }} {{ $name }} -c {{ .name }}{{ "\n" }}{{ end }}{{ end }}'
queue resources/api-pods ${OC} get pods -l openshift.io/component=api --all-namespaces --template '{{ range .items }}-n {{ .metadata.namespace }} {{ .metadata.name }}{{ "\n" }}{{ end }}'

queue resources/apiservices.json ${OC} get apiservices -o json
queue resources/clusteroperators.json ${OC} get clusteroperators -o json
queue resources/clusterversion.json ${OC} get clusterversion -o json
queue resources/configmaps.json ${OC} get configmaps --all-namespaces -o json
queue resources/csr.json ${OC} get csr -o json
queue resources/endpoints.json ${OC} get endpoints --all-namespaces -o json
queue resources/events.json ${OC} get events --all-namespaces -o json
queue resources/kubeapiserver.json ${OC} get kubeapiserver -o json
queue resources/kubecontrollermanager.json ${OC} get kubecontrollermanager -o json
queue resources/machineconfigpools.json ${OC} get machineconfigpools -o json
queue resources/machineconfigs.json ${OC} get machineconfigs -o json
queue resources/namespaces.json ${OC} get namespaces -o json
queue resources/nodes.json ${OC} get nodes -o json
queue resources/openshiftapiserver.json ${OC} get openshiftapiserver -o json
queue resources/pods.json ${OC} get pods --all-namespaces -o json
queue resources/rolebindings.json ${OC} get rolebindings --all-namespaces -o json
queue resources/roles.json ${OC} get roles --all-namespaces -o json
queue resources/secrets.json ${OC} get secrets --all-namespaces -o json
queue resources/services.json ${OC} get services --all-namespaces -o json

FILTER=gzip queue resources/openapi.json.gz ${OC} get --raw /openapi/v2

echo "Gathering node journals ..."
FILTER=gzip queue control-plane/journal.gz ${OC} adm node-logs --role=master --unify=false
FILTER=gzip queue workers/journal.gz ${OC} adm node-logs --role=worker --unify=false

echo "Gathering iptables data ..."
${OC} get --request-timeout=20s -n openshift-sdn -l app=sdn pods --template '{{ range .items }}{{ .metadata.name }}{{ "\n" }}{{ end }}' > "${ARTIFACTS}/resources/sdn-pods"
while IFS= read -r i; do
    queue resources/network/iptables-save-$i ${OC} rsh --timeout=20 -n openshift-sdn -c sdn $i iptables-save -c
done < "${ARTIFACTS}/resources/sdn-pods"

echo "Gathering container logs ..."
while IFS= read -r i; do
    file="$( echo "$i" | cut -d ' ' -f 2,3,5 | tr -s ' ' '_' )"
    FILTER=gzip queue resources/pods/${file}.log.gz ${OC} logs --request-timeout=20s $i
    FILTER=gzip queue resources/pods/${file}_previous.log.gz ${OC} logs --request-timeout=20s -p $i
done < "${ARTIFACTS}/resources/containers"

echo "Gathering kube-apiserver audit.log ..."
${OC} adm node-logs --request-timeout=30s --role=master --path=kube-apiserver/ > "${ARTIFACTS}/resources/kube-audit-logs"
while IFS=$'\n' read -r line; do
    IFS=' ' read -ra log <<< "${line}"
    FILTER=gzip queue resources/nodes/"${log[0]}"-"${log[1]}".gz ${OC} adm node-logs --request-timeout=30s "${log[0]}" --path=kube-apiserver/"${log[1]}"
done < "${ARTIFACTS}/resources/kube-audit-logs"

echo "Gathering openshift-apiserver audit.log ..."
oc --insecure-skip-tls-verify adm node-logs --request-timeout=30s --role=master --path=openshift-apiserver/ > "${ARTIFACTS}/resources/openshift-audit-logs"
while IFS=$'\n' read -r line; do
    IFS=' ' read -ra log <<< "${line}"
    FILTER=gzip queue resources/nodes/"${log[0]}"-"${log[1]}".gz ${OC} adm node-logs --request-timeout=30s "${log[0]}" --path=openshift-apiserver/"${log[1]}"
done < "${ARTIFACTS}/resources/openshift-audit-logs"

echo "Waiting for logs ..."
wait
