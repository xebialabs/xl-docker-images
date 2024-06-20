FROM alpine:3.16 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras


    

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/deploy-task-engine

# Install deploy-task-engine from zip file
COPY resources/deploy-task-engine-23.3.8.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/deploy-task-engine-23.3.8.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/deploy-task-engine-23.3.8 ${APP_HOME}

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

# Move plugins directory to default-plugins, so that when no external plugins are loaded we can use the default
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins

# Create empty 'repository', 'work', 'export', 'archive' and 'reports' directory
RUN mkdir ${APP_HOME}/repository ${APP_HOME}/export ${APP_HOME}/archive ${APP_HOME}/work ${APP_HOME}/reports

# Set permissions
RUN addgroup -S -g 10001 xebialabs
RUN chgrp -R 10001 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh


#FROM openjdk:11-jdk-slim-buster
FROM docker.usw2mgt.dev.digitalai.cloud/dai-java:11-jdk

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/deploy-task-engine" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="23.3.8" \
      release="1" \
      summary="Deploy Worker" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/deploy-task-engine"


    # Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/deploy-task-engine


# Install dependencies
RUN apt-get update -y && \
    apt-get install -y curl jq unzip apt-utils telnet && \
    apt-get install -y fontconfig libfreetype6 && \
    apt-get clean all -q

# Copy installed Deploy Worker
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=debian


    # install Terraform
ENV TERRAFORM_VERSION=0.11.13

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip


# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=10' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/lib/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini

# Don't run as root
RUN groupadd -r -g 10001 xebialabs
RUN useradd -r -M -u 10001 -g 0 -G xebialabs xebialabs

# Set permissions
RUN chown -R 10001 ${APP_ROOT} && \
    chmod u+x ${APP_HOME}/bin/*.sh &&\
    chmod -R g=u ${APP_ROOT}

WORKDIR ${APP_HOME}

ENV APP_PORT=4516 \
    XL_DB_URL=jdbc:derby:repository/db;create=true \
    XLD_TASK_QUEUE_NAME=xld-tasks-queue \
    XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE=100 \
    XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT=60000 \
    XLD_TASK_QUEUE_DRIVER_CLASS_NAME= \
    XLD_TASK_QUEUE_URL= \
    XLD_TASK_QUEUE_USERNAME= \
    XLD_TASK_QUEUE_PASSWORD= \
    PLUGIN_SOURCE=database \
    USE_EXTERNAL_CENTRAL_CONFIG=false \
    CENTRAL_CONFIG_URL= \
    CENTRAL_CONFIG_ENCRYPT_KEY= \
    LOGBACK_GLOBAL_LOGGING_LEVEL=info \
    LOGBACK_SCAN_ENABLED=true \
    LOGBACK_SCAN_PERIOD=30seconds


USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/ext", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/plugins", "${APP_HOME}/work"]

EXPOSE ${APP_PORT}

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.


ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/deploy-task-engine/bin/run-in-container.sh"]
