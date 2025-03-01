#!/bin/sh

echo "This will REMOVE ALL old versions which WILL break a running cluster.\nDo you want to continue? (y/n)"
read INPUT

if [ "$INPUT" = "y" ]; then
    # Remove old versions
    sudo apt update
    sudo apt-get remove docker docker-engine docker.io containerd runc

    # Install docker
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -m 0755 -p /etc/apt/keyrings

    
    os=$(lsb_release -is | awk '{print tolower($0)}')
    if [ $os = "ubuntu" ]; then
        echo "Ubuntu detected"
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    else
        echo "Ubuntu not detected - using Debian install"
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Install kubectl, kubelet, kubeadm
    sudo apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    # Install Helm
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install -y helm

    # Install Helmfile
    wget https://github.com/helmfile/helmfile/releases/download/v0.171.0/helmfile_0.171.0_linux_amd64.tar.gz
    tar -xvzf helmfile_0.171.0_linux_amd64.tar.gz
    sudo mv ./helmfile /usr/bin/helmfile
    helm plugin install https://github.com/databus23/helm-diff


    # Init docker permissions
    sudo groupadd docker
    sudo usermod -aG docker ${USER}
    echo "Re-logging you into your account to reload permission changes"
    echo "You will now have two stacked shells"
    sudo su $USER
fi