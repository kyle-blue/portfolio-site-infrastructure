#!/bin/bash

# Avoid attempting to apply when not on prod
HOST_IP=$(dig +short www.kblue.io)
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [ "$HOST_IP" != "$CURRENT_IP" ]; then
    echo "\nIncorrect host. You may be on local machine.\n"
    echo "Exiting"
    exit 1
fi

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
REPO_PATH=$(dirname "$SCRIPT_PATH")

echo Installing calico CNI
kubectl create -f "$REPO_PATH/kubernetes/calico/install.yaml" || 
kubectl replace -f "$REPO_PATH/kubernetes/calico/install.yaml"
kubectl apply -f "$REPO_PATH/kubernetes/calico/config.yaml"

echo Installing cert-manager
kubectl apply -Rf "$REPO_PATH/kubernetes/cert-manager"
kubectl apply -Rf "$REPO_PATH/kubernetes/cert-manager"

echo Creating namespaces
kubectl create namespace app
kubectl create namespace ingress-nginx

echo Applying all manifests
# Two times to avoid issues involving order of application
kubevar apply -ire prod "$REPO_PATH/kubernetes/namespace"
kubevar apply -ire prod "$REPO_PATH/kubernetes/namespace"

echo Finished!