#/bin/bash

# Prepare hook which runs before helmfile does anything


# Check that an environment has been passed to helmfile command
if [[ "$1" == "default" ]]; then
    echo "ERROR: You must specify an environment using '-e <env>'"
    exit 1
fi


# Validate pre-requisite resources have been first added
MISSING_RESOURCES=""

if ! kubectl get namespace app; then
    kubectl create ns app
fi

if ! kubectl get namespace cert-manager; then
    kubectl create ns cert-manager
fi

if ! kubectl get secret regcred -n app; then
    MISSING_RESOURCES="Secret 'regcred' is missing in 'app' namespace.\n$MISSING_RESOURCES"
fi

if ! kubectl get secret psql-password -n app; then
    MISSING_RESOURCES="Secret 'psql-password' is missing in 'app' namespace.\n$MISSING_RESOURCES"
fi

if ! kubectl get secret ssh-keys -n app; then
    MISSING_RESOURCES="Secret 'ssh-keys' is missing in 'app' namespace.\n$MISSING_RESOURCES"
fi

if ! kubectl get secret email-creds -n app; then
    MISSING_RESOURCES="Secret 'email-creds' is missing in 'app' namespace.\n$MISSING_RESOURCES"
fi


if [ -n "$MISSING_RESOURCES" ]; then
    echo "---"
    echo -e "Before releasing anything with Helm, please add the required preliminary resources:\n$MISSING_RESOURCES\nSee README for more info."
    echo "---"
    exit 1
fi