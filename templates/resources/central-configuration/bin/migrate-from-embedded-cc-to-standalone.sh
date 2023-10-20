#!/bin/bash

# Embedded central-configuration mount path
SOURCE_DIR="/mnt/centralConfiguration-source-dir"
# Standalone central-configuration mount path
TARGET_DIR="/mnt/centralConfiguration-target-dir"

echo "Start migrating from embedded central-configuration to standalone"
if [[ -d $SOURCE_DIR && -d $TARGET_DIR  &&  ! -d "$TARGET_DIR/conf" && ! -d "$TARGET_DIR/centralConfiguration" ]]
then
  echo "Copying embedded central-configuration from directory '$SOURCE_DIR'"
  if [[ -d $SOURCE_DIR/centralConfiguration ]]
  then
    cp -R $SOURCE_DIR/centralConfiguration $TARGET_DIR
  else
    echo "No 'centralConfiguration' directory exists in the $SOURCE_DIR"
  fi
  if [[ -d $SOURCE_DIR/conf ]]
  then
    mkdir -p $TARGET_DIR/conf
    rm -f $TARGET_DIR/conf/deployit.conf
    touch $TARGET_DIR/conf/deployit.conf
    {
      echo http.port=$APP_PORT
      sed -n '/xl.spring.cloud.encrypt.key\=/p' $SOURCE_DIR/conf/deployit.conf
      sed -n '/repository.keystore.password\=/p' $SOURCE_DIR/conf/deployit.conf
    } >> $TARGET_DIR/conf/deployit.conf

    if [[ -f $SOURCE_DIR/conf/repository-keystore.jceks ]]
    then
      cp -R $SOURCE_DIR/conf/repository-keystore.jceks $TARGET_DIR/conf
    else
      echo "Missing 'repository-keystore.jceks' file"
    fi
  else
    echo "No 'conf' directory exists in the $SOURCE_DIR"
  fi
else
  echo "Check the listed directories are exists: [$SOURCE_DIR, $TARGET_DIR]"
fi
echo "Successfully migrated from embedded central-configuration to standalone."
