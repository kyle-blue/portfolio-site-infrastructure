FROM bitnami/kubectl:1.32.2

USER root

RUN mkdir -p /var/lib/apt/lists/partial && apt-get update --yes && apt install --yes curl gpg tar wget

RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    apt-get update --yes && apt-get install apt-transport-https --yes && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update --yes && apt-get install -y helm

RUN wget https://github.com/helmfile/helmfile/releases/download/v0.171.0/helmfile_0.171.0_linux_amd64.tar.gz && \
    tar -xvzf helmfile_0.171.0_linux_amd64.tar.gz && \
    mv ./helmfile /usr/bin/helmfile

RUN helm plugin install https://github.com/databus23/helm-diff

ENTRYPOINT [ "/bin/bash" ]