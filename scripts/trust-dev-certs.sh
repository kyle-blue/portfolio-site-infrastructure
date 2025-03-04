#/bin/bash

## LINUX ONLY

cert=$(kubectl get configmap internal-ca-bundle -n app -o json | jq -r '.data["root-certs.pem"]')
sudo echo "$cert" > kblue-dev.crt
sudo rm /etc/ssl/certs/kblue-dev.crt
sudo rm /etc/ssl/certs/kblue-dev.pem
sudo rm /usr/local/share/ca-certificates/kblue-dev.crt
sudo rm /usr/local/share/ca-certificates/kblue-dev.pem
sudo mv kblue-dev.crt /usr/local/share/ca-certificates/kblue-dev.crt 
sudo cp /usr/local/share/ca-certificates/kblue-dev.crt /etc/ssl/certs/kblue-dev.crt
sudo update-ca-certificates --fresh

echo "Done!"
echo "You may need to update trusted certs separately in chrome"
echo "Firstly clear host cache with chrome://net-internals/#dns -> clear host cache"
echo "Go to chrome://settings/certificates -> Authorities and add /etc/ssl/certs/kblue-dev.crt"