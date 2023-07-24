#!/bin/bash
set -e
set -o pipefail
set -x

# The following is my normal image without instantON
ACMEAIR_DEFAULT_IMAGE_NAME="localhost/liberty-acmeair-ee8:23.0.0.6"
# The following is my image with InstantON
ACMEAIR_INSTANT_ON_IMAGE_NAME="localhost/liberty-acmeair-ee8:23.0.0.6-instanton"

#podman build -m=1024m --cap-add=CHECKPOINT_RESTORE --cap-add=SETPCAP --security-opt seccomp=unconfined -f Dockerfile_acmeair_instanton -t $ACMEAIR_DEFAULT_IMAGE_NAME .
podman run --name my-container -m 512m --cpus=1.0 -e _JAVA_OPTIONS="" -e MONGO_HOST="9.46.81.11" -e MONGO_PORT="27017" -e MONGO_DBNAME="acmeair" --privileged -e WLP_CHECKPOINT=afterAppStart $ACMEAIR_DEFAULT_IMAGE_NAME
podman commit my-container $ACMEAIR_INSTANT_ON_IMAGE_NAME
podman rm my-container

