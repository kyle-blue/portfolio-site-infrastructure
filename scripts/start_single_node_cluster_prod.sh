#!/bin/sh


SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
${SCRIPT_PATH}/start_cluster.sh

# Allow them to be deployed to control plane node, since this is a single node setup
# This is usually tainted for security and performance reasons
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
echo "Untainted control plane so you can add pods to control plane node (in single node cluster)"
echo "Finished!"