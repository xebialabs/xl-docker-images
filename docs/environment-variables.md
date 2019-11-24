## ENVIRONMENT VARIABLES
#### The following environment variables can be set to configure XL Docker image for different scenarios

### Common for all XL Products docker images,

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
- Note: 
    - Keystore password must be at least 6 characters.

##### `REPOSITORY_KEYSTORE`
- Repository keystore used in XL Products.
- possible values: "keystore-string-value"
- default value: content of `${APP_HOME}/conf/repository-keystore.jceks` which is generated from `keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}`
- example: "b3J0IHBvbGljeTogMSBtb250aCBvZiB0ZWNobmljYWwgc3VwcG9ydApFZGl0aW9uOiBUcmlhbAotLS0gU2lnbmF0dXJlIChTSEExd2l0aERTQSkgLS0tCjMwMmMwM"
- Note:    
    - This value is set as string whihc will be converted to base64 value and added to keystore file like below,
`echo "${REPOSITORY_KEYSTORE}" | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks`

##### `XL_LICENSE`
- Sets your XL License by passing base64 string license .. which will be added to license file .. other options to pass it as volume check Volumes docs for more details.
- possible values: "license-base64-value"
- default value: unregistered license valid for 7 days but you must use `ACCEPT_EULA`.
- example: "LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogMwpQcm9kdWN0OiOiBUcmlhbAotLS0gU2lnbmF0dXJlIChTSEExd2l0aERTQSkgLS0tCjMwMmMwMjE0MTY5YjUyNGFkYWYwYWRhYmNlZDcyMGM0YmZkMGmVhNTZhNGFiMzk4YTgzNGUyZjJiOWQ1CjI2MzNhHVyZSAtLS0K%"

##### `ACCEPT_EULA`
- This is needed "you must accept the End User License Agreement" if you will not provide your own license before container can start.
- possible values: "y" or "Y"
- default value: none

##### `FORCE_UPGRADE_FLAG`
- Force upgrade setting. In case of upgrade it will be performed in non-interactive mode by setting flag to "-force-upgrades"
- possible values: "true", "false" 
- default value: "false" 

##### `XL_CLUSTER_MODE`
- This is to specify if HA setup needed and specify which mode.
- possible values: "default", "hot-standby", "full"
- default value: "default"
    
##### `XL_DB_URL`
- This is to set DB url that will be used for repository.
- possible values: "url-string-value"
- default value: for XLD `"jdbc:h2:file:${APP_HOME}/repository/xl-deploy"` 
                 for XLR `jdbc:h2:file:${APP_HOME}/repository/xl-release`
- example: `jdbc:postgresql://postgresql:5432/XLDATABASENAME`

##### `XL_DB_USERNAME`
- Username used to connect to DataBase configured with XL products.
- possible values: "user-string-value"
- default value: "sa"
- example: "xl_user"

##### `XL_DB_PASSWORD`
- Password used to connect to DataBase configured with XL products.
- possible values: "password-value"
- default value: "123"
- example: "xl_P@ssw0rd01"

##### `XL_METRICS_ENABLED`
- Flag to exposes internal and system metrics over Java Management Extensions (JMX). so that any monitoring system that can read JMX data can be used to monitor XL Product.
- possible values: "true","false"
- default value: "false"
    
##### `GENERATE_XL_CONFIG`
- Used to generate configuration from environment parameters passed and volumes mounted with custom changes .. if set to false then it default conf will be used ignoring all env variables and volumes added.
- possible values: "true","false"
- default value: "true" 

### Specific for XLRelease docker images:-

##### `SERVER_URL`
- This is used for Setting a custom server URL instead of using hostname where XL Products is installed .. this can be useful in email notifications where you need useres to connect directly to url such as reverse proxy.
- possible values: "url-string-value"
- default value: `http://localhost:5516/`
- example "http://xl-release.company.com"
 
##### `XL_REPORT_DB_URL`
- sets value for URL used to connect to reporting database.
- possible values: "url-string-value"
- default value: `jdbc:h2:file:${APP_HOME}/repository/xl-release-report`
- example: `jdbc:postgresql://postgresql:5432/xl-release-report`

##### `XL_REPORT_DB_USERNAME`
- sets value for username used to connect to reporting database.
- possible values: "user-string-value"
- default value: none
- example: "xlr_user"

##### `XL_REPORT_DB_PASSWORD`
- sets value for password used to connect to reporting database.
- possible values: "password-value"
- default value: none
- example: "rep_P@ssw0rd01"

### Specific for XLDeploy docker images:-

##### `XLD_IN_PROCESS`
- Used to control if internal in-process worker will be used or not .. if you need to use external workers then this need to be set to false.
- possible values: "true", "false"
- default value: "true"

##### `XLD_TASK_QUEUE_NAME`
- Name for MQ task queue.
- possible values: "name-string-value"
- default value: "xld-tasks-queue"
- example: "xldeploy-tasks_q"

##### `XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE`
- sets value for maximum disk usage for internal worker.
- possible values: "max-number-value"
- default value: "100"
- example "150"

##### `XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT`
- sets value for shutdown time out for internal worker.
- possible values: "timeout-number-value"
- default value: "60000"
- example "80000"

##### `XLD_TASK_QUEUE_DRIVER_CLASS_NAME`
- Used to set MQ Provider configurations which copy required drivers to lib folder.
- possible values: "rabbitmq", "activemq"
- default value: none

##### `XLD_TASK_QUEUE_URL`
- MQ task queue URL either ip or hostname.
- possible values: "ip/hostname-value"
- default value: none
- example: "xl-deploy.company.com"

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
- Adds string suffix to your XLDeploy hostname in which external Workers will use to connect to master when having master-worker setup.
- possible values: "suffix-string-value"
- default value: none
- example: "xldmaster01"


### Examples:-	

###### If you do not have a license:	
	
```
$ docker run -e "ADMIN_PASSWORD=admin_password" -e "ACCEPT_EULA=Y" -p 4516:4516 --name xld xebialabs/xl-release:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Note that by running this command, you are accepting the End User License Agreement.


###### If you have a license:	

```
docker run -e "ADMIN_PASSWORD=admin_password" -e "XL_LICENSE=license_base64_string" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Set XL_LICENSE to the Base64-encoded license string.


###### providing Repository DB details:	
```
$ docker run -e "ADMIN_PASSWORD=admin_password" -e "ACCEPT_EULA=Y" -e "XL_DB_USERNAME=db_user" -e "XL_DB_PASSWORD=db_pass" -e "XL_DB_URL=jdbc:postgresql://postgresql:5432/xl-deploy-db" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user, XL_DB_USERNAME to DB username, XL_DB_PASSWORD to  DB Password and XL_DB_URL to url used to connect to DB.