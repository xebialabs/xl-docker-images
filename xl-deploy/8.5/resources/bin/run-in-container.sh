#!/bin/bash

function pwgen {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

function copy_db_driver {
  case ${XL_DB_URL} in
    jdbc:h2:*)
      XL_DB_DRIVER="org.h2.Driver"
      cp ${APP_ROOT}/db-libs/h2* ${APP_HOME}/lib
      ;;
    jdbc:oracle:*)
      XL_DB_DRIVER="oracle.jdbc.OracleDriver"
      echo "Still need support for 'oracle' jdbc driver"
      exit 1
      ;;
    jdbc:mysql:*)
      XL_DB_DRIVER="com.mysql.jdbc.Driver"
      cp ${APP_ROOT}/db-libs/mysql* ${APP_HOME}/lib
      ;;
    jdbc:postgresql:*)
      XL_DB_DRIVER="org.postgresql.Driver"
      cp ${APP_ROOT}/db-libs/postgresql* ${APP_HOME}/lib
      ;;
    jdbc:sqlserver:*)
      XL_DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
      cp ${APP_ROOT}/db-libs/mssql* ${APP_HOME}/lib
      ;;
    jdbc:db2:*)
      XL_DB_DRIVER="com.ibm.db2.jcc.DB2Driver"
      echo "Still need support for 'db2' jdbc driver"
      exit 1
      ;;
    *)
        echo "Database type could not be inferred from url '${XL_REPO_DB_URL}', supported db types are 'h2', 'oracle', 'mysql', 'postgresql', 'sqlserver', 'db2'"
        exit 1
        ;;
  esac
}

function store_license {
  if [ -z "${XL_LICENSE}" ]; then
    echo "No license provided in \${XL_LICENSE}"
    return
  fi

  if [ -f "${APP_HOME}/conf/deployit-license.lic" ]; then
    echo "Pre-existing license found, not overwriting"
    return
  fi

  echo ${XL_LICENSE} > ${APP_HOME}/conf/deployit-license.lic
}

function generate_node_conf {
  echo "Re-generate node cluster configuration"
  IP_ADDRESS=$(hostname -i)
  sed -e "s#\${XL_NODE_NAME}#${IP_ADDRESS}#g" \
      ${APP_HOME}/node-conf/xl-deploy.conf.template > ${APP_HOME}/node-conf/xl-deploy.conf

}

function generate_system_conf {
  echo "Re-generate node cluster configuration"
  IP_ADDRESS=$(hostname -i)
  sed -e "s#\${XL_NODE_NAME}#${IP_ADDRESS}#g" \
      ${APP_HOME}/node-conf/xl-deploy.conf.template > ${APP_HOME}/node-conf/xl-deploy.conf

}

function generate_product_conf {
  if [ -z "$XL_DB_URL" ]; then
    echo "... Using default conf/xl-deploy.conf"
    return
  fi

  echo "Generate configuration file from environment parameters"
  sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
      -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
      -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
      -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
      -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
      -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
  ${APP_HOME}/default-conf/xl-deploy.conf.template > ${APP_HOME}/conf/xl-deploy.conf
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
    if [[ $f == *.template ]]; then
      continue
    fi
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
    sed -e "s/\${ADMIN_PASSWORD}/${ADMIN_PASSWORD}/g" -e "s/\${REPOSITORY_KEYSTORE_PASSPHRASE}/${REPOSITORY_KEYSTORE_PASSPHRASE}/g" ${APP_HOME}/default-conf/deployit.conf.template > ${APP_HOME}/conf/deployit.conf

    echo "Done"
  fi
fi

copy_db_driver
generate_product_conf
generate_node_conf
store_license

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"