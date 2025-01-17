---
sidebar_position: 1
---

# Environment variables

#### The following environment variables can be set to configure XL Docker image for different scenarios

### Common for all XL Products docker images

##### `ADMIN_PASSWORD`
- Admin user password used in XL Products.
- possible values: "password-value"
- default value: If this value is not passed a random 8 characters password will be generated.
- example: "adm_P@ssw0rd_01"

##### `REPOSITORY_KEYSTORE_PASSPHRASE`
- Repository keystore passphrase used in XL Products.
- possible values: "passphrase-string-value"
- default value: If this value is not passed a random 16 characters password will be generated.
- example: "XL_P@ssphr@se_01"
- **Note:**
    - Keystore password must be at least 6 characters.

##### `REPOSITORY_KEYSTORE`
- Repository keystore used in XL Products.
- possible values: "keystore-string-value"
- default value: content of `${APP_HOME}/conf/repository-keystore.jceks` which is generated from `keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}`
- example: "b3J0IHBvbGljeTogMSBtb250aCBvZiB0ZWNobmljYWwgc3VwcG9ydApFZGl0aW9uOiBUcmlhbAotLS0gU2lnbmF0dXJlIChTSEExd2l0aERTQSkgLS0tCjMwMmMwM"
- **Note:**    
    - This value is set as string whihc will be converted to base64 value and added to keystore file like below,
`echo "${REPOSITORY_KEYSTORE}" | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks`

##### `XL_LICENSE`
- Sets your XL License by passing a base64 string license, which will then be added to the license file. For more details on other options to pass the license in a volume, see [Volumes](./volumes).
- possible values: "license-base64-value"
- default value: unregistered license valid for 7 days but you must use `ACCEPT_EULA`.
- example: "LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogMwpQcm9kdWN0OiOiBUcmlhbAotLS0gU2lnbmF0dXJlIChTSEExd2l0aERTQSkgLS0tCjMwMmMwMjE0MTY5YjUyNGFkYWYwYWRhYmNlZDcyMGM0YmZkMGmVhNTZhNGFiMzk4YTgzNGUyZjJiOWQ1CjI2MzNhHVyZSAtLS0K%"

##### `ACCEPT_EULA`
-"You must accept the End User License Agreement" if you are unable to provide your own license before the container can start.
- possible values: "y" or "Y"
- default value: none

##### `FORCE_UPGRADE`
- Force upgrade setting. It can be used to perform an upgrade in non-interactive mode by passing flag `-force-upgrades` while  starting a service.
- possible values: "true", "false"
- default value: "false"

##### `XL_CLUSTER_MODE`
- This is to specify if the HA setup is needed and to specify the HA mode.
- possible values: "default", "hot-standby", "full"
- default value: "default"

##### `XL_DB_URL`
- This is to set a DB URL that will be used for repository.
- possible values: "url-string-value"
- default value: for XLD `"jdbc:h2:file:${APP_HOME}/repository/xl-deploy"`
                 for XLR `jdbc:h2:file:${APP_HOME}/repository/xl-release`
- example: `jdbc:postgresql://postgresql:5432/XLDATABASENAME`

##### `XL_DB_USERNAME`
- Username used to connect to the database configured with XL products.
- possible values: "user-string-value"
- default value: "sa"
- example: "xl_user"

##### `XL_DB_PASSWORD`
- Password used to connect to database configured with XL products.
- possible values: "password-value"
- default value: "123"
- example: "xl_P@ssw0rd01"

##### `XL_DB_MAX_POOL_SIZE`
- Max size of the main DB pool.
- possible values: any positive number 
- default value: 10
- example: 10

##### `XL_REPORT_DB_URL`
- Sets the value for the URL used to connect to the reporting database.
- possible values: "url-string-value"
- default value: `jdbc:h2:file:${APP_HOME}/repository/xl-release-report`
- example: `jdbc:postgresql://postgresql:5432/xl-release-report`

##### `XL_REPORT_DB_USERNAME`
- Sets the value for the username used to connect to the reporting database.
- possible values: "user-string-value"
- default value: none
- example: "xlr_user"

##### `XL_REPORT_DB_PASSWORD`
- Sets the value for the password used to connect to the reporting database.
- possible values: "password-value"
- default value: none
- example: "rep_P@ssw0rd01"

##### `XL_REPORT_DB_MAX_POOL_SIZE`
- Max size of the report DB pool.
- possible values: any positive number
- default value: 10
- example: 10

##### `XL_METRICS_ENABLED`
- Flag to expose internal and system metrics over Java Management Extensions (JMX). This is to enable the use of monitoring systems that can read JMX data, with XL Products.
- possible values: "true","false"
- default value: "false"

##### `GENERATE_XL_CONFIG`
- Used to generate configuration from environment parameters passed, and volumes mounted with custom changes. If set to false, a default config will be used and all environment variables and volumes added will be ignored.
- possible values: "true","false"
- default value: "true"

##### `USE_IP_AS_HOSTNAME`
- Used to set IP address of the container as the hostname for the instance. If set to true then IP will be used instead of the container ID. This is useful when deploying XL Deploy as active-active cluster using docker compose as Akka cannot resolve aliases within the docker network.
- possible values: "true","false"
- default value: "false"

##### `APP_CONTEXT_ROOT`
- Context root for the application server.
- possible values: any string, it needs to start with /
- default value: /
- example: /release or /deploy

##### `SSL`
- Set to true to enable the HTTP SSL setup for the application server. If it is true you need to set other env variables: HTTP_SSL_KEYSTORE_PATH, HTTP_SSL_KEYSTORE_PASSWORD, HTTP_SSL_KEYSTORE_KEYPASSWORD and HTTP_SSL_KEYSTORE_TYPE.
- possible values: "true","false"
- default value: false
- example: true or false

##### `HTTP_SSL_KEYSTORE_PATH`
- Path in the container where the HTTP SSL keystore will be stored. The keystore will contain the key that will be used for the HTTP SSL traffic. The file needs to be readable by appplication process. The keystore needs to be encoded according to type set in the HTTP_SSL_KEYSTORE_TYPE. The keystore is protected with password set in the HTTP_SSL_KEYSTORE_PASSWORD and key is protected with password set in the HTTP_SSL_KEYSTORE_KEYPASSWORD.
- possible values: absolute path to the keystore file
- default value: none
- example: /opt/xebialabs/xl-release/conf/app-keystore.pkcs12

##### `HTTP_SSL_KEYSTORE_PASSWORD`
- The password that was set for the keystore under path: HTTP_SSL_KEYSTORE_PATH
- possible values: any string
- default value: none

##### `HTTP_SSL_KEYSTORE_KEYPASSWORD`
- The password that was set for the key in the keystore under path: HTTP_SSL_KEYSTORE_PATH
- possible values: any string
- default value: none

##### `HTTP_SSL_KEYSTORE_TYPE`
- Type of the keystore file.
- possible values: pkcs12 or jks
- default value: pkcs12

##### `NETWORK_ADDRESS_CACHE_TTL`
- The Java-level namelookup cache policy for successful lookups: any negative value: caching forever; any positive value: the number of seconds to cache an address for; zero: do not cache
- possible values: any integer
- default value: 30

### Specific for XLRelease docker images:-

##### `APP_PORT`
- HTTP Port of the master
- possible values: 5516
- default value: 5516

##### `SERVER_URL`
- This is used for setting a custom server URL instead of a hostname where XL Products are installed. This can be useful in email notifications where you need users to connect directly to URLs such as a reverse proxy.
- possible values: "url-string-value"
- default value: `http://localhost:5516/`
- example `http://xl-release.company.com`

##### `ENABLE_EMBEDDED_QUEUE`
- Flag to expose external messaging queue. If set to true, a default embedded-queue will be used and all environment variables will be ignored.
- possible values: "true", "false"
- default value: "true"

##### `XLR_TASK_QUEUE_NAME`
- Name for MQ task queue.
- possible values: "name-string-value"
- default value: "xlr-tasks-queue"
- example: "xlrelease-tasks_q"

##### `XLR_TASK_QUEUE_URL`
- MQ task queue URL to specify either the IP or the hostname.
- possible values: "ip-address/hostname"
- default value: none
- example: http://xl-release.company.com

##### `XLR_TASK_QUEUE_USERNAME`
- MQ task queue username.
- possible values: "user-string-value"
- default value: none
- example: "xlr_user"

##### `XLR_TASK_QUEUE_PASSWORD`
- MQ task queue password.
- possible values: "password-value"
- default value: none
- example: "MQ_P@ssw0rd01"

##### `XDG_CONFIG_HOME`
- Config home directory required by jgit library.
- possible values: "container-directory-with-write-permissions-for-jgit-lib"
- default value: "/tmp/jgit"

### Specific for XLDeploy docker images:-

##### `APP_PORT`
- HTTP Port of the master 
- possible values: 4516
- default value: 4516
  
##### `XLD_IN_PROCESS`
- Used to control whether the internal in-process worker should be used or not. If you need to use external workers then this needs to be set to false.
- possible values: "true", "false"
- default value: "true"

##### `XLD_TASK_QUEUE_NAME`
- Name for MQ task queue.
- possible values: "name-string-value"
- default value: "xld-tasks-queue"
- example: "xldeploy-tasks_q"

##### `XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE`
- Sets the value for the maximum disk usage for an internal worker.
- possible values: "max-number-value"
- default value: "100"
- example "150"

##### `XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT`
- Sets the value for the shutdown time out for an internal worker.
- possible values: "timeout-number-value"
- default value: "60000"
- example "80000"

##### `XLD_TASK_QUEUE_DRIVER_CLASS_NAME`
- Used to set MQ Provider configurations which copy the required drivers to the lib folder.
- possible values: "rabbitmq", "activemq"
- default value: none

##### `XLD_TASK_QUEUE_URL`
- MQ task queue URL to specify either the IP or the hostname.
- possible values: "ip/hostname-value"
- default value: none
- example: `http://xl-deploy.company.com`

##### `XLD_TASK_QUEUE_USERNAME`
- MQ task queue username.
- possible values: "user-string-value"
- default value: none
- example: "xld_user"

##### `XLD_TASK_QUEUE_PASSWORD`
- MQ task queue password.
- possible values: "password-value"
- default value: none
- example: "MQ_P@ssw0rd01"

##### `HOSTNAME_SUFFIX`
- Adds a string suffix to your XLDeploy hostname to which external Workers will connect to a master in a `master-worker` setup.
- possible values: "suffix-string-value"
- default value: none
- example: "xldmaster01"

##### `USE_EXTERNAL_CENTRAL_CONFIG`
- Flag to disable the embedded config server and use external config server. If "true", the embedded config server will be used and the external config server denoted by the "CENTRAL_CONFIG_URL" variable will be used
- possible values: "true,false"
- default value: "false"

##### `CENTRAL_CONFIG_URL`
- URL of the external central config server
- possible values: "valid URL"
- default value: ""
- example: "http://localhost:8888/centralConfiguration"

##### `USE_CACHE`
- Flag to disable/enable the use of application cache
- possible values: "true,false"
- default value: "false"

##### `OVERRIDE_HOSTNAME`
- Override HOSTNAME by this value. If the HOSTNAME_SUFFIX is not set in that case only this value will be used to generate the full hostname of the container.
- possible value: "test.com"
- no default value

##### `SERVER_PORT`
- Canonical port for the Akka remoting in the master-worker communication. 
- possible value: 8180
- default value: 8180

##### `CLUSTER_NODE_HOSTNAME_SUFFIX`
- Adds a string suffix to your master hostname to which other masters will connect in the cluster remoting setup.
- possible value: ".test.com"
- no default value

##### `CLUSTER_NODE_PORT`
- Canonical port for the Akka remoting that will be used in the cluster remoting setup.
- possible value: 25520
- default value: 25520

