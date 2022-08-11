FROM registry.access.redhat.com/rhel7/rhel-atomic

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/central-configuration" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="10.3.16" \
      release="1" \
      summary="Central configuration" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/central-configuration"

COPY resources/help.md /tmp/

### add licenses to this directory
COPY resources/licenses /licenses

# Install dependencies
RUN INSTALL_PKGS="golang-github-cpuguy83-go-md2man curl hostname shadow-utils which" && \
    microdnf install --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-optional-rpms --nodocs ${INSTALL_PKGS} && \
    microdnf update && \
### help file markdown to man conversion
    go-md2man -in /tmp/help.md -out /help.1 && \
    microdnf clean all

RUN microdnf install --enablerepo=rhel-7-server-rpms --nodocs unzip gawk java-11-openjdk-devel && \
### Set the Java random source
    echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/java/jre/lib/security/java.security && \
    microdnf clean all

### Install JQ
RUN JQ_LOCATION="/usr/bin/jq" && \
    curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -L > $JQ_LOCATION && chmod +x $JQ_LOCATION


    

# Set root folders
ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/central-configuration-server

# Install central-configuration from zip file
COPY resources/central-configuration-10.3.16-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/central-configuration-10.3.16-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/central-configuration-10.3.16-server ${APP_HOME}

# Add bin/run-in-container.sh
COPY resources/bin/run-in-container.sh ${APP_HOME}/bin/

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
RUN mv ${APP_HOME}/central-conf/boot.conf.template ${APP_HOME}/central-conf/deployit.conf.template
RUN mv ${APP_HOME}/central-conf/deployit.conf.template ${APP_HOME}/conf/deployit.conf


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





ENV OS=rhel



# Set ttl for DNS cache
RUN echo $'\n#\n# Set TTL for DNS cache.\nnetworkaddress.cache.ttl=10' >> $(readlink -f `which java` | sed -e 's:/jre/bin/java::' -e 's:/bin/java::')/lib/security/java.security

COPY resources/amd64/tini ${APP_ROOT}
RUN chmod ugo+x ${APP_ROOT}/tini

WORKDIR ${APP_HOME}

# Don't run as root
RUN useradd -r -M -u 10001 -g 0 xebialabs
USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/centralConfiguration"]
EXPOSE 8888



# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in tini running with a PID higher than 1.


ENTRYPOINT ["/opt/xebialabs/tini", "--", "/opt/xebialabs/central-configuration-server/bin/run-in-container.sh"]
