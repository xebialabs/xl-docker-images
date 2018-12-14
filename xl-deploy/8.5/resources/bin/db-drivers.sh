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
