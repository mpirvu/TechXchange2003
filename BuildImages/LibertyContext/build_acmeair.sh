#!/bin/bash
podman build -m=1024m  --no-cache -f Dockerfile_acmeair -t localhost/liberty-acmeair-ee8:23.0.0.6 .

