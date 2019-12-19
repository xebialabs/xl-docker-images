# Upgrade XL Deploy active-active cluster setup with docker compose

### Steps

Follow the below steps to Upgrade XL Deploy active-active cluster setup,

1. Make sure to read our docs for upgrade and release notes for each version you want to upgrade to.

2. Stop current running XL Deploy docker containers which have old version that need to be upgraded .. no need to stop load balancer, mq and database containers .. check below example,
  ```shell
   # Shutdown deployments
   docker-compose  -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml stop xl-deploy-master xl-deploy-worker
  ```
3. Update both files `docker-compose-xld-ha.yaml` and `docker-compose-xld-ha-workers.yaml` like below,
 
  * Update image with new tag which represent version you want to upgrade to for both master and worker, for example,
  ```shell
   xl-deploy-master:
     image: xebialabs/xl-deploy:9.5.1
  ```
  * specify your DB connection details to point to old DB for both master and worker for example using env variables such as `XL_DB_URL`
  * include all volumes already being used with old docker images for both master and worker. In case of "conf" volume make sure also to update any configurations required by new version "check release notes" before mounting it to new version of the container.
  * Update environment variables to include `FORCE_UPGRADE` for both master and worker see below,
  ```shell
   environment:
         - FORCE_UPGRADE=true
  ``` 
4. You can use the provided `run.sh` to bring up the setup or do it manually with below steps, update the passwords to represent Passwords used in previous version.

```shell
# Set passwords
export XLD_ADMIN_PASS=admin
export RABBITMQ_PASS=admin
export POSTGRES_PASS=admin

# upgrade master nodes only. You should not change the number of master nodes here, it must be 2
docker-compose -f docker-compose-xld-ha.yaml up --scale xl-deploy-master=2 -d

# get the IP of master nodes, change the container names if you are not inside a folder named "xl-deploy-ha"
export XLD_MASTER_1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_1)
export XLD_MASTER_2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_2)

# Deploy the worker nodes, you can change the number of nodes here if you wish
docker-compose -f docker-compose-xld-ha-workers.yaml up --scale xl-deploy-worker=2 -d

# Print out the status
docker-compose -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml ps
```

5. You can view the logs of individual containers using the `docker logs <container_name> -f` command.
6. You can access XL Deploy UI at http://localhost:8080
