## ENVIRONMENT VARIABLES
#### The following environment variables can be set to configure XL Docker image for different scenarios

### Common for all XL Products docker images,

##### `APP_ROOT   ????`
- value: "/opt/xebialabs"
- Note: 
    - not valid anymore as APP_ROOT is set to /opt/xebialabs .. however in db-drivers.sh if you set APP_ROOT to different path it will take affect but then scrib will be broken and will fail with below,
cp: cannot stat '/opt//db-libs/h2*': No such file or directory
and this will cause docker container to stop as DB libs can not be found.


##### `APP_HOME  ????`
- value: "/${APP_ROOT}/xl-deploy-server"
- Note: 
    - not valid anymore as APP_HOME is set to ${APP_ROOT}/{{ product }}-server .. if we tried to pass it as env docker container start will fail with below,
/opt/xebialabs/xl-deploy-server/bin/run-in-container.sh: line 136: cd: /opt/default-plugins: No such file or directory

##### `ADMIN_PASSWORD`
- value: "password-value"
- Admin user password used in XL Products
- Note: 
    - If this value is not passed a random 8 characters password will be generated using "pwgen 8"

##### `REPOSITORY_KEYSTORE_PASSPHRASE`
value: "passphrase-string" 
Repository keystore passphrase used in XL Products
If this value is not passed a random 16 characters password will be generated using "pwgen 8"
Note: 
    - Keystore password must be at least 6 characters

##### `REPOSITORY_KEYSTORE`
- value: "keystore-string"
- Repository keystore passphrase used in XL Products
- Note:    
    - If this value is set then it will be converted to base64 value and added to keystore file like below,
echo "${REPOSITORY_KEYSTORE}" | base64 -d > ${APP_HOME}/conf/repository-keystore.jceks
    - If this value is not set then new one will be created using keystore passphrase like below,
keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

##### `XL_LICENSE`
- value: "license-string"
- License if you want to explicitly provide it .. which will be added to license file.
other option is to add license file directly to below path 
${APP_HOME}/conf/xl-release-license.lic for XLRelease or ${APP_HOME}/conf/deployit-license.lic for XLDeploy

##### `XL_LICENSE_KIND   ????`
- value: "byol"
- Bring your owen license .. if set then no request for trial license will be issued.
- Note: 
    - Something wrong here as even if this is set you still need to accept ACCEPT_EULA .. however as far as i understand it should not ask for trial license.

##### `XL_NO_UNREGISTERED_LICENSE  ????`
- value: "yes"
- If passed then this will request unregistered license in which a call will be done to XebiaLabs license server to get a license and add it to license file. 
- Note: 
    - something wrong here as even if this is set you still asked to enter trial license as far as i understand it should not be the case.

##### `ACCEPT_EULA`
- value: "y" or "Y"
- This is needed "you must accept the End User License Agreement" if you didnot provide your own license before container can start and you are going to get Unregistered License.

##### `FORCE_UPGRADE_FLAG`
- value: "true"
- Force upgrade setting. In case of upgrade it will be performed in non-interactive mode by setting flag to "-force-upgrades"

##### `XL_CLUSTER_MODE`
- value: "default", "hot-standby", "full"
- This is to specify if HA setup needed amd speciy which mode.
    
##### `XL_DB_URL`
- value: "jdbc:h2:file:/opt/xldeploy/server/repository/xl-deploy"
- This is to set DB url that will be used for repository, it also control which driver "XL_DB_DRIVER" will be used based on DB type .. supported db types are 'h2', 'oracle', 'mysql', 'postgresql', 'sqlserver', 'db2'     
- Note: 
    - oracle jdbc driver is not provided by default in the classpath, please make sure you provide one and it will be added to ${APP_HOME}/lib

##### `XL_DB_USERNAME`
- value: "user-name"
- Username used to connect to DataBase configured with XL products.

##### `XL_DB_PASSWORD`
- value: "password-value"
- Password used to connect to DataBase configured with XL products.
    
##### `XL_METRICS_ENABLED`
- value: "false"
- Flag to exposes internal and system metrics over Java Management Extensions (JMX). so that any monitoring system that can read JMX data can be used to monitor XL Product.
    
##### `GENERATE_XL_CONFIG`
- value: "true"  
- Used to generate configuration files from environment parameters passed.


###Specific for XLRelease docker images:-

##### `SERVER_URL`
- value: "http://xl-release.company.com"
- This is used for Setting a custom server URL instead of using hostname where XL Products is installed .. this can be useful in email notifications where you need useres to connect directly to url such as reverse proxy.
    
##### `XL_REPORT_DB_URL`
- value: "jdbc:h2:file:/opt/xlrelease/server/repository/xl-release-report"
- sets value for URL used to connect to reporting database

##### `XL_REPORT_DB_USERNAME`
- value: "user-name"
- sets value for username used to connect to reporting database
    
##### `XL_REPORT_DB_PASSWORD`
- value: "password-value"
- sets value for password used to connect to reporting database


### Specific for XLDeploy docker images:-

##### `XLD_IN_PROCESS`
- value: "true", "false"
- Used to control if internal in-process worker will be used or not .. if you need to use external workers then this need  to be set to false

##### `XLD_TASK_QUEUE_NAME`
- value: "queue-name"
- Name for MQ task queue

##### `XLD_TASK_QUEUE_IN_PROCESS_MAX_DISK_USAGE`
- value: "100"
- sets value for maximum disk usage for internal worker

##### `XLD_TASK_QUEUE_IN_PROCESS_SHUTDOWN_TIMEOUT`
- value: "60000"
- sets value for shutdown time out for internal worker

##### `XLD_TASK_QUEUE_DRIVER_CLASS_NAME`
- value: "rabbitmq", "activemq"
- Used to set MQ Provider configurations which copy required drivers to lib folder

##### `XLD_TASK_QUEUE_URL`
- value: "ip/hostname"
- MQ task queue URL either ip or hostname

##### `XLD_TASK_QUEUE_USERNAME`
- value: "user-name"
- MQ task queue username

##### `XLD_TASK_QUEUE_PASSWORD`
- value: "password-value"
- MQ task queue password

##### `HOSTNAME_SUFFIX`
- value: "company.com"
- Sets domain name which can be used to set server hostname

### Examples:-

#### Licensing
##### If you do not have a license:
```
$ docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "ACCEPT_EULA=Y" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Note that by running this command, you are accepting the End User License Agreement.

###### If you have a license:
```
$ docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "XL_LICENSE=license-string" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```
Set ADMIN_PASSWORD to the desired password for the admin user. Set XL_LICENSE to the Base64-encoded license string.

#### Example of providing Repository DB details:
```
$ docker run -e "ADMIN_PASSWORD=desired-admin-password" -e "ACCEPT_EULA=Y" -e "XL_DB_USERNAME=user" -e "XL_DB_PASSWORD=pass" -e "XL_DB_URL=jdbc:db2:file:/opt/xebialabs/xl-deploy-server/repository/xl-deploy" -p 4516:4516 --name xld xebialabs/xl-deploy:9.0
```