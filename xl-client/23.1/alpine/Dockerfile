FROM alpine:3.16 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client

COPY resources/xl-client-23.1.11-linux-amd64.bin /tmp

RUN mkdir -p ${APP_HOME} && \
    mv /tmp/xl-client-23.1.11-linux-amd64.bin ${APP_HOME}/xl && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod +x ${APP_HOME}/xl

FROM alpine:3.16

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-client" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="23.1.11" \
      release="1" \
      summary="XL Client" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-client"

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client

# Install dependencies
RUN apk update

# Install kubectl
RUN apk add --no-cache curl && \
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.26.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    apk del curl && \
    kubectl version --client --output=yaml

# Install keytool
RUN apk add --no-cache openjdk11-jre-headless ca-certificates

# Install yq
RUN apk add --no-cache yq && \
    yq --version

# Install helm
RUN apk add --no-cache curl tar && \
    curl -LO https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz && \
    tar -xvf helm-v3.7.0-linux-amd64.tar.gz && \
    chmod +x linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin && \
    rm -rf helm-v3.7.0-linux-amd64.tar.gz linux-amd64 && \
    apk del curl tar && \
    helm version

# Install vim
RUN apk add --no-cache vim xclip

# Install oc
RUN apk add --no-cache gcompat curl ca-certificates tar gzip && \
    curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.8.11/openshift-client-linux.tar.gz | tar zx && \
    mv oc /usr/local/bin && \
    apk del curl tar gzip && \
    oc version --client

# Install gcloud dependencies
RUN apk add --no-cache curl python3 py3-crcmod py3-openssl ca-certificates
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz -o /tmp/google-cloud-sdk.tar.gz && \
     tar xzf /tmp/google-cloud-sdk.tar.gz -C /opt && \
     rm /tmp/google-cloud-sdk.tar.gz && \
     apk del curl tar gzip

ENV PATH="/opt/google-cloud-sdk/bin:${PATH}"

# Install gcloud auth plugin
RUN gcloud components install beta && \
    gcloud components install  gke-gcloud-auth-plugin

# git installation needed for krew
RUN apk add --no-cache git

# Install aws dependencies.
RUN apk update && \
    apk add python3 py3-pip

RUN pip3 install awscli
RUN aws --version

# Add user
RUN apk add --no-cache shadow && \
    useradd -d /opt/xebialabs -m -r -u 10001 -g 0 xebialabs

# Copy installed XL Client
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

# Set up gcloud config, aws config and kube config folder
RUN mkdir -p ${APP_ROOT}/.config/gcloud && \
    mkdir -p ${APP_ROOT}/.kube && \
    mkdir -p ${APP_ROOT}/.aws

ENV KUBECONFIG=${APP_ROOT}/.kube/config

# Install Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static ${APP_ROOT}/tini
RUN chmod +x ${APP_ROOT}/tini && \
    chown -R 10001:0 ${APP_ROOT}

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

# Install Krew
RUN cd /tmp \
  && wget -O krew-linux_amd64.tar.gz https://github.com/kubernetes-sigs/krew/releases/download/v0.4.3/krew-linux_amd64.tar.gz \
  && tar zxvf krew-linux_amd64.tar.gz \
  && ./krew-linux_amd64 install krew && \
  rm -rf /tmp/krew*

# Set up Krew
ENV PATH="${APP_ROOT}/.krew/bin:${PATH}"

RUN kubectl krew install oidc-login

ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-client/xl"]