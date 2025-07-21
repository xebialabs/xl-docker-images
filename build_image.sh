#!/bin/bash

if [[ -z $PYTHON3 ]]; then
  PYTHON3=/usr/bin/python3
fi

if [[ -z $NEXUS_USERNAME ]]; then
  echo "NEXUS_USERNAME env var is required"
  exit 1
fi

if [[ -z $NEXUS_PASSWORD ]]; then
  echo "NEXUS_PASSWORD env var is required"
  exit 1
fi

if [[ -z $RELEASE_EXPLICIT ]]; then
  echo "RELEASE_EXPLICIT env var is required"
  exit 1
fi

TARGET_PRODUCT=${1:-${TARGET_PRODUCT}}
if [[ -z $TARGET_PRODUCT ]]; then
  echo "TARGET_PRODUCT env var is required"
  exit 1
fi

if [[ -z $TARGET_OS ]]; then
  TARGET_OS=ubuntu
fi

if [[ -z $DOCKER_HUB_REPOSITORY ]]; then
  DOCKER_HUB_REPOSITORY=xebialabsunsupported
fi

pipenv update --python=$PYTHON3

pipenv run --python=$PYTHON3 ./applejack.py render --xl-version $RELEASE_EXPLICIT --product $TARGET_PRODUCT --registry $DOCKER_HUB_REPOSITORY \
           && pipenv run --python=$PYTHON3 ./applejack.py build --xl-version $RELEASE_EXPLICIT --product $TARGET_PRODUCT --registry $DOCKER_HUB_REPOSITORY --target-os $TARGET_OS \
           --download-username $NEXUS_USERNAME --download-password $NEXUS_PASSWORD --download-source=nexus \
            && docker push $DOCKER_HUB_REPOSITORY/$TARGET_PRODUCT:$RELEASE_EXPLICIT-$TARGET_OS \
            && docker push $DOCKER_HUB_REPOSITORY/$TARGET_PRODUCT:$RELEASE_EXPLICIT-$TARGET_OS-slim
