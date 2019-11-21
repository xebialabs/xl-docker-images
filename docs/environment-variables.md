## ENVIRONMENT VARIABLES
#### The following environment variables can be set to configure XL Docker image for different scenarios

### Common for all XL Products docker images,

##### `ADMIN_PASSWORD`
- possible values: "password-value"
- Admin user password used in XL Products
- Note: 
    - If this value is not passed a random 8 characters password will be generated

##### `REPOSITORY_KEYSTORE_PASSPHRASE`
- possible values: "passphrase-string" 
- Repository keystore passphrase used in XL Products .. If this value is not passed a random 16 characters password will be generated
- Note: 
    - Keystore password must be at least 6 characters

##### `REPOSITORY_KEYSTORE`
- possible values: "keystore-string"
- Repository keystore used in XL Products
- Note:    
    - If this value is set then it will be converted to base64 value and added to keystore file like below,
echo "${REPOSITORY_KEYSTORE}" | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks
    - If this value is not set then new one will be created using keystore passphrase like below,
keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

##### `XL_LICENSE`
- possible values: "base64-license-string"
- Sets your XL License by passing base64 string license .. which will be added to license file .. other options to pass it as volume check Volumes docs for more details.

#####Example:
```
docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "XL_LICENSE=Base64-license-string" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Set XL_LICENSE to the Base64-encoded license string.

##### `ACCEPT_EULA`
- possible values: "y" or "Y"
- This is needed "you must accept the End User License Agreement" if you will not provide your own license before container can start.

#####Example:
```
$ docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "ACCEPT_EULA=Y" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Note that by running this command, you are accepting the End User License Agreement.

##### `FORCE_UPGRADE_FLAG`
- possible values: "true", "false" 
- default value: "false" 
- Force upgrade setting. In case of upgrade it will be performed in non-interactive mode by setting flag to "-force-upgrades"

##### `XL_CLUSTER_MODE`
- possible values: "default", "hot-standby", "full"
- default value: "default"
- This is to specify if HA setup needed and specify which mode.
    
##### `XL_DB_URL`
- possible values: "jdbc:h2:file:/opt/xldeploy/server/repository/xl-deploy"
- This is to set DB url that will be used for repository.

##### `XL_DB_USERNAME`
- possible values: "user-name"
- Username used to connect to DataBase configured with XL products.

##### `XL_DB_PASSWORD`
- possible values: "password-value"
- Password used to connect to DataBase configured with XL products.

#####Example:
```
$ docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "ACCEPT_EULA=Y" -e "XL_DB_USERNAME=user" -e "XL_DB_PASSWORD=pass" -e "XL_DB_URL=jdbc:db2:file:/opt/xebialabs/xl-deploy-server/repository/xl-deploy" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user, XL_DB_USERNAME to DB username, XL_DB_PASSWORD to  DB Password and XL_DB_URL to url used to connect to DB.

##### `XL_METRICS_ENABLED`
- possible values: "true","false"
- default value: "false"
- Flag to exposes internal and system metrics over Java Management Extensions (JMX). so that any monitoring system that can read JMX data can be used to monitor XL Product.
    
##### `GENERATE_XL_CONFIG`
- possible values: "true","false"
- default value: "true"  
- Used to generate configuration from environment parameters passed and volumes mounted with custom changes .. if set to false then it default conf will be used ignoring all env variables and volumes added.

###Specific for XLRelease docker images:-

##### `SERVER_URL`
- possible values: "http://xl-release.company.com"
- This is used for Setting a custom server URL instead of using hostname where XL Products is installed .. this can be useful in email notifications where you need useres to connect directly to url such as reverse proxy.
    
##### `XL_REPORT_DB_URL`
- possible values: "jdbc:h2:file:/opt/xlrelease/server/repository/xl-release-report"
- sets value for URL used to connect to reporting database

##### `XL_REPORT_DB_USERNAME`
- possible values: "user-name"
- sets value for username used to connect to reporting database
    
##### `XL_REPORT_DB_PASSWORD`
- possible values: "password-value"
- sets value for password used to connect to reporting database


### Specific for XLDeploy docker images:-

##### `XLD_IN_PROCESS`
- possible values: "true", "false"
- default value: "true"
- Used to control if internal in-process worker will be used or not .. if you need to use external workers then this need to be set to false

##### `XLD_TASK_QUEUE_NAME`
- possible values: "queue-name"
- Name for MQ task queue

##### `XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE`
- possible values: "100"
- sets value for maximum disk usage for internal worker

##### `XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT`
- possible values: "60000"
- sets value for shutdown time out for internal worker

##### `XLD_TASK_QUEUE_DRIVER_CLASS_NAME`
- possible values: "rabbitmq", "activemq"
- Used to set MQ Provider configurations which copy required drivers to lib folder

##### `XLD_TASK_QUEUE_URL`
- possible values: "ip/hostname"
- MQ task queue URL either ip or hostname

##### `XLD_TASK_QUEUE_USERNAME`
- possible values: "user-name"
- MQ task queue username

##### `XLD_TASK_QUEUE_PASSWORD`
- possible values: "password-value"
- MQ task queue password

##### `HOSTNAME_SUFFIX`
- value: "string"
- Adds any string suffix to your XLDeploy hostname in which external Workers will use to connect to master when having master-worker setup.