#!/usr/bin/env bash
set -euo pipefail
# Update bootstrap node with latest content. Required for OKD as it starts with FCOS image
# and needs to be updated to the machine-os-content used by masters / nodes.

# Pivot bootstrap to FCOS + OKD machine-os-content
if [ ! -f /opt/openshift/.pivot-done ]; then
  # shellcheck disable=SC1091
  . /usr/local/bin/release-image.sh

  # Run pre-pivot.sh script to update bootstrap node
  MACHINE_CONFIG_OSCONTENT=$(image_for machine-os-content)
  while ! podman pull --quiet "$MACHINE_CONFIG_OSCONTENT"
  do
      echo "Pull failed. Retrying $MACHINE_CONFIG_OSCONTENT..."
  done
  mnt="$(podman image mount "${MACHINE_CONFIG_OSCONTENT}")"
  pushd "${mnt}/bootstrap"
    # shellcheck disable=SC1091
    . ./pre-pivot.sh
  popd
fi
