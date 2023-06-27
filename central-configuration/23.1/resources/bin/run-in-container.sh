#!/bin/bash

function pwgen {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

function check_eula {
  if [[ -z "$XL_LICENSE" && -z "$XL_NO_UNREGISTERED_LICENSE" && ! -f "${APP_HOME}/conf/" && "$XL_LICENSE_KIND" == "byol" ]]; then
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
      
        XL_DB_DRIVER="org.apache.derby.iapi.jdbc.AutoloadedDriver"
      
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
  if [ -f "${APP_HOME}/conf/" ]; then
    echo "Pre-existing license found, not overwriting"
    return
  fi

  if [ -v XL_LICENSE ]; then
    echo "License has been explicitly provided in \${XL_LICENSE}. Using it"
    echo ${XL_LICENSE} > ${APP_HOME}/conf/
    return
  fi

  if [ $XL_LICENSE_KIND != "byol" ]; then
    echo "License kind '$XL_LICENSE_KIND' has been configured, not requesting trial license"
    return
  fi


  if [ ! -v XL_NO_UNREGISTERED_LICENSE ]; then
    echo "XL_NO_UNREGISTERED_LICENSE was not set. Requesting unregistered license"
    SERVER_PATH_PART=${XL_LICENSE_ENDPOINT:-https://download.xebialabs.com}
    echo -e $(curl -X POST "${SERVER_PATH_PART}/api/unregistered/central-configuration" | jq --raw-output .license) | base64 -di > ${APP_HOME}/conf/
    return
  fi
}

# Generate node-specific central-configuration.conf file
# The ${APP_HOME}/node-conf/central-configuration.conf file provides node specific properties, which are then merged with the
# ${APP_HOME}/conf/central-configuration.conf file by the xl-platform when the instance is started.
# The ${APP_HOME}/node-conf takes precedance over ${APP_HOME}/conf/central-configuration.conf and this is specified in ${APP_HOME}/conf/xlc-wrapper.conf.common
function generate_node_conf {
  
    echo "Re-generate node cluster configuration"
    HOSTNAME=$(hostname)
    if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
      HOSTNAME=$(hostname -i)
    fi
    IP_ADDRESS=$(hostname -i)
    
  
}

function generate_product_conf {
  
    if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
        DNS_RESOLVER="inet-address"
    else
        DNS_RESOLVER="async-dns"
    fi

    if [ -z "$XL_DB_URL" ]; then
      echo "... Using default centralConfiguration/deploy-repository.yaml"
      return
    fi

    HOSTNAME=$(hostname)
    if [[ ${USE_IP_AS_HOSTNAME,,} == "true" ]]; then
      HOSTNAME=$(hostname -i)
    fi

    IP_ADDRESS=$(hostname -i)
    JMS_DRIVER_CLASS_NAME=${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}
    if [[ ${XLD_TASK_QUEUE_DRIVER_CLASS_NAME,,} == "rabbitmq" ]]; then
      JMS_DRIVER_CLASS_NAME="com.rabbitmq.jms.admin.RMQConnectionFactory"
    elif [[ ${XLD_TASK_QUEUE_DRIVER_CLASS_NAME,,} == "activemq" ]]; then
      JMS_DRIVER_CLASS_NAME="org.apache.activemq.ActiveMQConnectionFactory"
    fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-cluster.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-cluster.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-cluster.yaml" ]]; then
        echo "Generate configuration file deploy-cluster.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-cluster.yaml.template > ${APP_HOME}/centralConfiguration/deploy-cluster.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-metrics.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-metrics.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-metrics.yaml" ]]; then
        echo "Generate configuration file deploy-metrics.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-metrics.yaml.template > ${APP_HOME}/centralConfiguration/deploy-metrics.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-plugins.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-plugins.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-plugins.yaml" ]]; then
        echo "Generate configuration file deploy-plugins.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-plugins.yaml.template > ${APP_HOME}/centralConfiguration/deploy-plugins.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-repository.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-repository.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-repository.yaml" ]]; then
        echo "Generate configuration file deploy-repository.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-repository.yaml.template > ${APP_HOME}/centralConfiguration/deploy-repository.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-satellite.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-satellite.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-satellite.yaml" ]]; then
        echo "Generate configuration file deploy-satellite.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-satellite.yaml.template > ${APP_HOME}/centralConfiguration/deploy-satellite.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-secret-complexity.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-secret-complexity.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-secret-complexity.yaml" ]]; then
        echo "Generate configuration file deploy-secret-complexity.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-secret-complexity.yaml.template > ${APP_HOME}/centralConfiguration/deploy-secret-complexity.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-server.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-server.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-server.yaml" ]]; then
        echo "Generate configuration file deploy-server.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-server.yaml.template > ${APP_HOME}/centralConfiguration/deploy-server.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-task.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-task.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-task.yaml" ]]; then
        echo "Generate configuration file deploy-task.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-task.yaml.template > ${APP_HOME}/centralConfiguration/deploy-task.yaml
      fi
    
      if [[ ${GENERATE_XL_CONFIG,,} != "true" ]]; then
        echo "Not generating deploy-caches.yaml as GENERATE_XL_CONFIG != 'true'"
      elif [[ -e ${APP_HOME}/central-conf/deploy-caches.yaml.template && ! -f "${APP_HOME}/centralConfiguration/deploy-caches.yaml" ]]; then
        echo "Generate configuration file deploy-caches.yaml from environment parameters"
        sed -e "s#\${XL_DB_DRIVER}#${XL_DB_DRIVER}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${DNS_RESOLVER}#${DNS_RESOLVER}#g" \
            -e "s#\${HOSTNAME}#${HOSTNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${JMS_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XL_CLUSTER_MODE}#${XL_CLUSTER_MODE}#g" \
            -e "s#\${XL_DB_URL}#${XL_DB_URL}#g" \
            -e "s#\${XL_DB_USERNAME}#${XL_DB_USERNAME}#g" \
            -e "s#\${XL_DB_PASSWORD}#${XL_DB_PASSWORD}#g" \
            -e "s#\${XL_METRICS_ENABLED}#${XL_METRICS_ENABLED}#g" \
            -e "s#\${XLD_IN_PROCESS}#${XLD_IN_PROCESS}#g" \
            -e "s#\${XLD_TASK_QUEUE_NAME}#${XLD_TASK_QUEUE_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#${XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE}#g" \
            -e "s#\${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#${XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT}#g" \
            -e "s#\${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#${XLD_TASK_QUEUE_DRIVER_CLASS_NAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_URL}#${XLD_TASK_QUEUE_URL}#g" \
            -e "s#\${XLD_TASK_QUEUE_USERNAME}#${XLD_TASK_QUEUE_USERNAME}#g" \
            -e "s#\${XLD_TASK_QUEUE_PASSWORD}#${XLD_TASK_QUEUE_PASSWORD}#g" \
            -e "s#\${HOSTNAME_SUFFIX}#${HOSTNAME_SUFFIX}#g" \
            -e "s#\${XL_LICENSE_KIND}#${XL_LICENSE_KIND}#g" \
            -e "s#\${GENERATE_XL_CONFIG}#${GENERATE_XL_CONFIG}#g" \
            -e "s#\${USE_IP_AS_HOSTNAME}#${USE_IP_AS_HOSTNAME}#g" \
            -e "s#\${ENABLE_SATELLITE}#${ENABLE_SATELLITE}#g" \
            -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
            -e "s#\${USE_CACHE}#${USE_CACHE}#g" \
        ${APP_HOME}/central-conf/deploy-caches.yaml.template > ${APP_HOME}/centralConfiguration/deploy-caches.yaml
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




# Set up new installation
cd ${APP_HOME}/default-conf

if [ ! -f "${APP_HOME}/conf/deployit.conf" ]; then
  echo "No ${APP_HOME}/conf/deployit.conf file detected:"
  echo "... Generating deployit.conf"
  sed -e "s#\${CENTRAL_CONFIG_ENCRYPT_KEY}#${CENTRAL_CONFIG_ENCRYPT_KEY}#g" \
    ${APP_HOME}/default-conf/deployit.conf.template > ${APP_HOME}/conf/deployit.conf
  echo "Done"
fi

# copy default configurations
echo "... Copying default configuration from ${APP_HOME}/default-conf"

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

set_db_driver



generate_product_conf
generate_node_conf
check_force_upgrade
set_plugin_source $1


# Start regular startup process
exec ${APP_HOME}/bin/run.sh ${FORCE_UPGRADE_FLAG} "$@"  ${PLUGIN_SOURCE_FLAG}  ${FORCE_REMOVE_MISSING_TYPES_FLAG}
