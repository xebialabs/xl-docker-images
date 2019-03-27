FROM xebialabs/xl-deploy:8.6.1-amazonlinux

# install Terraform
ENV TERRAFORM_VERSION=0.11.13

USER root

RUN yum install unzip -y && \
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip

# Don't run as root
USER xebialabs

COPY resources/xl-jetpack-logo.svg ${APP_HOME}/conf/xl-deploy-logo.svg