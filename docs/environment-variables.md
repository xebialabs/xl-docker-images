## ENVIRONMENT VARIABLES
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
- Sets your XL License by passing a base64 string license, which will then be added to the license file. For more details on other options to pass the license in a volume, see [Volumes](##).
- possible values: "license-base64-value"
- default value: unregistered license valid for 7 days but you must use `ACCEPT_EULA`.
- example: "LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogMwpQcm9kdWN0OiOiBUcmlhbAotLS0gU2lnbmF0dXJlIChTSEExd2l0aERTQSkgLS0tCjMwMmMwMjE0MTY5YjUyNGFkYWYwYWRhYmNlZDcyMGM0YmZkMGmVhNTZhNGFiMzk4YTgzNGUyZjJiOWQ1CjI2MzNhHVyZSAtLS0K%"

##### `ACCEPT_EULA`
-"You must accept the End User License Agreement" if are unable to provide your own license before container can start.
- possible values: "y" or "Y"
- default value: none

##### `FORCE_UPGRADE`
- Force upgrade setting. It can be used to perform an upgrade in non-interactive mode by passing flag `-force-upgrades` while  starting a service.
- possible values: "true", "false"
- default value: "false"

##### `XL_CLUSTER_MODE`
- This is to specify if HA setup is needed and specify modes of setup.
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

##### `XL_METRICS_ENABLED`
- Flag to expose internal and system metrics over Java Management Extensions (JMX). This is to enable the use of a monitoring systems that can read JMX data, with XL Products.
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

### Specific for XLRelease docker images:-

##### `SERVER_URL`
- This is used for setting a custom server URL instead of a hostname where XL Products are installed. This can be useful in email notifications where you need users to connect directly to URLs such as a reverse proxy.
- possible values: "url-string-value"
- default value: `http://localhost:5516/`
- example `http://xl-release.company.com`

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

### Specific for XLDeploy docker images:-

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
