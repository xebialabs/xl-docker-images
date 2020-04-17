If you want to run a single node instance of XL Release or XL Deploy using Docker follow this steps.

# Single node XL Deploy deployment

## Docker run

You can run the official XLD docker images from XebiaLabs using the `docker run` command as follows:

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 4516:4516 \
  --name xl-deploy xebialabs/xl-deploy:9.5.0
```

This will start the XL Deploy container and print out the container ID, you can also find running containers using the `docker ps` command. You can pass more environment variables to the command using -e flags.

You can stream the logs from the container using `docker logs -f <container id>`.

You can mount volumes if required, while executing the `docker run` command as shown below.
**Note:** In our example we are mounting configurations and hotfix from local volumes.

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

Once the containers have started, you can access them at http://localhost:4516/, you might want to wait for a minute for the service to be up and running.

## Docker compose

You can also use a docker-compose file to run XLD containers, as shown in the example below:

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

Save the above content to a file named `docker-compose.yml` in a folder and run `docker-compose up -d` from the same folder.

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

Once the containers have started, you can access them at http://localhost:4516/, you might want to wait for a minute for the service to be up and running.

# Single node XL Release deployment

## Docker run

You can run the official XLR docker images from XebiaLabs using the `docker run` command as follows:

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 5516:5516 \
  --name xl-release xebialabs/xl-release:9.5.0
```

This will start the XL Release container and print out the container ID. You can also find running containers using the `docker ps` command. You can also pass more environment variables to the command using -e flags.

You can stream the logs from the container using `docker logs -f <container id>`

You can mount volumes if required, while executing the `docker run` command as shown below.
**Note:** In our example we are mounting configurations and hotfix from local volumes.

```shell
docker run -d  \
  -e ADMIN_PASSWORD=admin \
  -e ACCEPT_EULA=Y \
  -p 5516:5516 \
  -v ~/XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf \
  -v ~/XebiaLabs/xl-release-server/hotfix/:/opt/xebialabs/xl-release-server/hotfix/ \
  --name xl-release xebialabs/xl-release:9.5.0
```
Once the containers have started, you can access them at http://localhost:5516/, you might want to wait for a minute for the service to be up and running.

## Docker compose

You can also use a docker-compose file to run XLR containers, as shown in the example below:

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

Save the above content to a file named `docker-compose.yml` in a folder and run `docker-compose up -d` from the same folder.

If you use a different file name, then run `docker-compose -f <filename.yaml> up -d`

Once the containers have started, you can access them at http://localhost:5516/, you might want to wait for a minute for the service to be up and running.

# Single node XL Deploy and XL Release deployment

If you want to run a single node instance of both the products you can use docker compose file shown below, to do so.

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

Once the containers have started, you can access XL Deploy at http://localhost:4516/ and XL Release at http://localhost:5516/. You might want to wait for a minute for the services to be up and running.

When running XLR and XLD with docker, you might want to configure an XLD instance on XLR for deployment tasks. Go to **Settings** > **Shared configuration** > **XL Deploy server** click the + icon to add a new configuration and fill in the following details and click **test** and then **save**.

**Title**: xl-deploy-docker
**URL**: http://xl-deploy:4516
**Username**: admin
**Password**: admin

You can leave other fields empty. You can use a different admin password.
