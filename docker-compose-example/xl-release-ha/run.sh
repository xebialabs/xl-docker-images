#!/bin/bash

# Set passwords
export XLR_ADMIN_PASS=admin
export POSTGRES_PASS=admin

echo ">>> Deploy master nodes"
# deploy master nodes, load balancer, mq and database.
docker-compose -f docker-compose-xlr-ha.yaml up --scale xl-release-master=2 -d || exit

# Print out the status
docker-compose -f docker-compose-xlr-ha.yaml ps || exit

# # Cleanup
# docker-compose -f docker-compose-xlr-ha.yaml down