FROM alpine:3.13.0 as installer

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client

COPY resources/xl-client-10.2.15-linux-amd64.bin /tmp

RUN mkdir -p ${APP_HOME} && \
    mv /tmp/xl-client-10.2.15-linux-amd64.bin ${APP_HOME}/xl && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/xl


FROM alpine:3.13.0

MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-client" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="10.2.15" \
      release="1" \
      summary="XL Client" \
      description="Enterprise-scale Application Release Automation for any environment" \
      url="https://www.xebialabs.com/xl-client"

ENV USER_UID=10001 APP_ROOT=/opt/xebialabs
ENV APP_HOME=${APP_ROOT}/xl-client

# Copy installed XL Client
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

COPY resources/amd64/tini /opt
RUN chmod ugo+x /opt/tini

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

ENTRYPOINT ["/opt/tini", "/opt/xebialabs/xl-client/xl"]