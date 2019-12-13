If you want to upgrade a single node instance of XL Release or XL Deploy using Docker follow these steps,

1. Make sure to read our docs for upgrade and release notes for each version you want to upgrade to.
2. Stop current running docker container which have old version ythat need to be upgraded.
3. Start new docker container with new tag which represent version you want to upgrade to, taking in consideration below
    * include all volumes already being used with old docker images
    * specify your DB connection details to point to old DB for example using env variables such as `XL_DB_URL`
    * make sure to use `FORCE_UPGRADE_FLAG` to be true in order to force upgrade by using flag `-force-upgrades`

# Upgrade Single node XL Deploy deployment

## Docker run

After stopping old XL Deploy docker container You can start upgrade using new version through tag while running `docker run` command as follows,

```shell
docker run -d  \
  -e FORCE_UPGRADE_FLAG=true \
  -p 4516:4516 \
  -e XL_DB_URL="jdbc:postgresql://PsqlDbHost:5432/repo" \
  -e XL_DB_USERNAME=postgres \
  -e XL_DB_PASSWORD="password" \
  -v ~/XebiaLabs/xl-deploy-server/conf:/opt/xebialabs/xl-deploy-server/conf \
  -v ~/XebiaLabs/xl-deploy-server/plugins:/opt/xebialabs/xl-deploy-server/plugins \
  --name xl-deploy xebialabs/xl-deploy:9.5.1
```

This will start the XL Deploy container, print out the container ID and detect that there is old version of XL Deploy then start upgrade, you can also find running containers using the `docker ps` command.

You can stream the logs from the container using `docker logs -f <container id>`.

Once the containers are started you can find them at http://localhost:4516/, you might want a wait for a minute for the service to be up and running

## Docker compose

You can also use a docker-compose file to run XLD containers, see the below file for example

```yaml
version: "2"
services:
  xl-deploy:
    image: xebialabs/xl-deploy:9.5.1
    container_name: xl-deploy
    ports:
      - "4516:4516"
    volumes:
      - ~/XebiaLabs/xl-deploy-server/conf:/opt/xebialabs/xl-deploy-server/conf
      - ~/XebiaLabs/xl-deploy-server/hotfix/lib:/opt/xebialabs/xl-deploy-server/hotfix/lib
      - ~/XebiaLabs/xl-deploy-server/hotfix/plugins:/opt/xebialabs/xl-deploy-server/hotfix/plugins
    environment:
      - FORCE_UPGRADE_FLAG=true \
      - XL_DB_URL="jdbc:postgresql://PsqlDbHost:5432/xl-deploy" \
      - XL_DB_USERNAME=postgres \
      - XL_DB_PASSWORD="password" \
```

Save the above content to a file called `docker-compose.yml` in a folder and run `docker-compose up -d` from that folder .. while starting it will detect that there is old version of XL Deploy then start upgrade

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

Once the containers are started you can find them at http://localhost:4516/, you might want a wait for a minute for the service to be up and running

# Upgrade Single node XL Release deployment

## Docker run

After stopping old XL Release docker container You can start upgrade using new version through tag while running `docker run` command as follows,

```shell
docker run -d  \
  -e FORCE_UPGRADE_FLAG=true \
  -p 5516:5516 \
  -e XL_DB_URL="jdbc:postgresql://PsqlDbHost:5432/repo" \
  -e XL_DB_USERNAME=postgres \
  -e XL_DB_PASSWORD="password" \
  -e XL_REPORT_DB_USERNAME=postgres \
  -e XL_REPORT_DB_PASSWORD="password" \
  -v ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf \
  -v ~/XebiaLabs/xl-release-server/hotfix/lib:/opt/xebialabs/xl-release-server/hotfix/lib
  -v ~/XebiaLabs/xl-release-server/plugins:/opt/xebialabs/xl-release-server/plugins \
  --name xl-release xebialabs/xl-release:9.5.2
```

This will start the XL Release container, print out the container ID and detect that there is old version of XL Release then start Upgrade process, you can also find running containers using the `docker ps` command.

You can stream the logs from the container using `docker logs -f <container id>`.

Once the containers are started you can find them at http://localhost:5516/, you might want a wait for a minute for the service to be up and running

## Docker compose

You can also use a docker-compose file to run XLR containers, see the below file for example

```yaml
version: "2"
services:
  xl-release:
    image: xebialabs/xl-release:9.5.2
    container_name: xl-release
    ports:
      - "5516:5516"
    volumes:
      - ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf
      - ~/XebiaLabs/xl-release-server/hotfix/lib:/opt/xebialabs/xl-release-server/hotfix/lib
      - ~/XebiaLabs/xl-release-server/hotfix/plugins:/opt/xebialabs/xl-release-server/hotfix/plugins
    environment:
      - FORCE_UPGRADE_FLAG=true \
      - XL_DB_URL="jdbc:postgresql://PsqlDbHost:5432/xl-release" \
      - XL_DB_USERNAME=postgres \
      - XL_DB_PASSWORD="password" \
      - XL_REPORT_DB_USERNAME=postgres \
      - XL_REPORT_DB_PASSWORD="password" \
```

Save the above content to a file called `docker-compose.yml` in a folder and run `docker-compose up -d` from that folder .. while starting it will detect that there is old version of XL Release then start upgrade

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

Once the containers are started you can find them at http://localhost:5516/, you might want a wait for a minute for the service to be up and running

