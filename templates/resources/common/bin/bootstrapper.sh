#!/bin/bash

IP_ADDRESS=$(hostname -i)

echo "APP_ROOT=${APP_ROOT}"
echo "BOOTSTRAP_DIR=${BOOTSTRAP_DIR}"
echo "DATA_DIR=${DATA_DIR}"

function xlr_copy_extensions {
    DIRS=( "plugins" "hotfix" "ext" )
    for i in "${DIRS[@]}"; do
        if [[ -d ${BOOTSTRAP_DIR}/$i ]]; then
            echo "Copying $i to installation..."
            cp -fr ${BOOTSTRAP_DIR}/$i ${APP_HOME}/$i
        fi
    done
}

function xlr_generate_keystore {
    if [[ ! -e ${BOOTSTRAP_DIR}/conf/repository-keystore.jceks ]]; then
        echo "Generating random keystore"
        keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${BOOTSTRAP_DIR}/conf/repository-keystore.jceks -storetype jceks -storepass "docker"
        cp /tmp/templates/xl-release-server.conf ${BOOTSTRAP_DIR}/conf
        echo "repository.keystore.password=docker" >> ${BOOTSTRAP_DIR}/conf/xl-release-server.conf
    fi
}

function xlr_copy_bootstrap_conf {
    FILES=( "repository-keystore.jceks" "logback.xml" "security.policy", "xl-release.policy" "deployit-defaults.properties" "xl-release-security.xml" "keystore.jks" "xl-release-server.conf" )
    for i in "${FILES[@]}"; do
        if [[ -e ${BOOTSTRAP_DIR}/conf/$i ]]; then
            echo "Copying $i to installation..."
            cp ${BOOTSTRAP_DIR}/conf/$i ${APP_HOME}/conf
        fi
    done
}

function xlr_configure {
    echo "Customizing configuration based on environment settings"

    sed -e "s/XLR_NODE_NAME/${IP_ADDRESS}/g" '/tmp/templates/xl-release.conf' > "${APP_HOME}/conf/xl-release.conf"
    for e in `env | grep '^XLR_'`; do
        IFS='=' read -ra KV <<< "$e"
        sed -e "s#${KV[0]}#${KV[1]}#g" -i "${APP_HOME}/conf/xl-release.conf"
    done

    case ${XLR_DB_TYPE} in
        h2)
            XLR_DB_DRIVER="org.h2.Driver"
            ;;
        oracle)
            XLR_DB_DRIVER="oracle.jdbc.OracleDriver"
            echo "Still need support for 'oracle' jdbc driver"
            exit 1
            ;;
        mysql)
            XLR_DB_DRIVER="com.mysql.jdbc.Driver"
            curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar -o ${APP_HOME}/lib/mysql-connector-java-5.1.39.jar
            ;;
        postgres)
            XLR_DB_DRIVER="org.postgresql.Driver"
            curl http://repo1.maven.org/maven2/org/postgresql/postgresql/9.4.1211/postgresql-9.4.1211.jar -o ${APP_HOME}/lib/postgresql-9.4.1211.jar
            ;;
        mssql)
            XLR_DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
            curl http://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/6.2.2.jre8/mssql-jdbc-6.2.2.jre8.jar -o ${APP_HOME}/lib/mssql-jdbc-6.2.2.jre8.jar
            ;;
        db2)
            XLR_DB_DRIVER="com.ibm.db2.jcc.DB2Driver"
            echo "Still need support for 'db2' jdbc driver"
            exit 1
            ;;
        *)
            echo "Unknown DB type '${XLR_DB_TYPE}', supported db types are 'h2', 'oracle', 'mysql', 'postgres', 'mssql', 'db2'"
            exit 1
            ;;
    esac
    sed -e "s/XLR_DB_DRIVER/${XLR_DB_DRIVER}/g" -i "${APP_HOME}/conf/xl-release.conf"
    if [[ ! -e ${APP_HOME}/conf/xl-release-server.conf ]]; then
        cp /tmp/templates/xl-release-server.conf ${APP_HOME}/conf
        cp /tmp/templates/xlr-wrapper-linux.conf ${APP_HOME}/conf
        cp /tmp/templates/logback.xml ${APP_HOME}/conf
    fi
}

xlr_copy_extensions
xlr_generate_keystore
xlr_copy_bootstrap_conf
xlr_configure

${APP_HOME}/bin/run.sh
