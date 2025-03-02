#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
REPO_PATH=$(dirname "$SCRIPT_PATH")


declare -a SERVICES=(
    "git@github.com:kyle-blue/portfolio-site-frontend.git"
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