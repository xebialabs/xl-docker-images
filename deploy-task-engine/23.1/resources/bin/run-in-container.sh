#!/bin/bash

function pwgen {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

function check_eula {
  if [[ -z "$XL_LICENSE" && -z "$XL_NO_UNREGISTERED_LICENSE" && ! -f "${APP_HOME}/conf/deployit-license.lic" && "$XL_LICENSE_KIND" == "byol" ]]; then
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
  case ${XL_DB_URL} in
    jdbc:derby:*)
      
        XL_DB_DRIVER="org.apache.derby.jdbc.AutoloadedDriver"
      
      echo "Derby jdbc driver is provided by default in the classpath"
      ;;
    jdbc:oracle:*)
      XL_DB_DRIVER="oracle.jdbc.OracleDriver"
      echo "oracle jdbc driver is not provided by default in the classpath, please make sure you provide one. Please refer readme for more details"
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
      echo "db2 jdbc driver is not provided by default in the classpath, please make sure you provide one. Please refer readme for more details"
      ;;
    *)
        echo "Database type could not be inferred from url '${XL_REPO_DB_URL}', supported db types are 'derby', 'oracle', 'mysql', 'postgresql', 'sqlserver', 'db2'"
        exit 1
        ;;
  esac
}

function store_license {
  if [ -f "${APP_HOME}/conf/deployit-license.lic" ]; then
    echo "Pre-existing license found, not overwriting"
    return
  fi

  if [ -v XL_LICENSE ]; then
    echo "License has been explicitly provided in \${XL_LICENSE}. Using it"
    echo ${XL_LICENSE} > ${APP_HOME}/conf/deployit-license.lic
    return
  fi

  if [ $XL_LICENSE_KIND != "byol" ]; then
    echo "License kind '$XL_LICENSE_KIND' has been configured, not requesting trial license"
    return
  fi

  if [ ! -v XL_NO_UNREGISTERED_LICENSE ]; then
    echo "XL_NO_UNREGISTERED_LICENSE was not set. Requesting unregistered license"
    SERVER_PATH_PART=${XL_LICENSE_ENDPOINT:-https://download.xebialabs.com}
    echo -e $(curl -X POST "${SERVER_PATH_PART}/api/unregistered/xl-deploy" | jq --raw-output .license) | base64 -di > ${APP_HOME}/conf/deployit-license.lic
    return
  fi
}


function generate_product_conf {

    if [[ -z "$OVERRIDE_HOSTNAME" ]]; then
      HOSTNAME=$(hostname)
      if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
        HOSTNAME=$(hostname -i)
      fi
    else
      HOSTNAME=$OVERRIDE_HOSTNAME
    fi
    IP_ADDRESS=$(hostname -i)

    if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
      echo "Not generating  as GENERATE_XL_CONFIG != 'true'"
    elif [ -e ${APP_HOME}/default-conf/.template ]; then
      echo "Generate configuration file  from environment parameters"
      sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
          -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
          -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
          -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
          -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
          -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
          -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
          -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
          -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
          -e "s#\${PLUGIN_SOURCE}#${PLUGIN_SOURCE}#g" \
          -e "s#\${USE_EXTERNAL_CENTRAL_CONFIG}#${USE_EXTERNAL_CENTRAL_CONFIG}#g" \
          -e "s#\${CENTRAL_CONFIG_URL}#${CENTRAL_CONFIG_URL}#g" \
          -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
      ${APP_HOME}/default-conf/.template > ${APP_HOME}/conf/
    fi
}


function set_plugin_source {
    PLUGIN_SOURCE_FLAG="-pluginSource=${PLUGIN_SOURCE}"
    echo "Configuring plugin source. Setting value to ${PLUGIN_SOURCE_FLAG}"
}


# Copy default plugins
if [ -z "$(ls -A ${APP_HOME}/plugins)" ]; then
  echo "Empty ${APP_HOME}/plugins directory detected:"
fi

echo "... Copying default plugins from ${APP_HOME}/default-plugins to ${APP_HOME}/plugins when a plugin is missing"

cd ${APP_HOME}/default-plugins
for pluginjar in *; do
  pluginbasename=${pluginjar%%-[0-9\.]*.xldp}
  if [ -f ${APP_HOME}/plugins/$pluginbasename-[0-9\.]*.xldp ]; then
    echo "... Not copying $pluginjar because a version of that plugin already exists in the plugins directory"
  else
    echo "... Copying $pluginjar to the plugins directory"
    cp -R ${APP_HOME}/default-plugins/$pluginjar ${APP_HOME}/plugins/
  fi
done

# Excluding plugins from the container.

cd ${APP_HOME}/plugins/xld-official
echo "Plugins to exclude from ${APP_HOME}/plugins/xld-official: [$PLUGINS_TO_EXCLUDE]"

if [[ ! -z "$PLUGINS_TO_EXCLUDE" ]]; then
  tmp=${PLUGINS_TO_EXCLUDE//","/$'\2'}
  IFS=$'\2' read -a arr <<< "$tmp"

  for name in "${arr[@]}" ; do
    if [ ! -z "$name" ]; then
      if [[ $(ls -d *"$name"* | wc -l) -ne 0 ]]; then
        echo Excluding $(ls -d *"$name"*)
        ls -d *"$name"* | xargs rm
      else
        echo "Plugin names containing '$name' have not found."
      fi
    fi
  done
fi

cd ${APP_HOME}
echo "Done copying default plugins"

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

if [[ -z "$SERVER_PORT" ]]; then
  SERVER_PORT=8180
fi
if [[ -z "$APP_PORT" ]]; then
  APP_PORT=4516
fi

# Set up new installation
if [ ! -f "${APP_HOME}/conf/deployit.conf" ]; then
  echo "No ${APP_HOME}/conf/deployit.conf file detected:"

  if [ $# -gt 0 ]; then
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
      echo ${REPOSITORY_KEYSTORE} | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks
    fi

    if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
      HOSTNAME=$(hostname -i)
    fi

    if [[ -z "$OVERRIDE_HOSTNAME" ]]; then
      HOSTNAME=$(hostname)
      if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
        HOSTNAME=$(hostname -i)
      fi
    else
      HOSTNAME=$OVERRIDE_HOSTNAME
    fi

    if [[ -z "$SSL" ]]; then
      SSL=false
    fi

    echo "... Generating deployit.conf"
    sed -e "s#\${ADMIN_PASSWORD}#${ADMIN_PASSWORD}#g" \
      -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
      -e "s#\${REPOSITORY_KEYSTORE_PASSPHRASE}#${REPOSITORY_KEYSTORE_PASSPHRASE}#g" \
      -e "s#\${USE_EXTERNAL_CENTRAL_CONFIG}#${USE_EXTERNAL_CENTRAL_CONFIG}#g" \
      -e "s#\${CENTRAL_CONFIG_URL}#${CENTRAL_CONFIG_URL}#g" \
      -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
      -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
      -e "s#\${SSL}#${SSL}#g" \
      -e "s#\${SERVER_PORT}#${SERVER_PORT}#g" \
      -e "s#\${APP_PORT}#${APP_PORT}#g" \
      ${APP_HOME}/default-conf/deployit.conf.template > ${APP_HOME}/conf/deployit.conf

    echo "Done"
  fi
else
    echo "Found ${APP_HOME}/conf/deployit.conf file. Processing it for new properties"

    if [[ -z "$OVERRIDE_HOSTNAME" ]]; then
      HOSTNAME=$(hostname)
      if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
        HOSTNAME=$(hostname -i)
      fi
    else
      HOSTNAME=$OVERRIDE_HOSTNAME
    fi

    if [[ "${HOSTNAME}" != "" && "${HOSTNAME_SUFFIX}" != "" ]]; then
      echo "Updating server.hostname with HOSTNAME & HOSTNAME_SUFFIX properties"
      grep "server.hostname=" ${APP_HOME}/conf/deployit.conf && sed -i "s#server.hostname\=.*##" ${APP_HOME}/conf/deployit.conf
      {
        echo server.hostname=${HOSTNAME}${HOSTNAME_SUFFIX}
      } >> ${APP_HOME}/conf/deployit.conf
    fi
    if [[ "${USE_EXTERNAL_CENTRAL_CONFIG}" != "" ]]; then
      echo "Updating xl.spring.cloud.external-config with USE_EXTERNAL_CENTRAL_CONFIG property"
      grep "xl.spring.cloud.external-config=" ${APP_HOME}/conf/deployit.conf && sed -i "s#xl.spring.cloud.external-config\=.*##" ${APP_HOME}/conf/deployit.conf
      {
        echo xl.spring.cloud.external-config=${USE_EXTERNAL_CENTRAL_CONFIG}
      } >> ${APP_HOME}/conf/deployit.conf
    fi
    if [[ "${CENTRAL_CONFIG_URL}" != "" ]]; then
      echo "Updating xl.spring.cloud.uri with CENTRAL_CONFIG_URL property"
      grep "xl.spring.cloud.uri=" ${APP_HOME}/conf/deployit.conf && sed -i "s#xl.spring.cloud.uri\=.*##" ${APP_HOME}/conf/deployit.conf
      {
        echo xl.spring.cloud.uri=${CENTRAL_CONFIG_URL}
      } >> ${APP_HOME}/conf/deployit.conf
    fi
    if [[ "${CENTRAL_CONFIG_ENCRYPT_KEY}" != "" ]]; then
      if ! grep -q xl.spring.cloud.encrypt.key ${APP_HOME}/conf/deployit.conf; then
        echo "Updating xl.spring.cloud.encrypt.key with CENTRAL_CONFIG_ENCRYPT_KEY property"
        {
          echo xl.spring.cloud.encrypt.key=${CENTRAL_CONFIG_ENCRYPT_KEY}
        } >> ${APP_HOME}/conf/deployit.conf
      fi
    fi
    echo "Updating server port and cloud enabled properties"
    grep "server.port=" ${APP_HOME}/conf/deployit.conf && sed -i "s#server.port\=.*##" ${APP_HOME}/conf/deployit.conf
    grep "xl.spring.cloud.enabled=" ${APP_HOME}/conf/deployit.conf && sed -i "s#xl.spring.cloud.enabled\=.*##" ${APP_HOME}/conf/deployit.conf
    {
      echo server.port=${SERVER_PORT}
      echo xl.spring.cloud.enabled=true
    } >> ${APP_HOME}/conf/deployit.conf

    sed -i '/^$/d' ${APP_HOME}/conf/deployit.conf
fi

check_eula
copy_db_driver
copy_mq_driver
store_license
generate_product_conf
set_plugin_source

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"  ${PLUGIN_SOURCE_FLAG} 