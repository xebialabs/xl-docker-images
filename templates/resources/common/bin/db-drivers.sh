#!/bin/bash
set -e

MYSQL_VERSION="8.0.31"
H2_VERSION="2.1.214"
POSTGRESQL_VERSION="42.5.1"
MSSQL_VERSION="11.2.2.jre11"

echo "Downloading DB drivers to ${APP_ROOT}/db-libs"
mkdir ${APP_ROOT}/db-libs

curl https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_VERSION}/mysql-connector-j-${MYSQL_VERSION}.jar -o ${APP_ROOT}/db-libs/mysql-connector-j-${MYSQL_VERSION}.jar -f
curl https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar -o ${APP_ROOT}/db-libs/h2-${H2_VERSION}.jar -f
curl https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_VERSION}.jar -o ${APP_ROOT}/db-libs/postgresql-${POSTGRESQL_VERSION}.jar -f
curl https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_VERSION}/mssql-jdbc-${MSSQL_VERSION}.jar -o ${APP_ROOT}/db-libs/mssql-jdbc-${MSSQL_VERSION}.jar -f

echo "Downloading MQ drivers to ${APP_ROOT}/mq-libs"
mkdir ${APP_ROOT}/mq-libs

RABBIT_MQ_AMQP_VERSION="5.16.0"
RABBIT_MQ_JMS_VERSION="2.8.0"
ACTIVE_MQ_VERSION="5.17.3"

curl https://repo1.maven.org/maven2/com/rabbitmq/amqp-client/${RABBIT_MQ_AMQP_VERSION}/amqp-client-${RABBIT_MQ_AMQP_VERSION}.jar -o ${APP_ROOT}/mq-libs/amqp-client-${RABBIT_MQ_AMQP_VERSION}.jar -f
curl https://repo1.maven.org/maven2/com/rabbitmq/jms/rabbitmq-jms/${RABBIT_MQ_JMS_VERSION}/rabbitmq-jms-${RABBIT_MQ_JMS_VERSION}.jar -o ${APP_ROOT}/mq-libs/rabbitmq-jms-${RABBIT_MQ_JMS_VERSION}.jar
curl https://repo1.maven.org/maven2/org/apache/activemq/activemq-all/${ACTIVE_MQ_VERSION}/activemq-all-${ACTIVE_MQ_VERSION}.jar -o ${APP_ROOT}/mq-libs/activemq-all-${ACTIVE_MQ_VERSION}.jar
