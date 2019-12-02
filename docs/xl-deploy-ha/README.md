# XL Deploy active-active cluster setup with docker compose

The production setup for XL Deploy as mentioned [here](https://docs.xebialabs.com/v.9.0/xl-deploy/how-to/set-up-xl-deploy-in-production/) can be done using Docker compose as below.

This is a sample, you can follow this approach to setup the database and other infrastructure of your choice.

**Note 1**: For production deployments it is advised to use Kubernetes to orchestrate the deployment of the applications. Docker compose is not ideal for production setup. Proceed at your own risk. Use the `xl up` command from the official XebiaLabs CLI to install XebiaLabs products using Kubernetes. **//TODO: Link to XL UP docs**

**Note 2**: For HA setup to work, you need to mount a licence file or provide an environment variable `XL_LICENSE` with a licence text converted to base64 for the XL Deploy instances

**Note 3**: The folders you mount needs to be owned by user 10001, for example, you can run `sudo chown -R 10001 xl-deploy-master` if you are going to mount directories under `$PWD/xl-deploy-master` folder.

### setup

The setup includes

- A load balancer with HaProxy
- RabbitMQ single node setup
- PostgreSQL database single node setup
- XL Deploy master nodes
- XL Deploy worker nodes

### Limitations:

- You can have only 2 master nodes
- The database setup is for demo purposes, use your own setup or use external database
- The MQ setup is for demo purposes, use your own setup or use external MQ

### Steps

Follow the below steps to deploy the sample

1. Download the `docker-compose-xld-ha.yaml` and `docker-compose-xld-ha-workers.yaml` files here
2. You can use the provided `run.sh` to bring up the setup or do it manually with below steps, change the passwords as required in either case.

```shell
# Set passwords
export XLD_ADMIN_PASS=admin
export RABBITMQ_PASS=admin
export POSTGRES_PASS=admin

# Create docker network
docker network create xld-network

# deploy master nodes, load balancer, mq and database. You should not change the number of master nodes here, it must be 2
docker-compose -f docker-compose-xld-ha.yaml up --scale xl-deploy-master=2 -d

# get the IP of master nodes, change the container names if you are not inside a folder named "xl-deploy-ha"
export XLD_MASTER_1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_1)
export XLD_MASTER_2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_2)

# Deploy the worker nodes, you can change the number of nodes here if you wish
docker-compose -f docker-compose-xld-ha-workers.yaml up --scale xl-deploy-worker=2 -d

# Print out the status
docker-compose -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml ps
```

3. You can view the logs of individual containers using the `docker logs <container_name> -f` command.
4. You can access XL Deploy UI at http://localhost:8080
5. To shutdown the setup you can run below

```shell
# Shutdown deployments
docker-compose -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml down
# Remove network
docker network rm xld-network
```
