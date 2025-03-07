#!/bin/bash

kubectl delete deployment --all -n app 
kubectl delete pod --all -n app
kubectl get pvc -n app -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch pvc {} -n app -p '{"metadata":{"finalizers":null}}'
kubectl delete pvc --all -n app
kubectl get pv -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch pv {} -p '{"metadata":{"finalizers":null}}'
kubectl delete pv --all

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
cd ${SCRIPT_PATH}/../kubernetes

helmfile -e dev sync -l name=app