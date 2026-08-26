#!/bin/bash

print_help() {
  cat <<EOF
Usage:
  $0 <target-product> [local-zipfile]

Target product options:
  xl-client
  xl-deploy
  xl-release
  central-configuration
  deploy-task-engine

Description:
  Builds Docker images for a product using applejack.
  By default it downloads artifacts from Nexus.
  If a local zip file is provided, it builds from that zip instead.

Environment variables:
  REQUIRED:
    RELEASE_EXPLICIT       Version to build (for example: 23.3.1)

  REQUIRED for Nexus mode (no local zipfile provided):
    NEXUS_USERNAME         Nexus username
    NEXUS_PASSWORD         Nexus password

  OPTIONAL:
    PYTHON3                Python executable path (default: /usr/bin/python3)
    TARGET_PRODUCT         Alternative to first positional argument
    TARGET_OS              Target OS (default: ubuntu)
    DOCKER_HUB_REPOSITORY  Docker registry/org (default: xebialabsunsupported)
    LOCAL_ZIPFILE          Alternative to second positional argument
    JAVA_VERSION           Java major version to build (21 or 25)
    JAVA_VERSIONS          Comma/space-separated Java majors (21,25)

Examples:
  # Build from Nexus (credentials required)
  RELEASE_EXPLICIT=23.3.1 NEXUS_USERNAME=user NEXUS_PASSWORD=pass \
    $0 xl-deploy

  # Build another supported product
  RELEASE_EXPLICIT=23.3.1 NEXUS_USERNAME=user NEXUS_PASSWORD=pass \
    $0 deploy-task-engine

  # Build from local zip (no Nexus credentials required)
  RELEASE_EXPLICIT=23.3.1 $0 xl-deploy /tmp/xld-23.3.1-server.zip

  # Build from local zip via env var
  RELEASE_EXPLICIT=23.3.1 LOCAL_ZIPFILE=/tmp/xld-23.3.1-server.zip \
    $0 xl-deploy

  # Build Java 21 and Java 25 image variants
  RELEASE_EXPLICIT=27.1.0 JAVA_VERSIONS=21,25 NEXUS_USERNAME=user NEXUS_PASSWORD=pass \
    $0 xl-release
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  print_help
  exit 0
fi

if [[ -z $PYTHON3 ]]; then
  PYTHON3=/usr/bin/python3
fi

LOCAL_ZIPFILE=${2:-${LOCAL_ZIPFILE}}

if [[ -z $LOCAL_ZIPFILE ]]; then
  if [[ -z $NEXUS_USERNAME ]]; then
    echo "NEXUS_USERNAME env var is required"
    exit 1
  fi

  if [[ -z $NEXUS_PASSWORD ]]; then
    echo "NEXUS_PASSWORD env var is required"
    exit 1
  fi
else
  if [[ ! -f "$LOCAL_ZIPFILE" ]]; then
    echo "LOCAL_ZIPFILE does not exist: $LOCAL_ZIPFILE"
    exit 1
  fi
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

if [[ -z $JAVA_VERSIONS && -n $JAVA_VERSION ]]; then
  JAVA_VERSIONS=$JAVA_VERSION
fi

if [[ -n $JAVA_VERSIONS ]]; then
  NORMALIZED_JAVA_VERSIONS=${JAVA_VERSIONS//,/ }
  read -r -a JAVA_VERSION_LIST <<< "$NORMALIZED_JAVA_VERSIONS"

  if [[ ${#JAVA_VERSION_LIST[@]} -eq 0 ]]; then
    echo "JAVA_VERSIONS is set but no values were provided"
    exit 1
  fi

  for JAVA_MAJOR in "${JAVA_VERSION_LIST[@]}"; do
    if [[ "$JAVA_MAJOR" != "21" && "$JAVA_MAJOR" != "25" ]]; then
      echo "Unsupported Java version: $JAVA_MAJOR (supported: 21, 25)"
      exit 1
    fi
  done
else
  JAVA_VERSION_LIST=()
fi

pipenv update --python=$PYTHON3

if [[ -n $LOCAL_ZIPFILE ]]; then
  DOWNLOAD_ARGS=(--download-source=zip --zipfile "$LOCAL_ZIPFILE")
else
  DOWNLOAD_ARGS=(--download-username "$NEXUS_USERNAME" --download-password "$NEXUS_PASSWORD" --download-source=nexus)
fi

build_and_push_variant() {
  local java_major="$1"
  local image_version="$RELEASE_EXPLICIT"
  local suffix_args=()

  if [[ -n "$java_major" ]]; then
    suffix_args=(--suffix "jdk$java_major")
    image_version="$RELEASE_EXPLICIT-jdk$java_major"
  fi

  pipenv run --python=$PYTHON3 ./applejack.py render --xl-version "$RELEASE_EXPLICIT" --product "$TARGET_PRODUCT" --registry "$DOCKER_HUB_REPOSITORY" \
             "${suffix_args[@]}" \
    && pipenv run --python=$PYTHON3 ./applejack.py build --xl-version "$RELEASE_EXPLICIT" --product "$TARGET_PRODUCT" --registry "$DOCKER_HUB_REPOSITORY" --target-os "$TARGET_OS" \
             "${suffix_args[@]}" \
             "${DOWNLOAD_ARGS[@]}" \
    && docker push "$DOCKER_HUB_REPOSITORY/$TARGET_PRODUCT:$image_version-$TARGET_OS" \
    && docker push "$DOCKER_HUB_REPOSITORY/$TARGET_PRODUCT:$image_version-$TARGET_OS-slim"
}

if [[ ${#JAVA_VERSION_LIST[@]} -eq 0 ]]; then
  build_and_push_variant ""
else
  for JAVA_MAJOR in "${JAVA_VERSION_LIST[@]}"; do
    build_and_push_variant "$JAVA_MAJOR" || exit 1
  done
fi
