#!/bin/bash
# This script only needs to be executed once to create initialize the 
# influx database and create the user, organization, token and bucket
# The script creates two directories, "data" and "config", and maps
# them inside the influxdb container for persistence.
# In this script, the token is given as an environment variable to the
# container, but if not, a random totekn will be generated.

if [ -d "data" ]; then
  echo "Directory data already exists; doing nothing"
  exit -1
fi
if [ -d "config" ]; then
  echo "Directory config already exists; doing nothing"
  exit -1
fi


mkdir data
mkdir config

podman run -it --rm -p 8086:8086 \
      --name influxdb \
      -v $PWD/data:/var/lib/influxdb2 \
      -v $PWD/config:/etc/influxdb2 \
      -e DOCKER_INFLUXDB_INIT_MODE=setup \
      -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
      -e DOCKER_INFLUXDB_INIT_PASSWORD=Administrat0r \
      -e DOCKER_INFLUXDB_INIT_ORG=IBM \
      -e DOCKER_INFLUXDB_INIT_BUCKET=jmeter \
      -e DOCKER_INFLUXDB_INIT_RETENTION=1d \
      -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=o9ceP5FUCKNluez0il8rucFE5lsd4exc1CPf3hu7MJoaSsNnsvNnYIfB_LJqpuCopa646K9SFiPQslR-OIPxGw== \
      influxdb:2.2.0
#Press Ctrl-C to terminate this process
