#!/bin/bash
# Output is written to  /output/acmeair.stats.0 inside the container
# -e JURL="/" -e JUSERBOTTOM=0 
podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=300 -e JHOST="9.46.81.11" -e JPORT=9080  -e JUSERBOTTOM=0   -e JUSER=199 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter  --name jmeter1 localhost/jmeter-acmeair:5.5-influxdb
podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=300 -e JHOST="9.46.81.11" -e JPORT=9081  -e JUSERBOTTOM=200 -e JUSER=399 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter2 --name jmeter2 localhost/jmeter-acmeair:5.5-influxdb
