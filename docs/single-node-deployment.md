If you want to run a single node instance of XL Release or XL Deploy using Docker follow this steps.

# Single node XL Deploy deployment

## Docker run

You can run the official XLD docker images from XebiaLabs using the `docker run` command as follows

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 4516:4516 \
  --name xl-deploy xebialabs/xl-deploy:9.5.0
```

This will start the XL Deploy container and print out the container ID, you can also find running containers using the `docker ps` command. You can pass more environment variables to the command using -e flags.

You can stream the logs from the container using `docker logs -f <container id>`.

You can mount volumes if required like below during the `docker run` command. In this sample we are mounting configurations and hotfix from local volumes.

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 4516:4516 \
  -v ~/XebiaLabs/xl-deploy-server/conf:/opt/xebialabs/xl-deploy-server/conf \
  -v ~/XebiaLabs/xl-deploy-server/hotfix/lib:/opt/xebialabs/xl-deploy-server/hotfix/lib \
  -v ~/XebiaLabs/xl-deploy-server/hotfix/plugins:/opt/xebialabs/xl-deploy-server/hotfix/plugins \
  --name xl-deploy xebialabs/xl-deploy:9.5.0
```

## Docker compose

You can also use a docker-compose file to run XLD containers, see the below file for example

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
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y
```

Save the above content to a file called `docker-compose.yml` in a folder and run `docker-compose up -d` from that folder.

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

# Single node XL Release deployment

## Docker run

You can run the official XLR docker images from XebiaLabs using the `docker run` command as follows

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 5516:5516 \
  --name xl-release xebialabs/xl-release:9.5.0
```

This will start the XL Release container and print out the container ID, you can also find running containers using the `docker ps` command. You can pass more environment variables to the command using -e flags.

You can stream the logs from the container using `docker logs -f <container id>`

You can mount volumes if required like below during the `docker run` command. In this sample we are mounting configurations and hotfix from local volumes

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 5516:5516 \
  -v ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf \
  -v ~/XebiaLabs/xl-release-server/hotfix/:/opt/xebialabs/xl-release-server/hotfix/ \
  --name xl-release xebialabs/xl-release:9.5.0
```

## Docker compose

You can also use a docker-compose file to run XLR containers, see the below file for example

```yaml
version: "2"
services:
  xl-release:
    image: xebialabs/xl-release:9.5.0
    container_name: xl-release
    ports:
      - "5516:5516"
    volumes:
      - ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf
      - ~/XebiaLabs/xl-release-server/hotfix/:/opt/xebialabs/xl-release-server/hotfix/
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y
```

Save the above content to a file called `docker-compose.yml` in a folder and run `docker-compose up -d` from that folder.

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

# Single node XL Deploy and XL Release deployment

If you want to run a single node instance of both products you can use the below docker compose file to do so.

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
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y

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
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y
```
