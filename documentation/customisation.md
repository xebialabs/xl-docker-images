# Dockerfile Customisation

A custom Docker file might be required in certain circumstances. These include (but aren't limited to)

- Connecting to a properietary database (DB2, Oracle, etc.)
- Adding a hotfix as instructed by our support team
- Adding a custom plugin
- etc.

The process to customise a docker image for your needs is described below

## XL Deploy

When creating a Dockerfile with custom resources added, always remember that the owning user:group combination _must_ be `10001:0`, or else XL Deploy will not be able to read the files. 

To start off with, create a `Dockerfile` that resembles the following. 

Please note that certain JARS will go into certain paths. You shouldn't add a Oracle JAR to the `ext/` folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team. 

NOTE: `${APP_HOME}` points to the path `/opt/xebialabs/xl-deploy-server` by default

```docker
FROM xebialabs/xl-deploy:9.5.0

###################################################################################
# PLUGINS                                                                         #
# Plugins should be placed under ${APP_HOME}/default-plugins/ #
###################################################################################

COPY --chown=10001:0 files/xld-liquibase-plugin-5.0.1.xldp /opt/xebialabs/xl-deploy-server/default-plugins/

# Add plugin from url
ADD --chown=10001:0 https://dist.xebialabs.com/public/community/xl-deploy/command2-plugin/3.9.1-1/command2-plugin-3.9.1-1.jar /opt/xebialabs/xl-deploy-server/default-plugins/

##########################################################################
# EXTENSIONS                                                             #
# Extensions should be placed under ${APP_HOME}/ext
##########################################################################
ADD --chown=10001:0 files/ext /opt/xebialabs/xl-deploy-server/ext/

##########################################################################
# HOTFIXES                                                               #
##########################################################################
ADD --chown=10001:0 files/lib-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/lib/

##########################################################################
# LIBRARIES                                                              #
##########################################################################
ADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-deploy-server/lib/
```

For an overview of how `ADD` and `COPY` works, please refer to [the documentation](https://docs.docker.com/engine/reference/builder/#add)

Once you are satisfied with your Dockerfile, run the following command in the same directory

`docker build -t xl-deploy-custom:9.5.0 .`

Always use [semver](https://semver.org/) to version your docker images. This is to ensure future compatability with one of our other tools, `xl up`.

This command will build and tag a docker image for you. If you would like to run this image locally, you can do this now by running

`docker run -it --rm -p 4601:4601 -e ACCEPT_EULA=Y xl-deploy-custom:9.5.0`

If you would like to host this elsewhere, you have two options

1. (Recommended) [Push this image to a docker registry](https://docs.docker.com/engine/reference/commandline/push/) of your choice. You can either [set up your own registry](https://docs.docker.com/registry/), or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run
  - `docker tag xl-deploy-custom:9.5.0 yourdockerhuborg/xl-deploy-custom:9.5.0`
  - `docker push yourdockerhuborg/xl-deploy-custom:9.5.0`
  - (On the node you would like to run the container) `docker run -it --rm -p 4601:4601 -e ACCEPT_EULA=Y yourdockerhuborg/xl-deploy-custom:9.5.0`
2. By using [`docker export`](https://docs.docker.com/engine/reference/commandline/export/) and [`docker load`](https://docs.docker.com/engine/reference/commandline/load/). This is not a recommended approach as it requires you to move a tar file between different machines. 


## XL Release

As with XL Deploy, always remember that the owning user:group combination _must_ be `10001:0` for any files you add.

To start off with, create a `Dockerfile` that resembles the following. 

Please note that certain JARS will go into certain paths. You shouldn't add a Oracle JAR to the `ext/` folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team. 

NOTE: `${APP_HOME}` points to the path `/opt/xebialabs/xl-deploy-server` by default

```docker
FROM xebialabs/xl-release:9.5.0

###################################################################################
# PLUGINS                                                                         #
# Plugins should be placed under ${APP_HOME}/default-plugins/ #
###################################################################################

COPY --chown=10001:0 files/xld-liquibase-plugin-5.0.1.xldp /opt/xebialabs/xl-release-server/default-plugins/xlr-official/

# Add plugin from url
ADD --chown=10001:0 https://dist.xebialabs.com/public/community/xl-deploy/command2-plugin/3.9.1-1/command2-plugin-3.9.1-1.jar /opt/xebialabs/xl-release-server/default-plugins/__local__/

##########################################################################
# EXTENSIONS                                                             #
# Extensions should be placed under ${APP_HOME}/ext
##########################################################################
ADD --chown=10001:0 files/ext /opt/xebialabs/xl-release-server/ext/

##########################################################################
# HOTFIXES                                                               #
##########################################################################
ADD --chown=10001:0 files/lib-hotfix.jar /opt/xebialabs/xl-release-server/hotfix/lib/

##########################################################################
# LIBRARIES                                                              #
##########################################################################
ADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-release-server/lib/
```

NOTE: For XL Release plugins, official plugins should go to the `default-plugins/xlr-official/` folder, while custom or community plugins should go under `default-plugins/__local__/`

For an overview of how `ADD` and `COPY` works, please refer to [the documentation](https://docs.docker.com/engine/reference/builder/#add)

Once you are satisfied with your Dockerfile, run the following command in the same directory

`docker build -t xl-release-custom:9.5.0 .`

Always use [semver](https://semver.org/) to version your docker images. This is to ensure future compatability with one of our other tools, `xl up`.

This command will build and tag a docker image for you. If you would like to run this image locally, you can do this now by running

`docker run -it --rm -p 5601:5601 -e ACCEPT_EULA=Y xl-release-custom:9.5.0`

If you would like to host this elsewhere, you have two options

1. (Recommended) [Push this image to a docker registry](https://docs.docker.com/engine/reference/commandline/push/) of your choice. You can either [set up your own registry](https://docs.docker.com/registry/), or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run
  - `docker tag xl-release-custom:9.5.0 yourdockerhuborg/xl-release-custom:9.5.0`
  - `docker push yourdockerhuborg/xl-release-custom:9.5.0`
  - (On the node you would like to run the container) `docker run -it --rm -p 5601:5601 -e ACCEPT_EULA=Y yourdockerhuborg/xl-release-custom:9.5.0`
2. By using [`docker export`](https://docs.docker.com/engine/reference/commandline/export/) and [`docker load`](https://docs.docker.com/engine/reference/commandline/load/). This is not a recommended approach as it requires you to move a tar file between different machines. 


