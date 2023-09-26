#!/bin/bash

function pwgen {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

function check_eula {
  if [[ -z "$XL_LICENSE" && -z "$XL_NO_UNREGISTERED_LICENSE" && ! -f "${APP_HOME}/conf/xl-release-license.lic" && "$XL_LICENSE_KIND" == "byol" ]]; then
      if [[  "$ACCEPT_EULA" != "Y" && "$ACCEPT_EULA" != "y" ]]; then
        echo "You must accept the End User License Agreement or provide your own license before this container can start."
        exit 1
      fi
  fi;
}

function copy_mq_driver {
  case ${XLD_TASK_QUEUE_DRIVER_CLASS_NAME} in
    *rabbitmq*)
      echo "Detected RabbitMQ configuration. Copying required drivers to the lib folder."
      cp ${APP_ROOT}/mq-libs/rabbitmq-jms* ${APP_HOME}/lib
      cp ${APP_ROOT}/mq-libs/amqp-client* ${APP_HOME}/lib
      ;;
    *activemq*)
      echo "Detected ActiveMQ configuration. Copying required drivers to the lib folder."
      cp ${APP_ROOT}/mq-libs/activemq* ${APP_HOME}/lib
      ;;
    *)
      echo "MQ Provider could not be inferred from url '${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}'"
      ;;
  esac
}

function copy_db_driver {
  echo "Copying a database driver"

  case ${XL_DB_URL} in
    jdbc:h2:*)
      cp ${APP_ROOT}/db-libs/h2* ${APP_HOME}/lib
      ;;
    jdbc:derby:*)
      echo "Derby jdbc driver is provided by default in the classpath"
      ;;
    jdbc:oracle:*)
      echo "oracle jdbc driver is not provided by default in the classpath, please make sure you provide one. Please refer readme for more details"
      ;;
    jdbc:mysql:*)
      cp ${APP_ROOT}/db-libs/mysql* ${APP_HOME}/lib
      ;;
    jdbc:postgresql:*)
      cp ${APP_ROOT}/db-libs/postgresql* ${APP_HOME}/lib
      ;;
    jdbc:sqlserver:*)
      cp ${APP_ROOT}/db-libs/mssql* ${APP_HOME}/lib
      ;;
    jdbc:db2:*)
      echo "db2 jdbc driver is not provided by default in the classpath, please make sure you provide one. Please refer readme for more details"
      ;;
    *)
        echo "Database type could not be inferred from url '${XL_REPO_DB_URL}', supported db types are 'h2', 'derby', 'oracle', 'mysql', 'postgresql', 'sqlserver', 'db2'"
        exit 1
        ;;
  esac
}

function set_db_driver {
  echo "Setting database driver classname"

  case ${XL_DB_URL} in
    jdbc:h2:*)
      XL_DB_DRIVER="org.h2.Driver"
      ;;
    jdbc:derby:*)
      
        XL_DB_DRIVER="org.apache.derby.jdbc.AutoloadedDriver"
      
      ;;
    jdbc:oracle:*)
      XL_DB_DRIVER="oracle.jdbc.OracleDriver"
      ;;
    jdbc:mysql:*)
      XL_DB_DRIVER="com.mysql.jdbc.Driver"
      ;;
    jdbc:postgresql:*)
      XL_DB_DRIVER="org.postgresql.Driver"
      ;;
    jdbc:sqlserver:*)
      XL_DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
      ;;
    jdbc:db2:*)
      XL_DB_DRIVER="com.ibm.db2.jcc.DB2Driver"
      ;;
  esac
}

function store_license {
  if [ -f "${APP_HOME}/conf/xl-release-license.lic" ]; then
    echo "Pre-existing license found, not overwriting"
    return
  fi

  if [ -v XL_LICENSE ]; then
    echo "License has been explicitly provided in \${XL_LICENSE}. Using it"
    echo ${XL_LICENSE} > ${APP_HOME}/conf/xl-release-license.lic
    return
  fi

  if [ $XL_LICENSE_KIND != "byol" ]; then
    echo "License kind '$XL_LICENSE_KIND' has been configured, not requesting trial license"
    return
  fi


  if [ ! -v XL_NO_UNREGISTERED_LICENSE ]; then
    echo "XL_NO_UNREGISTERED_LICENSE was not set. Requesting unregistered license"
    SERVER_PATH_PART=${XL_LICENSE_ENDPOINT:-https://download.xebialabs.com}
    echo -e $(curl -X POST "${SERVER_PATH_PART}/api/unregistered/xl-release" | jq --raw-output .license) | base64 -di > ${APP_HOME}/conf/xl-release-license.lic
    return
  fi
}

# Generate node-specific xl-release.conf file
# The ${APP_HOME}/node-conf/xl-release.conf file provides node specific properties, which are then merged with the
# ${APP_HOME}/conf/xl-release.conf file by the xl-platform when the instance is started.
# The ${APP_HOME}/node-conf takes precedance over ${APP_HOME}/conf/xl-release.conf and this is specified in ${APP_HOME}/conf/xlr-wrapper-linux.conf
function generate_node_conf {
  
    echo "Re-generate node cluster configuration"
    HOSTNAME=$(hostname)
    if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
      HOSTNAME=$(hostname -i)
    fi
    IP_ADDRESS=$(hostname -i)
    
      if [ -e ${APP_HOME}/node-conf/xl-release.conf.template ]; then
        sed -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XL_NODE_NAME}#${IP_ADDRESS}#g" \
          ${APP_HOME}/node-conf/xl-release.conf.template > ${APP_HOME}/node-conf/xl-release.conf
      fi
    
  
}

function generate_product_conf {
  
    if [ -z "$XL_DB_URL" ]; then
      echo "... Using default conf/xl-release.conf"
      return
    fi

    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating xl-release.conf as GENERATE_XL_CONFIG != 'true'"
      elif [ -e ${APP_HOME}/default-conf/xl-release.conf.template ]; then
        echo "Generate configuration file xl-release.conf from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_DB_MAX_POOL_SIZE}#${XL_DB_MAX_POOL_SIZE}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${SERVER_URL}#${SERVER_URL}#g" \
            -e "s#\${XL_REPORT_DB_URL}#${XL_REPORT_DB_URL}#g" \
            -e "s#\${XL_REPORT_DB_USERNAME}#${XL_REPORT_DB_USERNAME}#g" \
            -e "s#\${XL_REPORT_DB_PASSWORD}#${XL_REPORT_DB_PASSWORD}#g" \
            -e "s#\${XL_REPORT_DB_MAX_POOL_SIZE}#${XL_REPORT_DB_MAX_POOL_SIZE}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_EMBEDDED_QUEUE}#${ENABLE_EMBEDDED_QUEUE}#g" \
            -e "s#\${XLR_TASK_QUEUE_PASSWORD}#${XLR_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${XLR_TASK_QUEUE_NAME}#${XLR_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLR_TASK_QUEUE_URL}#${XLR_TASK_QUEUE_URL}#g" \
            -e "s#\${XLR_TASK_QUEUE_USERNAME}#${XLR_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${PLUGIN_SOURCE}#${PLUGIN_SOURCE}#g" \
            -e "s#\${FORCE_REMOVE_MISSING_TYPES}#${FORCE_REMOVE_MISSING_TYPES}#g" \
            -e "s#\${XLR_HTTP2_ENABLED}#${XLR_HTTP2_ENABLED}#g" \
        ${APP_HOME}/default-conf/xl-release.conf.template > ${APP_HOME}/conf/xl-release.conf
      fi
    
  
}

function check_force_upgrade {
   FORCE_UPGRADE_FLAG=""
   if [[ ${FORCE_UPGRADE,,} == "true" ]] ; then
     echo "Force upgrade setting has been detected. In case of upgrade it will be performed in non-interactive mode. "
     FORCE_UPGRADE_FLAG="-force-upgrades"
   fi
}

function set_plugin_source {
    if [[ "$1" == "worker" ]]
    then
        PLUGIN_SOURCE_FLAG="-pluginSource=${PLUGIN_SOURCE}"
    else
        PLUGIN_SOURCE_FLAG="-plugin-source=${PLUGIN_SOURCE}"
    fi

    echo "Configuring plugin source. Setting value to ${PLUGIN_SOURCE_FLAG}"
}



function set_force_remove_missing_types {
    if [[ "${FORCE_REMOVE_MISSING_TYPES}" == "true" ]]
    then
        FORCE_REMOVE_MISSING_TYPES_FLAG="-force-remove-missing-types"
    fi
}


# Copy default plugins
if [ -z "$(ls -A ${APP_HOME}/plugins)" ]; then
  echo "Empty ${APP_HOME}/plugins directory detected:"
fi
  
echo "... Copying default plugins from ${APP_HOME}/default-plugins to ${APP_HOME}/plugins when a plugin is missing"

cd ${APP_HOME}/default-plugins
for pluginrepo in *; do
  if [ -d ${APP_HOME}/default-plugins/$pluginrepo ]; then
    mkdir -p ${APP_HOME}/plugins/$pluginrepo
    cd ${APP_HOME}/default-plugins/$pluginrepo
    for pluginjar in *; do
      pluginbasename=${pluginjar%%-[0-9\.]*.jar}
      if [ -f ${APP_HOME}/plugins/*/$pluginbasename-[0-9\.]*.jar ]; then
        echo "... Not copying $pluginrepo/$pluginjar because a version of that plugin already exists in the plugins directory"
      else
        echo "... Copying $pluginrepo/$pluginjar to the plugins directory"
        cp -R ${APP_HOME}/default-plugins/$pluginrepo/$pluginjar ${APP_HOME}/plugins/$pluginrepo/
      fi
    done
  else
    cp -R ${APP_HOME}/default-plugins/$pluginrepo ${APP_HOME}/plugins/
  fi
done
cd ${APP_HOME}
echo "Done copying default plugins"

# Clean out of the box empty config file to generate template.
rm ${APP_HOME}/default-conf/xl-release.conf

# copy default configurations
echo "... Copying default configuration from ${APP_HOME}/default-conf"

cd ${APP_HOME}/default-conf
for f in *; do
  if [[ $f == *.template ]]; then
    continue
  fi
  if [ -f ${APP_HOME}/conf/$f ]; then
    echo "... Not copying $f because it already exists in the conf directory"
  else
    echo "... Copying $f to the conf directory"
    cp -R $f ${APP_HOME}/conf/
  fi
done
cd ${APP_HOME}
echo "Done copying default configurations"

# Set up new installation
if [ ! -f "${APP_HOME}/conf/xl-release-server.conf" ]; then
  echo "No ${APP_HOME}/conf/xl-release-server.conf file detected:"

  if [ $# -eq 0 ]; then
    echo "No arguments passed to container:"
    echo "... Running default setup"

    if [ "${ADMIN_PASSWORD}" = "" ]; then
      ADMIN_PASSWORD=`pwgen 8`
      echo "... Generating admin password: ${ADMIN_PASSWORD}"
    fi

    if [ "${REPOSITORY_KEYSTORE}" = "" ]; then
      if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" = "" ]; then
        REPOSITORY_KEYSTORE_PASSPHRASE=`pwgen 16`
        echo "... Generating repository keystore passphrase: ${REPOSITORY_KEYSTORE_PASSPHRASE}"
      fi
      echo "... Generating repository keystore"
      keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}
    else
      if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" = "" ]; then
        echo "REPOSITORY_KEYSTORE provided, without an accompanying passphrase. exiting..."
        exit 1
      fi
      echo "${REPOSITORY_KEYSTORE}" | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks
    fi

    if [[ -z "$SSL" ]]; then
      SSL=false
    fi

    if [[ -z "$APP_PORT" ]]; then
      APP_PORT=5516
    fi

    if [[ -z "$APP_CONTEXT_ROOT" ]]; then
      APP_CONTEXT_ROOT="/"
    fi

    echo "... Generating xl-release-server.conf"
    sed -e "s#\${ADMIN_PASSWORD}#${ADMIN_PASSWORD}#g" \
      -e "s#\${REPOSITORY_KEYSTORE_PASSPHRASE}#${REPOSITORY_KEYSTORE_PASSPHRASE}#g" \
      -e "s#\${SSL}#${SSL}#g" \
      -e "s#\${APP_PORT}#${APP_PORT}#g" \
      -e "s#\${APP_CONTEXT_ROOT}#${APP_CONTEXT_ROOT}#g" \
      ${APP_HOME}/default-conf/xl-release-server.conf.template > ${APP_HOME}/conf/xl-release-server.conf

    if [ -n "${SERVER_URL}" ]; then
      echo "Setting custom server URL: ${SERVER_URL}"
      echo -e "\nserver.url=${SERVER_URL}" | sed -e "s#\${APP_PORT}#${APP_PORT}#g" >> ${APP_HOME}/conf/xl-release-server.conf
    fi

    if [ -n "$HTTP_SSL_KEYSTORE_PATH" ]; then
      echo -e "\nkeystore.path=${HTTP_SSL_KEYSTORE_PATH}" >> ${APP_HOME}/conf/xl-release-server.conf
    fi
    if [ -n "$HTTP_SSL_KEYSTORE_PASSWORD" ]; then
      echo -e "\nkeystore.password=${HTTP_SSL_KEYSTORE_PASSWORD}" >> ${APP_HOME}/conf/xl-release-server.conf
    fi
    if [ -n "$HTTP_SSL_KEYSTORE_KEYPASSWORD" ]; then
      echo -e "\nkeystore.keypassword=${HTTP_SSL_KEYSTORE_KEYPASSWORD}" >> ${APP_HOME}/conf/xl-release-server.conf
    fi

    echo "Done"
  fi
else 
  echo "Found ${APP_HOME}/conf/xl-release-server.conf file. Processing it for new properties"

  echo "Updating http port and context root properties"
  grep "http.port=" ${APP_HOME}/conf/xl-release-server.conf && sed -i "s#http.port\=.*##" ${APP_HOME}/conf/xl-release-server.conf
  grep "http.context.root=" ${APP_HOME}/conf/xl-release-server.conf && sed -i "s#http.context.root\=.*##" ${APP_HOME}/conf/xl-release-server.conf
  {
    echo ""
    echo http.port=${APP_PORT}
    echo http.context.root=${APP_CONTEXT_ROOT}
  } >> ${APP_HOME}/conf/xl-release-server.conf

  sed -i '/^$/d' ${APP_HOME}/conf/xl-release-server.conf
fi

# Fix OpenJDK SSL issue
case ${OS} in
  "debian")
    JAVA_CERT_PATH="/etc/ssl/certs/java"
    ;;
  "centos")
    JAVA_CERT_PATH="/etc/pki/ca-trust/extracted/java"
    ;;
  "rhel")
    JAVA_CERT_PATH="/etc/pki/ca-trust/extracted/java"
    ;;
  *)
    JAVA_CERT_PATH="/etc/ssl/certs/java"
    ;;
esac

if [[ ${GENERATE_XL_CONFIG,,} == "true" ]]; then
    sed "s#\${JAVA_CERT_PATH}#${JAVA_CERT_PATH}#g" ${APP_HOME}/default-conf/script.policy.template > ${APP_HOME}/conf/script.policy
fi

set_db_driver


    check_eula
    copy_db_driver
    copy_mq_driver
    store_license


generate_product_conf
generate_node_conf
check_force_upgrade
set_plugin_source $1
set_force_remove_missing_types

# Start regular startup process
exec ${APP_HOME}/bin/run.sh ${FORCE_UPGRADE_FLAG} "$@"  ${PLUGIN_SOURCE_FLAG}  ${FORCE_REMOVE_MISSING_TYPES_FLAG}
