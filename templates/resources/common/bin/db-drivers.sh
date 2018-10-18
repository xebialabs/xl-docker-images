#!/bin/bash

echo "Downloading DB drivers to ${APP_ROOT}/db-libs"
mkdir ${APP_ROOT}/db-libs

curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar -o ${APP_ROOT}/db-libs/mysql-connector-java-5.1.39.jar
curl http://repo1.maven.org/maven2/com/h2database/h2/1.4.197/h2-1.4.197.jar -o ${APP_ROOT}/db-libs/h2-1.4.197.jar
curl https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o ${APP_ROOT}/db-libs/postgresql-42.2.5.jar
curl http://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/6.2.2.jre8/mssql-jdbc-6.2.2.jre8.jar -o ${APP_ROOT}/db-libs/mssql-jdbc-6.2.2.jre8.jar
