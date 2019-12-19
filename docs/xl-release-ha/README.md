# XL Release active-active cluster setup with docker compose


The production setup for XL Release as mentioned [here](https://docs.xebialabs.com/v.9.0/xl-release/how-to/set-up-xl-release-production/#production-environment-setup) can be done using Docker compose as below.

This is a sample, you can follow this approach to setup the database and other infrastructure of your choice.

**Note 1**: For production deployments it is advised to use Kubernetes to orchestrate the deployment of the applications. Docker compose is not ideal for production setup. Proceed at your own risk. Use the `xl up` command from the official XebiaLabs CLI to install XebiaLabs products using Kubernetes. **//TODO: Link to XL UP docs**

**Note 2**: For HA setup to work, you need to mount a licence file or provide an environment variable `XL_LICENSE` with a licence text converted to base64 for the XL Release instances

**Note 3**: The folders you mount needs to be owned by user 10001, for example, you can run `sudo chown -R 10001 xl-release` if you are going to mount directories under `$PWD/xl-release` folder.

### setup

The setup includes

- A load balancer with HaProxy
- PostgreSQL database single node setup
- XL Release master nodes

### Limitations:

- The database setup is for demo purposes, use your own setup or use external database
- The HAproxy setup is for demo purposes, use your own setup 

### Steps

Follow the below steps to deploy the sample

1. Download the `docker-compose-xlr-ha.yaml` file here
2. You can use the provided `run.sh` to bring up the setup or do it manually with below steps, change the passwords as required in either case.

```shell
# Set passwords
export XLR_ADMIN_PASS=admin
export POSTGRES_PASS=admin

# deploy master nodes, load balancer, mq and database.
docker-compose -f docker-compose-xlr-ha.yaml up --scale xl-release-master=2 -d

# Print out the status
docker-compose -f docker-compose-xlr-ha.yaml ps
```

3. You can view the logs of individual containers using the `docker logs <container_name> -f` command.
4. You can access XL Release UI at http://localhost:8081
5. To shutdown the setup you can run below

```shell
# Shutdown deployments
docker-compose -f docker-compose-xlr-ha.yaml down
```

#### For Upgrade procedures please check this [upgrade multi node deployment](upgrade-multi-node-deployment.md)