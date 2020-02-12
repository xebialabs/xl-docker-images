# Dockerfile customization

It is likely, that you might need to customize your Docker file for certain purposes which include but aren't limited to:

- Connecting to a proprietary database (DB2, Oracle, etc.)
- Adding a hotfix as instructed by our support team
- Adding a custom plugin


You can customize a docker image for your needs as described in the process below.

## XL Deploy

**Important:** When you create a Dockerfile with custom resources added, always remember that the owning user:group combination _must_ be `10001:0`, or else, XL Deploy will not be able to read the files.

**Note:** Certain JARS should be placed in specific paths only. You shouldn't add a Oracle JAR to the `ext/` folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team.

**Note:** `${APP_HOME}` points to the path `/opt/xebialabs/xl-deploy-server` by default

To begin, create a `Dockerfile` that resembles the following configuration:

```
docker
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
ADD --chown=10001:0 files/plugin-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/plugin/
ADD --chown=10001:0 files/sattelite-lib-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/sattelite-lib/

##########################################################################
# LIBRARIES                                                              #
##########################################################################
ADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-deploy-server/lib/
```

**Note:** There are separate hotfix directories for placing different types of hotfix JARS. If you are unsure where a hotfix JAR should be placed, please get in touch with our support team.

For an overview of how `ADD` and `COPY` works, see [the documentation](https://docs.docker.com/engine/reference/builder/#add)

Once you are satisfied with your Dockerfile, run the following command in the same directory:

`docker build -t xl-deploy-custom:9.5.0 .`

This command will build and tag a docker image for you.

**Important:** Always use [semver](https://semver.org/) to version your docker images. Doing so, ensures future compatibility with one of our other tools, `xl up`.

To run the image locally, use the following command:

`docker run -it --rm -p 4516:4516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y xl-deploy-custom:9.5.0`

If you would like to host the docker image elsewhere, you have two options:
**Recommended:**
1. [Push this image to a docker registry](https://docs.docker.com/engine/reference/commandline/push/) of your choice. You can either [set up your own registry](https://docs.docker.com/registry/), or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run
  - `docker tag xl-deploy-custom:9.5.0 yourdockerhuborg/xl-deploy-custom:9.5.0`
  - `docker push yourdockerhuborg/xl-deploy-custom:9.5.0`
  - (On the node you would like to run the container) `docker run -it --rm -p 4516:4516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y yourdockerhuborg/xl-deploy-custom:9.5.0`

**Not recommended:**
2. By using [`docker export`](https://docs.docker.com/engine/reference/commandline/export/) and [`docker load`](https://docs.docker.com/engine/reference/commandline/load/). This is approach is not recommended, as it requires you to move a tar file between different machines.


## XL Release

**Important:** When you create a Dockerfile with custom resources added, always remember that the owning user:group combination _must_ be `10001:0`.

**Note:** Certain JARS should be placed in specific paths only. You shouldn't add a Oracle JAR to the `ext/` folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team.

**Note:** `${APP_HOME}` points to the path `/opt/xebialabs/xl-deploy-server` by default

To begin, create a `Dockerfile` that resembles the following configuration:

```
docker
FROM xebialabs/xl-release:9.5.0

###################################################################################
# PLUGINS                                                                         #
# Plugins should be placed under ${APP_HOME}/default-plugins/ #
###################################################################################

COPY --chown=10001:0 files/xlr-delphix-plugin-9.0.0.jar /opt/xebialabs/xl-release-server/default-plugins/xlr-official/

# Add plugin from url
ADD --chown=10001:0 https://github.com/xebialabs-community/xlr-github-plugin/releases/download/v1.5.2/xlr-github-plugin-1.5.2.jar /opt/xebialabs/xl-release-server/default-plugins/__local__/

##########################################################################
# EXTENSIONS                                                             #
# Extensions should be placed under ${APP_HOME}/ext
##########################################################################
ADD --chown=10001:0 files/ext /opt/xebialabs/xl-release-server/ext/

##########################################################################
# HOTFIXES                                                               #
##########################################################################
ADD --chown=10001:0 files/hotfix.jar /opt/xebialabs/xl-release-server/hotfix/

##########################################################################
# LIBRARIES                                                              #
##########################################################################
ADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-release-server/lib/
```

**Note:** All official XL Release plugins must be placed under `default-plugins/xlr-official/` folder, while custom or community plugins must be placed under `default-plugins/__local__/`

For an overview of how `ADD` and `COPY` works, see [the documentation](https://docs.docker.com/engine/reference/builder/#add)

Once you are satisfied with your Dockerfile, run the following command in the same directory

`docker build -t xl-release-custom:9.5.0 .`

This command will build and tag a docker image for you.
**Important:** Always use [semver](https://semver.org/) to version your docker images. This is to ensure future compatibility with one of our other tools, `xl up`.

To run this image locally, use the following command:

`docker run -it --rm -p 5516:5516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y xl-release-custom:9.5.0`

If you would like to host the docker image elsewhere, you have two options:

**Recommended:**
1. [Push this image to a docker registry](https://docs.docker.com/engine/reference/commandline/push/) of your choice. You can either [set up your own registry](https://docs.docker.com/registry/), or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run
  - `docker tag xl-release-custom:9.5.0 yourdockerhuborg/xl-release-custom:9.5.0`
  - `docker push yourdockerhuborg/xl-release-custom:9.5.0`
  - (On the node you would like to run the container) `docker run -it --rm -p 5516:5516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y yourdockerhuborg/xl-release-custom:9.5.0`

**Not recommended:**
2. By using [`docker export`](https://docs.docker.com/engine/reference/commandline/export/) and [`docker load`](https://docs.docker.com/engine/reference/commandline/load/). This approach is not recommended, as it requires you to move a tar file between different machines.
