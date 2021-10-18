docker-compose -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-slim-workers.yaml down

# You can uncomment the next list of commands if you want to clean up the mounted volumes.

if [[ $# -eq 1 ]] ; then
  if [ "$1" == 'clean' ]; then
    echo "Cleaning mounted volumes."
    rm -rf $PWD/xl-deploy-master/conf/*
    rm -rf $PWD/xl-deploy-master/centralConfiguration/*
    rm -rf $PWD/xl-deploy-master/plugins/*

    rm -rf $PWD/xl-deploy-worker/conf/*
    rm -rf $PWD/xl-deploy-worker/plugins/*
    echo "Mounted volumes has cleaned successfully."
  fi
fi
