FROM alpine:3.23 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client
ENV XL_OP_BLUEPRINTS_HOME=${APP_ROOT}/xl-op-blueprints

COPY resources/xl-client-25.3.4-217.1125-linux-amd64.bin /tmp

RUN mkdir -p ${APP_HOME} && \
    mv /tmp/xl-client-25.3.4-217.1125-linux-amd64.bin ${APP_HOME}/xl && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod +x ${APP_HOME}/xl

RUN mkdir -p ${XL_OP_BLUEPRINTS_HOME} && \
    wget -O /tmp/xl-op-blueprints-25.3.4-217.1125.zip https://nexus.xebialabs.com/nexus/content/repositories/digitalai-public/ai/digital/xlclient/blueprints/xl-op-blueprints/25.3.4-217.1125/xl-op-blueprints-25.3.4-217.1125.zip && \
    unzip -o /tmp/xl-op-blueprints-25.3.4-217.1125.zip -d ${XL_OP_BLUEPRINTS_HOME} && \
    chgrp -R 0 ${XL_OP_BLUEPRINTS_HOME} && \
    chmod -R g=u ${XL_OP_BLUEPRINTS_HOME}

FROM alpine:3.23


LABEL name="xebialabs/xl-client" \
      vendor="Digital.ai" \
      maintainer="Digital.ai" \
      version="25.3.4-217.1125" \
      release="1" \
      summary="XL Client" \
      description="Remote control your XebiaLabs DevOps Platform!" \
      url=""

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client

# Install dependencies
RUN apk update

# Install kubectl
RUN apk add --no-cache curl && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    apk del curl && \
    kubectl version --client --output=yaml

# Install keytool
RUN apk add --no-cache openjdk21-jre-headless ca-certificates

# Install yq
RUN apk add --no-cache yq && \
    yq --version

# Install helm
RUN apk add --no-cache curl tar && \
    curl -LO https://get.helm.sh/helm-v4.1.0-linux-amd64.tar.gz && \
    tar -xvf helm-v4.1.0-linux-amd64.tar.gz && \
    chmod +x linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin && \
    rm -rf helm-v4.1.0-linux-amd64.tar.gz linux-amd64 && \
    apk del curl tar && \
    helm version

# Install vim
RUN apk add --no-cache vim xclip



# Add user
RUN apk add --no-cache shadow && \
    useradd -d /opt/xebialabs -m -r -u 10001 -g 0 xebialabs

# Copy installed XL Client
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

# Set up kube config folder
RUN mkdir -p ${APP_ROOT}/.kube

# Install Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static ${APP_ROOT}/tini
RUN chmod +x ${APP_ROOT}/tini && \
    chown -R 10001:0 ${APP_ROOT}

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-client/xl"]