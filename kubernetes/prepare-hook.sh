#/bin/bash

MISSING_RESOURCES=""

if ! kubectl get namespace app; then
    MISSING_RESOURCES="Namespace 'app' is missing.\n$MISSING_RESOURCES"
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

if [ -n "$MISSING_RESOURCES" ]; then
    echo "---"
    echo -e "Before releasing anything with Helm, please add the required preliminary resources:\n$MISSING_RESOURCES\nSee README for more info."
    echo "---"
    exit 1
fi