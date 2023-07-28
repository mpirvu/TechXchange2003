#!/bin/bash

podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=240 -e JHOST="acmeair-baseline-default.apps.ocp.ibm.edu" -e JPORT=80  -e JUSERBOTTOM=0   -e JUSER=99  -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter  --name jmeter1 localhost/jmeter-acmeair:5.5-influxdb
podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=240 -e JHOST="acmeair-scc-default.apps.ocp.ibm.edu"      -e JPORT=80  -e JUSERBOTTOM=100 -e JUSER=199 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter2 --name jmeter2 localhost/jmeter-acmeair:5.5-influxdb
#podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=240 -e JHOST="acmeair-sccio-default.apps.ocp.ibm.edu"    -e JPORT=80  -e JUSERBOTTOM=100 -e JUSER=199 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter2 --name jmeter2 localhost/jmeter-acmeair:5.5-influxdb
