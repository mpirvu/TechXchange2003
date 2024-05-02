#!/bin/bash

# Replace [Your_initials] with your initials and replace [OCP server name] with the OCP server name. For example, if the URL used to access the console is 
# https://console-openshift-console.apps.ocp-663004rdfa-kgmt.cloud.techzone.ibm.com, then you can fill in the "OCP server name" as "ocp-663004rdfa-kgmt".

podman run --rm -d --net=host  -e JTHREAD=100 -e JDURATION=240 -e JHOST="acmeair-baseline-scclab-[Your_initials].apps.[OCP server name].cloud.techzone.ibm.com" -e JPORT=80  -e JUSERBOTTOM=0   -e JUSER=99  -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter  --name jmeter1 localhost/jmeter-acmeair:5.5-influxdb
podman run --rm -d --net=host  -e JTHREAD=100 -e JDURATION=240 -e JHOST="acmeair-scc-scclab-[Your_initials].apps.[OCP server name].cloud.techzone.ibm.com"      -e JPORT=80  -e JUSERBOTTOM=100 -e JUSER=199 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter2 --name jmeter2 localhost/jmeter-acmeair:5.5-influxdb
#podman run --rm -d --net=host  -e JTHREAD=10 -e JDURATION=240 -e JHOST="acmeair-sccio-scclab-[Your_initials].apps.[OCP server name].cloud.techzone.ibm.com"    -e JPORT=80  -e JUSERBOTTOM=100 -e JUSER=199 -e JRAMP=0 -e JINFLUXDBADDR="9.46.81.11" -e JINFLUXDBBUCKET=jmeter2 --name jmeter2 localhost/jmeter-acmeair:5.5-influxdb
