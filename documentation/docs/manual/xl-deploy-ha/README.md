---
sidebar_position: 1
---

# XL Deploy active-active cluster setup with docker compose

The production setup for XL Deploy as mentioned [here](https://docs.xebialabs.com/v.10.3/deploy/how-to/set-up-xl-deploy-in-production/) can be done using Docker compose as below.

This article provides a sample approach you can follow to setup the database and other infrastructure of your choice.

**Note 1**: For HA setup to work, you need to mount a license file or provide an environment variable `XL_LICENSE` with a license text converted to base64 for the XL Deploy instances

**Note 2**: The folders you mount needs to be owned by user 10001, for example, you can run `sudo chown -R 10001 xl-deploy-master` if you are going to mount directories under `$PWD/xl-deploy-master` folder.

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
- The HAproxy setup is for demo purposes, use your own setup

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

### Steps to use Digital.ai Deploy Task Engine as a worker

From 10.4 we split Deploy Task Engine to a separate distribution. So that running the task has only the code which 
is required for that, not the full version of Deploy. It has a less footprint what can give a great benefit in saving VM RAM.

Use shell scripts `slim-up.sh` to bring the cluster up and `slim-down.sh` to shut it down.
The difference in the configuration is quite subtle, `docker-compose-xld-ha-slim-workers.yaml` points to another image 
and has a bit different command. `worker` argument is no more required. 

#### For Upgrade procedures please check this [upgrade multi node deployment](./upgrade-multi-node-deployment)
