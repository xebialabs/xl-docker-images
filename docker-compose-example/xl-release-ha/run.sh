#!/bin/bash

# Set passwords
export XLR_ADMIN_PASS=admin
export POSTGRES_PASS=admin

# echo ">>> Create docker network"
# docker network create xld-network || exit

echo ">>> Deploy master nodes"
# deploy master nodes, load balancer, mq and database. You should not change the number of master nodes here, it must be 2
docker-compose -f docker-compose-xlr-ha.yaml up --scale xl-release-master=2 -d || exit

# # get the IP of master nodes, change the container names if you are not inside a folder named "xl-deploy-ha"
# export XLD_MASTER_1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_1)
# export XLD_MASTER_2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_2)

# echo ">>> Deploy worker nodes"
# # Deploy the worker nodes, you can change the number of nodes here if you wish
# docker-compose -f docker-compose-xld-ha-workers.yaml up --scale xl-deploy-worker=2 -d || exit

# Print out the status
docker-compose -f docker-compose-xlr-ha.yaml ps || exit

# # Cleanup
# docker-compose -f docker-compose-xlr-ha.yaml down