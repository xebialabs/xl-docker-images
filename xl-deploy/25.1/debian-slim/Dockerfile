FROM alpine:3.16 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras


    

# Set root folders
ENV APP_ROOT=/opt/xebialabs \
    APP_HOME=/opt/xebialabs/xl-deploy-server

# Install xl-deploy from zip file
COPY resources/xl-deploy-25.1.0-beta.4-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-deploy-25.1.0-beta.4-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-deploy-25.1.0-beta.4-server ${APP_HOME} && \
    rm -fr ${APP_HOME}/serviceWrapper/ && \
    rm ${APP_HOME}/bin/.wrapper-env* ${APP_HOME}/bin/install-service* ${APP_HOME}/bin/uninstall-service* && \
    true

# Create directories for external drivers
RUN mkdir -p ${APP_HOME}/driver/jdbc && \
    mkdir -p ${APP_HOME}/driver/mq

# Add bin/run-in-container.sh
COPY resources/bin/run-in-container.sh ${APP_HOME}/bin/run-in-container.sh

# Add jmx-exporter for prometheus
COPY resources/jmx-exporter/jmx_prometheus_javaagent.jar ${APP_HOME}/lib/

# Add (and run) Database driver download script
COPY resources/bin/drivers.sh /tmp/drivers.sh

RUN chmod ugo+x /tmp/drivers.sh && \
    /bin/sh /tmp/drivers.sh && \
    # Modify bin/run.sh so that java becomes a child process of dumb-init
    sed -i 's/^\($JAVACMD\)/exec \1/' ${APP_HOME}/bin/run.sh



# Move and augment conf directory of regular install to default-conf so that when no external config is loaded we can use default
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf
COPY resources/jmx-exporter/jmx-exporter.yaml ${APP_HOME}/default-conf/
RUN mv ${APP_HOME}/default-conf/boot.conf.cloud.template ${APP_HOME}/default-conf/deployit.conf.template

# Copy central configuration files
RUN mkdir -p ${APP_HOME}/centralConfiguration
COPY resources/central-conf ${APP_HOME}/central-conf



# Modify conf/xld-wrapper.conf.common to add node-conf to the classpath and to add container-specific VM options
# ${APP_HOME}/node-conf will have first priority in classpath
COPY resources/modify-wrapper-linux-conf.gawk /tmp
RUN chmod +x /tmp/modify-wrapper-linux-conf.gawk && \
    /tmp/modify-wrapper-linux-conf.gawk ${APP_HOME}/default-conf/xld-wrapper.conf.common > /tmp/xld-wrapper.conf.common && \
    mv /tmp/xld-wrapper.conf.common ${APP_HOME}/default-conf/xld-wrapper.conf.common && \
    rm /tmp/modify-wrapper-linux-conf.gawk && \
    # Create node-specific conf directory and add template for node-specific xl-deploy.conf file
    # The node-specific xl-deploy.conf file provides HOSTNAME, HOSTNAME_SUFFIX & XL_NODE_NAME to the instance, which are then merged with the
    # ${APP_HOME}/conf/xl-deploy.conf file by the xl-platform
    mkdir ${APP_HOME}/node-conf
COPY resources/node-conf ${APP_HOME}/node-conf

# Move plugins directory to default-plugins, so that when no external plugins are loaded we can use the default
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins && \
    # Create empty 'repository', 'work', 'export', 'archive' and 'reports' directory
    mkdir ${APP_HOME}/repository ${APP_HOME}/export ${APP_HOME}/archive ${APP_HOME}/work ${APP_HOME}/reports

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod ugo+x ${APP_HOME}/bin/*.sh


FROM openjdk:17-jdk-slim-buster
# We need to update this with jdk17
# FROM openjdk:11-jdk-slim-buster
# FROM docker.usw2mgt.dev.digitalai.cloud/dai-java:11-jdk
# USER 0



LABEL name="xebialabs/xl-deploy" \
      vendor="Digital.ai" \
      maintainer="Digital.ai" \
      version="25.1.0-beta.4" \
      release="1" \
      summary="XL Deploy" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://digital.ai/products/deploy/"


    # Set root folders
ENV APP_ROOT=/opt/xebialabs \
    APP_HOME=/opt/xebialabs/xl-deploy-server


# Install dependencies
RUN apt-get update -y && \
    apt-get install -y curl jq unzip apt-utils telnet && \
    apt-get install -y fontconfig libfreetype6 && \
    apt-get clean all -q

# Copy installed XL Deploy
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=debian


# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=30' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/conf/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini

# Add xebialabs user but do not switch to it
RUN groupadd -r -g 10001 xebialabs && \
    useradd -r -u 10001 -g 0 -G xebialabs xebialabs

WORKDIR ${APP_HOME}

ENV SERVER_PORT=8180 \
    XL_CLUSTER_MODE=default \
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
    XLD_TASK_QUEUE_IS_QUORUM=false \
    HOSTNAME_SUFFIX= \
    XL_LICENSE_KIND=byol \
    GENERATE_XL_CONFIG=true \
    USE_IP_AS_HOSTNAME=false \
    ENABLE_SATELLITE=false \
    PLUGIN_SOURCE=database \
    USE_EXTERNAL_CENTRAL_CONFIG=false \
    CENTRAL_CONFIG_URL= \
    CENTRAL_CONFIG_ENCRYPT_KEY= \
    USE_CACHE=false \
    LOGBACK_GLOBAL_LOGGING_LEVEL=info \
    LOGBACK_SCAN_ENABLED=true \
    LOGBACK_SCAN_PERIOD=30seconds \
    NETWORK_ADDRESS_CACHE_TTL=30


USER 10001

VOLUME ["${APP_HOME}/centralConfiguration", "${APP_HOME}/conf", "${APP_HOME}/driver/jdbc", "${APP_HOME}/driver/mq", "${APP_HOME}/export", "${APP_HOME}/ext", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/importablePackages", "${APP_HOME}/plugins", "${APP_HOME}/repository", "${APP_HOME}/work"]

EXPOSE ${APP_PORT}

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.


ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-deploy-server/bin/run-in-container.sh"]
