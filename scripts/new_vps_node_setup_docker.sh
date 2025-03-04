#!/bin/sh

SSH_DIR=$HOME/.ssh
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
docker run -it -v "$(realpath $SCRIPT_PATH):/app" -v "$SSH_DIR:/root/.ssh" -v "/dev/null:/root/.ssh/known_hosts" --env USER=root debian:11.6 /app/new_vps_node_setup_subscript.sh
sudo chown -R $USER:$USER $SSH_DIR