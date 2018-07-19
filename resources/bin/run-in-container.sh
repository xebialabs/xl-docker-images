#!/bin/sh

pwgen() {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

# Copy default plugins
if [ -z "$(ls -A ${APP_HOME}/plugins)" ]; then
  echo "Empty ${APP_HOME}/plugins directory detected:"
  echo "... Copying default plugins from ${APP_HOME}/default-plugins"

  cd ${APP_HOME}/default-plugins
  for pluginjar in *; do
    pluginbasename=${pluginjar%%-[0-9\.]*.jar}
    if [ -f ${APP_HOME}/plugins/*/$pluginbasename-[0-9\.]*.jar ]; then
      echo "... Not copying $pluginrepo/$pluginjar because a version of that plugin already exists in the plugins directory"
    else
      cp -R ${APP_HOME}/default-plugins/$pluginrepo/$pluginjar ${APP_HOME}/plugins/$pluginrepo/
    fi
  done
  cd ${APP_HOME}

  echo "Done"
fi

# Set up new installation
if [ ! -f "${APP_HOME}/conf/deployit.conf" ]; then
  echo "No ${APP_HOME}/conf/deployit.conf file detected:"
  echo "... Copying default configuration from ${APP_HOME}/default-conf"

  cd ${APP_HOME}/default-conf
  for f in *; do
    if [ -f ${APP_HOME}/conf/$f ]; then
      echo "... Not copying $f because it already exists in the conf directory"
    else
      cp -R $f ${APP_HOME}/conf/
    fi
  done
  cd ${APP_HOME}

  echo "Done"

  if [ $# -eq 0 ]; then
    echo "No arguments passed to container:"
    echo "... Running default setup"

    if [ "${ADMIN_PASSWORD}" = "" ]; then
      ADMIN_PASSWORD=`pwgen 8`
      echo "... Generating admin password: ${ADMIN_PASSWORD}"
    fi

    if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" = "" ]; then
      REPOSITORY_KEYSTORE_PASSPHRASE=`pwgen 16`
      echo "... Generating repository keystore passphrase: ${REPOSITORY_KEYSTORE_PASSPHRASE}"
    fi
    echo "... Generating repository keystore"
    keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

    echo "... Generating deployit.conf"
    sed -e "s/\${ADMIN_PASSWORD}/${ADMIN_PASSWORD}/g" -e "s/\${REPOSITORY_KEYSTORE_PASSPHRASE}/${REPOSITORY_KEYSTORE_PASSPHRASE}/g" ${APP_HOME}/conf/deployit.conf.template > ${APP_HOME}/conf/deployit.conf

    echo "Done"
  fi
fi



# Generate node specific configuration with IP address of container
IP_ADDRESS=$(hostname -i)
sed -e "s/\${IP_ADDRESS}/${IP_ADDRESS}/g" ${APP_HOME}/node-conf/xl-deploy.conf.template > ${APP_HOME}/node-conf/xl-deploy.conf

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"
