#!/bin/sh

set -e

echo "WARNING: This will delete your old ~/.kube/config. Continue? (y/n)"
read CONTINUE

if [ "$CONTINUE" = "y" ]; then
    sudo kubeadm reset
    sudo rm -r /etc/cni/net.d 
    mv ~/.kube/config ~/.kube/config_old
    echo "done!"
fi