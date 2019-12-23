# Upgrade XL Release active-active cluster setup with docker compose

### Steps

Follow the below steps to Upgrade XL Release active-active cluster setup,

1. Make sure to read our docs for upgrade and release notes for each version you want to upgrade to.

2. Stop current running docker containers which have old version that need to be upgraded .. no need to stop load balancer, mq and database containers .. check below example,
  ```shell
   # Shutdown deployments
   docker-compose -f docker-compose-xlr-ha.yaml stop xl-release-master  
  ```
3. Update `docker-compose-xlr-ha.yaml` file like below,
 
  * Update image with new tag which represent version you want to upgrade to for both master and worker, for example,
  ```shell
   xl-release-master:
     image: xebialabs/xl-release:9.5.2
  ```
  * specify your DB connection details to point to old DB for example using env variables such as `XL_DB_URL`
  * include all volumes already being used with old docker images. In case of "conf" volume make sure also to update any configurations required by new version "check release notes" before mounting it to new version of the container.
  * Update environment variables to include `FORCE_UPGRADE` see below,
  ```shell
   environment:
         - FORCE_UPGRADE=true
  ``` 
4. You can use the provided `run.sh` to bring up the setup or do it manually with below steps, update the passwords to represent Passwords used in previous version.

```shell
# Set passwords
export XLR_ADMIN_PASS=admin
export POSTGRES_PASS=admin

# upgrade master nodes,
docker-compose -f docker-compose-xlr-ha.yaml up --scale xl-release-master=2 -d

# Print out the status
docker-compose -f docker-compose-xlr-ha.yaml ps
```

5. You can view the logs of individual containers using the `docker logs <container_name> -f` command.
6. You can access XL Release UI at http://localhost:8081
