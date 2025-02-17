#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
REPO_PATH=$(dirname "$SCRIPT_PATH")


declare -a SERVICES=(
    "git@github.com:kyle-blue/portfolio-site-frontent.git"
    "git@github.com:kyle-blue/portfolio-site-backend.git"
)
mkdir -p projects
cd projects
for SERVICE in ${SERVICES[@]}; do
    SERVICE_NAME=$(echo "$SERVICE" | sed 's/.*\///' | sed 's/\.git//')
    if [ ! -d $SERVICE_NAME ]; then
        echo "$SERVICE_NAME has not been cloned to /projects. Cloning..."
        git clone "$SERVICE"
        echo "Installing dependencies"
        cd $SERVICE_NAME
        if test -f package.json; then
            yarn
        fi
        cd ..
    fi
done
cd ..

echo Installing calico CNI
kubectl create -f "$REPO_PATH/kubernetes/calico/install.yaml" || 
kubectl replace -f "$REPO_PATH/kubernetes/calico/install.yaml"
kubectl apply -f "$REPO_PATH/kubernetes/calico/config.yaml"

echo Creating namespaces
kubectl create namespace app
kubectl create namespace ingress-nginx

echo Applying all manifests
# Two times to avoid issues involving order of application
kubevar apply -ire dev "$REPO_PATH/kubernetes/namespace"
kubevar apply -ire dev "$REPO_PATH/kubernetes/namespace"

kubectl apply -f ./projects/web-app-backend/kubernetes/psql-migration-job.yaml

echo Finished!