#/bin/bash

## LINUX ONLY

cert=$(kubectl get configmap internal-ca-bundle -n app -o json | jq -r '.data["root-certs.pem"]')
sudo echo "$cert" > kblue-dev.crt
sudo mv kblue-dev.crt /usr/local/share/ca-certificates/kblue-dev.crt 
sudo cp /usr/local/share/ca-certificates/kblue-dev.crt /etc/ssl/certs/kblue-dev.crt
sudo update-ca-certificates
