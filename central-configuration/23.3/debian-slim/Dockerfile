FROM alpine:3.16 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras


    

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/central-configuration-server

# Install central-configuration from zip file
COPY resources/central-configuration-23.3.0-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/central-configuration-23.3.0-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/central-configuration-23.3.0-server ${APP_HOME}

# Add bin/run-in-container.sh
COPY resources/bin/run-in-container.sh ${APP_HOME}/bin/

# script to copy cc from embedded master to standalone cc
COPY resources/bin/migrate-from-embedded-cc-to-standalone.sh ${APP_HOME}/bin/

# Add jmx-exporter for prometheus
COPY resources/jmx-exporter/jmx_prometheus_javaagent.jar ${APP_HOME}/lib/

# Modify bin/run.sh so that java becomes a child process of dumb-init
RUN sed -i 's/^\($JAVACMD\)/exec \1/' ${APP_HOME}/bin/run.sh

# Move and augment conf directory of regular install to default-conf so that when no external config is loaded we can use default
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf
COPY resources/jmx-exporter/jmx-exporter.yaml ${APP_HOME}/default-conf/

# Copy central configuration files
RUN mkdir -p ${APP_HOME}/centralConfiguration
COPY resources/central-conf ${APP_HOME}/central-conf
RUN mv ${APP_HOME}/central-conf/boot.conf.template ${APP_HOME}/default-conf/deployit.conf.template

# Modify conf/xlc-wrapper.conf.common to add node-conf to the classpath and to add container-specific VM options
# ${APP_HOME}/node-conf will have first priority in classpath
COPY resources/modify-wrapper-linux-conf.gawk /tmp
RUN chmod +x /tmp/modify-wrapper-linux-conf.gawk && \
    /tmp/modify-wrapper-linux-conf.gawk ${APP_HOME}/default-conf/xlc-wrapper.conf.common > /tmp/xlc-wrapper.conf.common && \
    mv /tmp/xlc-wrapper.conf.common ${APP_HOME}/default-conf/xlc-wrapper.conf.common && \
    rm /tmp/modify-wrapper-linux-conf.gawk


# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh && \
    chmod a+rwx ${APP_HOME}/centralConfiguration



#FROM openjdk:11-jdk-slim-buster
FROM docker.usw2mgt.dev.digitalai.cloud/dai-java:11-jdk

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/central-configuration" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="23.3.0" \
      release="1" \
      summary="Central configuration" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/central-configuration"


    # Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/central-configuration-server


# Install dependencies
RUN apt-get update -y && \
    apt-get install -y curl jq unzip apt-utils telnet && \
    apt-get install -y fontconfig libfreetype6 && \
    apt-get clean all -q

# Copy installed Central configuration
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=debian



# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=10' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/lib/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini



WORKDIR ${APP_HOME}

ENV XL_CLUSTER_MODE=default \
    XL_DB_URL=jdbc:derby:repository/db;create=true \
    XL_DB_USERNAME=sa \
    XL_DB_PASSWORD=123 \
    XL_DB_MAX_POOL_SIZE=10 \
    XL_REPORT_DB_URL=jdbc:derby:repository/db-report;create=true \
    XL_REPORT_DB_USERNAME=sa \
    XL_REPORT_DB_PASSWORD=123 \
    XL_REPORT_DB_MAX_POOL_SIZE=10 \
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
    ENABLE_SATELLITE=false \
    CENTRAL_CONFIG_ENCRYPT_KEY= \
    USE_CACHE=false


# Don't run as root
RUN useradd -r -M -u 10001 -g 0 xebialabs
USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/centralConfiguration"]

EXPOSE ${APP_PORT}

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.


ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/central-configuration-server/bin/run-in-container.sh"]
