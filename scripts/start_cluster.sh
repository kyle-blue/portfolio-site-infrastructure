#!/bin/sh

echo "Have you created kubeadm node yet? (y/n)"
read CREATED

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
REPO_PATH=$(dirname "$SCRIPT_PATH")

if [ "$CREATED" != "y" ]; then
    echo "Turning off memory swap as kubeadm cannot handle this..."
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    sudo systemctl mask swap.target
   
    echo "Applying containerd config to make cgroup container driver systemd (must match)"
    mkdir -p /etc/containerd
    sudo cp "$SCRIPT_PATH/containerd-config.toml" "/etc/containerd/config.toml"
    sudo systemctl restart containerd
    sleep 3

    echo "Initialising kubeadm, and applying config to make kubelet cgroup driver systemd (must match)" 
    sudo kubeadm init --config "$REPO_PATH/kubernetes/kubeadm/config.yaml"

    echo "Setting kube config"
    mkdir -p $HOME/.kube
    sudo echo yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
fi
echo "Created Cluster"
