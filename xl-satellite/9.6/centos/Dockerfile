FROM alpine:3.7 as installer

# Install dependencies
RUN apk add --no-cache gawk unzip curl

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-satellite-server

COPY resources/xl-satellite-server-9.6.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-satellite-server-9.6.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-satellite-server-9.6 ${APP_HOME}

# Add bin/run-in-container.sh
COPY resources/run-in-container.sh ${APP_HOME}/bin/

# Add jmx-exporter for prometheus
COPY resources/jmx_prometheus_javaagent.jar ${APP_HOME}/lib/
COPY resources/jmx-exporter.yaml ${APP_HOME}/conf/

# Modify bin/run.sh so that java becomes a child process of dumb-init
RUN sed -i 's/^\($JAVACMD\)/exec \1/' ${APP_HOME}/bin/run.sh


# Modify conf/xl-satellite-wrapper-linux.conf to add node-conf to the classpath and to add container-specific VM options
# ${APP_HOME}/node-conf will have first priority in classpath
COPY resources/modify-wrapper-linux-conf.gawk /tmp
RUN chmod +x /tmp/modify-wrapper-linux-conf.gawk && \
    /tmp/modify-wrapper-linux-conf.gawk ${APP_HOME}/conf/xl-satellite-wrapper-linux.conf > /tmp/xl-satellite-wrapper-linux.conf && \
    mv /tmp/xl-satellite-wrapper-linux.conf ${APP_HOME}/conf/xl-satellite-wrapper-linux.conf && \
    rm /tmp/modify-wrapper-linux-conf.gawk

COPY resources/satellite.conf.template ${APP_HOME}/conf/satellite.conf.template

# Create empty 'workdir' directory
RUN mkdir ${APP_HOME}/workdir

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh

FROM centos:7

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-satellite" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="9.6" \
      release="1" \
      summary="XL Satellite" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-satellite"

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-satellite-server

# Install dependencies
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y java-1.8.0-openjdk-headless curl jq unzip which && \
    yum clean all -q

# Copy installed XL Satellite
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

ENV OS=centos

# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=10' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/jre/lib/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini

WORKDIR ${APP_HOME}

# Don't run as root
RUN useradd -r -M -u 10001 -g 0 xebialabs
USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/recovery", "${APP_HOME}/workdir"]
EXPOSE 8380 8480

ENV INBOUND_ADDRESS=


# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.
ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/xl-satellite-server/bin/run-in-container.sh"]