#!/bin/bash

k3d cluster create portfolio \
    -p "30000-30200:30000-30200@server:*" \
    --k3s-arg "--disable=traefik@server:*" \
    --k3s-arg "--flannel-backend=none@server:*" \
