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
for container in $(sudo crictl ps --all --quiet)
do
    container_name=$(sudo crictl ps -a --id ${container} -v | grep -oP "Name: \K(.*)")
    sudo crictl logs "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container_name}.log"
    sudo crictl inspect "${container}" >& "${ARTIFACTS}/bootstrap/containers/${container_name}.inspect"
done
mkdir -p "${ARTIFACTS}/bootstrap/pods"
for container in $(sudo podman ps --all --quiet)
do
    sudo podman logs "${container}" >& "${ARTIFACTS}/bootstrap/pods/${container}.log"
    sudo podman inspect "${container}" >& "${ARTIFACTS}/bootstrap/pods/${container}.inspect"
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
    sudo "${@}" | "${FILTER}" >"${TARGET}" &
    else
    sudo "${@}" >"${TARGET}" &
    fi
}
OC="sudo oc --config=/etc/kubernetes/kubeconfig --insecure-skip-tls-verify --request-timeout=5s"

mkdir -p "${ARTIFACTS}/control-plane" "${ARTIFACTS}/masters" "${ARTIFACTS}/resources/pods" "${ARTIFACTS}/resources/network" "${ARTIFACTS}/resources/nodes"

echo "Gathering cluster resources ..."
queue resources/nodes.list ${OC} get nodes -o jsonpath --template '{range .items[*]}{.metadata.name}{"\n"}{end}'
queue resources/masters.list ${OC} get nodes -o jsonpath -l 'node-role.kubernetes.io/master' --template '{range .items[*]}{.metadata.name}{"\n"}{end}'
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

echo "Waiting for logs ..."
wait

echo "Gather remote logs"
for i in $(cat ${ARTIFACTS}/resources/masters.list); do
  scp -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null  /usr/local/bin/installer-masters-gather.sh core@$i:
  mkdir -p ${ARTIFACTS}/masters/${i}
  ssh -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null core@$i -C 'sudo ./installer-masters-gather.sh'
  ssh -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null core@$i -C 'sudo tar cv -C /tmp/artifacts/ .' | tar -x -C ${ARTIFACTS}/masters/${i}/
done
tar cz -C /tmp/artifacts . > ~/log-bundle.tar.gz
