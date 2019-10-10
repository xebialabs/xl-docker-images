#!/bin/bash
set -e

MYSQL_VERSION="5.1.39"
H2_VERSION="1.4.197"
POSTGRESQL_VERSION="42.2.5"
MSSQL_VERSION="6.2.2.jre8"

echo "Downloading DB drivers to ${APP_ROOT}/db-libs"
mkdir ${APP_ROOT}/db-libs

curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar -o ${APP_ROOT}/db-libs/mysql-connector-java-${MYSQL_VERSION}.jar -f
curl http://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar -o ${APP_ROOT}/db-libs/h2-${H2_VERSION}.jar -f
curl https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_VERSION}.jar -o ${APP_ROOT}/db-libs/postgresql-${POSTGRESQL_VERSION}.jar -f
curl http://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_VERSION}/mssql-jdbc-${MSSQL_VERSION}.jar -o ${APP_ROOT}/db-libs/mssql-jdbc-${MSSQL_VERSION}.jar -f

echo "Downloading MQ drivers to ${APP_ROOT}/mq-libs"
mkdir ${APP_ROOT}/mq-libs

curl https://repo1.maven.org/maven2/com/rabbitmq/amqp-client/5.7.3/amqp-client-5.7.3.jar -o ${APP_ROOT}/mq-libs/amqp-client-5.7.3.jar -f
curl https://repo1.maven.org/maven2/com/rabbitmq/jms/rabbitmq-jms/1.13.0/rabbitmq-jms-1.13.0.jar -o ${APP_ROOT}/mq-libs/rabbitmq-jms-1.13.0.jar
curl https://repo1.maven.org/maven2/org/apache/activemq/activemq-all/5.15.9/activemq-all-5.15.9.jar -o ${APP_ROOT}/mq-libs/activemq-all-5.15.9.jar
