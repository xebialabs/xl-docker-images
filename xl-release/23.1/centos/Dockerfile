FROM alpine:3.16 as installer

# Install dependencies
RUN apk update
RUN apk add --no-cache gawk unzip curl busybox-extras


    

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-release-server

# Install xl-release from zip file
COPY resources/xl-release-23.1.15-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-release-23.1.15-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-release-23.1.15-server ${APP_HOME}

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
    rm ${APP_HOME}/default-conf/xl-release.conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf
COPY resources/jmx-exporter/jmx-exporter.yaml ${APP_HOME}/default-conf/
RUN mv ${APP_HOME}/default-conf/boot.conf.template ${APP_HOME}/default-conf/xl-release-server.conf.template



# Modify conf/xlr-wrapper-linux.conf to add node-conf to the classpath and to add container-specific VM options
# ${APP_HOME}/node-conf will have first priority in classpath
COPY resources/modify-wrapper-linux-conf.gawk /tmp
RUN chmod +x /tmp/modify-wrapper-linux-conf.gawk && \
    /tmp/modify-wrapper-linux-conf.gawk ${APP_HOME}/default-conf/xlr-wrapper-linux.conf > /tmp/xlr-wrapper-linux.conf && \
    mv /tmp/xlr-wrapper-linux.conf ${APP_HOME}/default-conf/xlr-wrapper-linux.conf && \
    rm /tmp/modify-wrapper-linux-conf.gawk

# Create node-specific conf directory and add template for node-specific xl-release.conf file
# The node-specific xl-release.conf file provides HOSTNAME, HOSTNAME_SUFFIX & XL_NODE_NAME to the instance, which are then merged with the
# ${APP_HOME}/conf/xl-release.conf file by the xl-platform
RUN mkdir ${APP_HOME}/node-conf
COPY resources/node-conf ${APP_HOME}/node-conf

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


FROM centos:7

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-release" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="23.1.15" \
      release="1" \
      summary="XL Release" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-release"


    # Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-release-server


# Install dependencies
RUN yum update -y && \
    yum install -y epel-release telnet && \
    yum install -y java-11-openjdk-devel curl jq unzip which && \
    yum clean all -q

# Copy installed XL Release
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=centos



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

ENV XL_CLUSTER_MODE=default \
    XL_DB_URL=jdbc:h2:file:${APP_HOME}/repository/xl-release \
    XL_DB_USERNAME=sa \
    XL_DB_PASSWORD=123 \
    XL_METRICS_ENABLED=false \
    XL_CLUSTER_MODE=default \
    SERVER_URL=http://localhost:\${APP_PORT}/ \
    XL_REPORT_DB_URL=jdbc:h2:file:${APP_HOME}/repository/xl-release-report \
    XL_REPORT_DB_USERNAME=\${xl.database.db-username} \
    XL_REPORT_DB_PASSWORD=\${xl.database.db-password} \
    XL_LICENSE_KIND=byol \
    GENERATE_XL_CONFIG=true \
    USE_IP_AS_HOSTNAME=false \
    ENABLE_EMBEDDED_QUEUE=true \
    XLR_TASK_QUEUE_PASSWORD=mqadmin \
    XLR_TASK_QUEUE_NAME=xlr-tasks-queue \
    XLR_TASK_QUEUE_URL=amqp://localhost:61616 \
    XLR_TASK_QUEUE_USERNAME=mqadmin \
    PLUGIN_SOURCE=database \
    FORCE_REMOVE_MISSING_TYPES=false \
    XLR_HTTP2_ENABLED=false


# Don't run as root
USER 10001

VOLUME ["${APP_ROOT}/bootstrap", "${APP_HOME}/archive", "${APP_HOME}/conf", "${APP_HOME}/hotfix", "${APP_HOME}/ext", "${APP_HOME}/plugins", "${APP_HOME}/repository", "${APP_HOME}/reports"]

EXPOSE ${APP_PORT}

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.


ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-release-server/bin/run-in-container.sh"]
