FROM alpine:3.12 as installer

# Install dependencies
RUN apk add --no-cache gawk unzip curl

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-deploy-server

# Install xl-deploy from zip file
COPY resources/xl-deploy-9.7.7-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-deploy-9.7.7-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-deploy-9.7.7-server ${APP_HOME}

# Add bin/run-in-container.sh
COPY resources/bin/run-in-container.sh ${APP_HOME}/bin/

# Add jmx-exporter for prometheus
COPY resources/jmx-exporter/jmx_prometheus_javaagent.jar ${APP_HOME}/lib/

# Add (and run) Database driver download script
COPY resources/bin/db-drivers.sh /tmp
RUN chmod ugo+x /tmp/db-drivers.sh && \
    /bin/sh /tmp/db-drivers.sh

# Modify bin/run.sh so that java becomes a child process of dumb-init
RUN sed -i 's/^\($JAVACMD\)/exec \1/' ${APP_HOME}/bin/run.sh

# Move and augment conf directory of regular install to default-conf so that when no external config is loaded we can use default
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    rm ${APP_HOME}/default-conf/xl-deploy.conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf
COPY resources/jmx-exporter/jmx-exporter.yaml ${APP_HOME}/default-conf/
RUN mv ${APP_HOME}/default-conf/boot.conf.template ${APP_HOME}/default-conf/deployit.conf.template

# Modify conf/xld-wrapper.conf.common to add node-conf to the classpath and to add container-specific VM options
# ${APP_HOME}/node-conf will have first priority in classpath
COPY resources/modify-wrapper-linux-conf.gawk /tmp
RUN chmod +x /tmp/modify-wrapper-linux-conf.gawk && \
    /tmp/modify-wrapper-linux-conf.gawk ${APP_HOME}/default-conf/xld-wrapper.conf.common > /tmp/xld-wrapper.conf.common && \
    mv /tmp/xld-wrapper.conf.common ${APP_HOME}/default-conf/xld-wrapper.conf.common && \
    rm /tmp/modify-wrapper-linux-conf.gawk

# Create node-specific conf directory and add template for node-specific xl-deploy.conf file
# The node-specific xl-deploy.conf file provides HOSTNAME, HOSTNAME_SUFFIX & XL_NODE_NAME to the instance, which are then merged with the 
# ${APP_HOME}/conf/xl-deploy.conf file by the xl-platform
RUN mkdir ${APP_HOME}/node-conf
COPY resources/node-conf ${APP_HOME}/node-conf

# Move plugins directory to default-plugins, so that when no external plugins are loaded we can use the default
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins

# Create empty 'repository', 'work', 'export', 'archive' and 'reports' directory
RUN mkdir ${APP_HOME}/repository ${APP_HOME}/export ${APP_HOME}/archive ${APP_HOME}/work ${APP_HOME}/reports

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh

FROM centos:7

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-deploy" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="9.7.7" \
      release="1" \
      summary="XL Deploy" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-deploy"

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-deploy-server

# Install dependencies
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y java-1.8.0-openjdk-headless curl jq unzip which && \
    yum clean all -q

# Copy installed XL Deploy
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=centos


    # install Terraform
ENV TERRAFORM_VERSION=0.11.13

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip


# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=10' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/jre/lib/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini

WORKDIR ${APP_HOME}

# Don't run as root
RUN useradd -r -M -u 10001 -g 0 xebialabs
USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/export", "${APP_HOME}/ext", "${APP_HOME}/plugins", "${APP_HOME}/repository", "${APP_HOME}/work"]
EXPOSE 4516

ENV XL_CLUSTER_MODE=default \
    XL_DB_URL=jdbc:h2:file:${APP_HOME}/repository/xl-deploy \
    XL_DB_USERNAME=sa \
    XL_DB_PASSWORD=123 \
    XL_METRICS_ENABLED=false \
    XLD_IN_PROCESS=true \
    XLD_TASK_QUEUE_NAME=xld-tasks-queue \
    XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE=100 \
    XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT=60000 \
    XLD_TASK_QUEUE_DRIVER_CLASS_NAME= \
    XLD_TASK_QUEUE_URL= \
    XLD_TASK_QUEUE_USERNAME= \
    XLD_TASK_QUEUE_PASSWORD= \
    HOSTNAME_SUFFIX= \
    XL_LICENSE_KIND=byol \
    GENERATE_XL_CONFIG=true \
    USE_IP_AS_HOSTNAME=false \
    ENABLE_SATELLITE=False


# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.
ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-deploy-server/bin/run-in-container.sh"]