#!/bin/bash

# Embedded central-configuration mount path
SOURCE_DIR="/mnt/centralConfiguration-source-dir"
# Standalone central-configuration mount path
TARGET_DIR="/mnt/centralConfiguration-target-dir"

echo "Start migrating from embedded central-configuration to standalone"
if [[ -d $SOURCE_DIR ]]
then
  echo "Copying embedded central-configuration from directory '$SOURCE_DIR'"
  if [[ -d $SOURCE_DIR/centralConfiguration ]]
  then
    cp -R $SOURCE_DIR/centralConfiguration $TARGET_DIR
  else
    echo "Failed to migrate!. No 'centralConfiguration' directory exists in the $SOURCE_DIR"
    exit 1
  fi
  if [[ -d $SOURCE_DIR/conf ]]
  then
    if [[ -f $SOURCE_DIR/conf/repository-keystore.jceks ]]
    then
      mkdir -p $TARGET_DIR/conf
      cp -R $SOURCE_DIR/conf/repository-keystore.jceks $TARGET_DIR/conf
      rm -f $TARGET_DIR/conf/deployit.conf
      touch $TARGET_DIR/conf/deployit.conf
    else
      echo "Missing 'repository-keystore.jceks' file"
    fi
  else
    echo "Failed to migrate!. No 'conf' directory exists in the $SOURCE_DIR"
    exit 1
  fi

  {
    echo http.port=8888
    sed -n '/xl.spring.cloud.encrypt.key\=/p' $SOURCE_DIR/conf/deployit.conf
    sed -n '/repository.keystore.password\=/p' $SOURCE_DIR/conf/deployit.conf
  } >> $TARGET_DIR/conf/deployit.conf
else
  echo "Failed to migrate embedded central-configuration to standalone, Missing embedded central-configuration directory '$SOURCE_DIR'"
  exit 1
fi
echo "Successfully migrated from embedded central-configuration to standalone."
