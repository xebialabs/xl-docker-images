# Working with Volumes

The below are the volumes that can be mounted for XL products and the reason to use them

## XL Deploy

The env variables `APP_ROOT` ponts to `/opt/xebialabs` and `APP_HOME` point to  `/${APP_ROOT}/xl-deploy-server` by default, there is no need to change them usually.

The following locations can be mounted as volumes to provide either configuration data, and/or persistent storage for application data.

**${APP_HOME}/conf** - This directory contains the configuration files and keystores for XL Deploy. If mounted it is possible to configure (and inject) non-default configuration settings. Some configurations in `xl-deploy.conf` file are always overwritten by the container startup script based on env variables set, to avoid that you can set the `GENERATE_XL_CONFIG` env variable to `false`. Once you set this the `xl-deploy.conf` for the product will not be generated and you would have to provide this yourself.

**${APP_HOME}/hotfix/lib** - This directory contains the hotfixes for the libraries used by XL Deploy. When instructed by XebiaLabs support personnel, you should drop any delivered hotfixes in here.

**${APP_HOME}/hotfix/plugins** - This directory contains the hotfixes for the plugins used by XL Deploy. When instructed by XebiaLabs support personnel, you should drop any delivered plugin hotfixes in here.

**${APP_HOME}/ext** - This directory contains the developed (exploded plugins) for XL Deploy. You can customize an existing plugin here, for example you can modify the `synthetic.xml` for a specific plugin here.

**${APP_HOME}/plugins** - This directory contains the plugins that are running in XL Deploy. When mounted only plugins present in this directory will be loaded and you need to ensure to provide all required base plugins here. If you mount an empty directory the default bundled plugins will be loaded.

**${APP_HOME}/repository** - This directory contains the embedded repository database for XL Deploy. Using the configuration injected through the ${APP_HOME}/conf volume, it is possible to configure the used database to a remotely running database engine, instead of using the embedded memory based one. It is highly recommended not to use the embedded DB for production setup.

**${APP_HOME}/export** - This directory holds the exported CIs when using the CI export option in XL Deploy

**${APP_HOME}/work** - This directory will be used to save task data, task recovery files, uploaded files and temp files in XL Deploy. The task recovery files can be used in cases on container restarts if mounted externally to recover tasks.

Here is an example of mounting volumes for XL Deploy with docker compose.

```yaml
version: "2"
services:
  xl-deploy:
    image: xebialabs/xl-deploy:9.5.0
    container_name: xl-deploy
    ports:
     - "4516:4516"
    volumes:
     - ~/XebiaLabs/xl-deploy-server/conf:/opt/xebialabs/xl-deploy-server/conf
     - ~/XebiaLabs/xl-deploy-server/hotfix/lib:/opt/xebialabs/xl-deploy-server/hotfix/lib
     - ~/XebiaLabs/xl-deploy-server/hotfix/plugins:/opt/xebialabs/xl-deploy-server/hotfix/plugins
     - ~/XebiaLabs/xl-deploy-server/ext:/opt/xebialabs/xl-deploy-server/ext
     - ~/XebiaLabs/xl-deploy-server/plugins:/opt/xebialabs/xl-deploy-server/plugins
     - ~/XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/repository
     - ~/XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/export
     - ~/XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/work
    environment:
     - ADMIN_PASSWORD=admin
     - GENERATE_XL_CONFIG=false
     - ACCEPT_EULA=Y
```

## XL Release

The env variables `APP_ROOT` ponts to `/opt/xebialabs` and `APP_HOME` point to `/${APP_ROOT}/xl-release-server` by default, there is no need to change them usually.

The following locations can be mounted as volumes to provide either configuration data, and/or persistent storage for application data.

**${APP_HOME}/conf** - This directory contains the configuration files and keystores for XL Release. If mounted it is possible to configure (and inject) non-default configuration settings. Some configurations in `xl-release.conf` file are always overwritten by the container startup script based on env variables set, to avoid that you can set the `GENERATE_XL_CONFIG` env variable to `false`. Once you set this the `xl-release.conf` for the product will not be generated and you would have to provide this yourself.

**${APP_HOME}/hotfix** - This directory contains the hotfixes for the libraries & plugins used by XL Release. When instructed by XebiaLabs support personnel, you should drop any delivered hotfixes in here.

**${APP_HOME}/ext** - This directory contains the developed (exploded plugins) for XL Release. You can customize an existing plugin here, for example you can modify the `synthetic.xml` for a specific plugin here.

**${APP_HOME}/plugins** - This directory contains the plugins that are running in XL Release. When mounted only plugins present in this directory will be loaded and you need to ensure to provide all required base plugins here. If you mount an empty directory the default bundled plugins will be loaded.

**${APP_HOME}/repository** - This directory contains the embedded repository database for XL Release. Using the configuration injected through the ${APP_HOME}/conf volume, it is possible to configure the used database to a remotely running database engine, instead of using the embedded memory base one. It is highly recommended not to use the embedded DB for production setup.

**${APP_HOME}/archive** - This directory contains the embedded archive database for XL Release. Using the configuration injected through the ${APP_HOME}/conf volume, it is possible to configure the used database to a remotely running database engine, instead of using the embedded memory base one. It is highly recommended not to use the embedded DB for production setup.

**${APP_HOME}/reports** - The report files generated from XL Release are stored in this folder.

Here is an example of mounting volumes for XL Release with docker compose.

```yaml
version: "2"
services:
  xl-release:
    image: xebialabs/xl-release:9.5.0
    container_name: xl-release
    ports:
     - "5516:5516"
    links:
     - xl-deploy
    volumes:
     - ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf
     - ~/XebiaLabs/xl-release-server/hotfix/:/opt/xebialabs/xl-release-server/hotfix/
     - ~/XebiaLabs/xl-release-server/ext:/opt/xebialabs/xl-release-server/ext
     - ~/XebiaLabs/xl-release-server/plugins:/opt/xebialabs/xl-release-server/plugins
     - ~/XebiaLabs/xl-release-server/repository:/opt/xebialabs/xl-release-server/repository
     - ~/XebiaLabs/xl-release-server/archive:/opt/xebialabs/xl-release-server/archive
     - ~/XebiaLabs/xl-release-server/archive:/opt/xebialabs/xl-release-server/reports
    environment:
     - ADMIN_PASSWORD=admin
     - GENERATE_XL_CONFIG=false
     - ACCEPT_EULA=Y
```