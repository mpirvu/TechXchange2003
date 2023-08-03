# TechXchange2023

This repository contains artifacts to demonstrate some of the benefits
of Semeru Cloud Compiler (aka OpenJ9 JITServer).




Go to the directory for the demo (/home/ibmuser/JITServerDemo/TechXchange2023)
and perform the following steps:



0. Login as root and execute the following commands:
  su --login root
   Password: password
Login to OCT

  Switch to the "default" namespace:
`oc project default`

Clone the repository
```
cd /home/ibmuser/JITServerDemo
git clone https://github.com/mpirvu/TechXchange2023.git
cd TechXchange2023
```


1. Use the `searchReplaceIPAddress.sh` script to change all "9.46.81.11" addresses from bash scripts to the IP of the machine where the demo is running):

2. Execute the `./startInflux.sh` script to start the influxdb container in normal operation mode.
Verify the influxdb container is up and running with
`podman ps -a | grep influxdb`

Create another bucket by executing the following command:
`podman exec influxdb influx bucket create -n jmeter2 -o IBM -r 1d`

Verify that two buckets called jmeter and jmeter2 exist with the following command:
`podman exec influxdb influx bucket list`


3. Create the JMeter container:
```
   cd BuildImages/JMeterContext
   ./build_jmeter.sh
    cd ../..
```

4. Create the mongodb container
```
  cd BuildImages/MongoContext
  ./build_mongo.sh
  cd ../..
```

5. Create the two AcmeAir containers.
```
   cd BuildImages/LibertyContext
   ./build_acmeair.sh
   cd ../..
```
Optional: if you want to create the AcmeAir container with InstantON, execute `./checkpoint.sh` after the `./build_acmeair.sh` command above.

6. Push the images for AcmeAir and mongodb to the OCP private repository

	oc registry login --insecure=true
	oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
	oc get secrets -n openshift-image-registry | grep cluster-image-registry-operator-token
	export OCP_REGISTRY_PASSWORD=$(oc get secret -n openshift-image-registry cluster-image-registry-operator-token-<GET NAME FROM PREVIOUS COMMAND> -o=jsonpath='{.data.token}{"\n"}' | base64 -d)
	export OCP_REGISTRY_HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')

	podman login -p $OCP_REGISTRY_PASSWORD -u kubeadmin $OCP_REGISTRY_HOST --tls-verify=false

	podman tag localhost/mongo-acmeair:5.0.17 $(oc registry info)/$(oc project -q)/mongo-acmeair:5.0.17
	podman push $(oc registry info)/$(oc project -q)/mongo-acmeair:5.0.17 --tls-verify=false

	podman tag localhost/liberty-acmeair-ee8:23.0.0.6 $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6
	podman push $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6 --tls-verify=false

Optional: if you want to push the AcmeAir container with InstantON, execute the following commands after the previous two commands:
	podman tag localhost/liberty-acmeair-ee8:23.0.0.6-instanton $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6-instanton
	podman push $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6-instanton --tls-verify=false


7. Start the grafana container with:
`./startGrafana.sh`

Find the IP address of the local machine with `ifconfig`. It should be something like "10.xxx.xxx.xxx".


8. Using the grafana UI (http://GRAFANA_IP:3000), configure grafana to get data from influxdb (initial credentials are admin/admin)
  There are two pre-configured datasources called InfluxDB and InfluxDB2. However, the IP address of these datasources needs to be adjusted. To configure the datasources, select the gear from the left side menu, then select "Data sources", then select the data source you want to configure (InfluxDB or InfluxDB2).
  Change the "URL" of the data source to the IP machine that runs InfluxDB. Then press "Save & Test" to validate the connection.
  Make sure you change both data sources.


9. Display the pre-loaded dashboard in grafana UI
   From the left side menu select the "Dashboard" icon (4 squares), then select "Browse", then select "JMeter Load Test".
   Enable automatic refresh of the graphs by selecting `10 sec` in the top right menu of grafana dashboard.

10. Deploy the services in OCP
10.0 Go to the Knative directory `cd Knative`
10.1 Validate that yaml files have the correct images specified with `grep "image:" *.yaml`
   The image should start with `image.registry.openshift-image-registry.svc:5000/` followed by the name of the project where the images were pushed (`default`) and followed by the image name and tag.
10.2 Deploy mongodb with `kubectl apply -f Mongo.yaml`
10.3 Find the mongodb pod with `kubectl get pods | grep mongodb` and restore the database with `./mongoRestore.sh MONGOPOD`
Alternatively, you can find the pod for the mongodb service with
 `kubectl get pods --selector=app=mongodb  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`
10.4 Deploy Semeru Cloud Compiler with `kubectl apply -f JITServer.yaml` and verify it started sucessfully with `kubectl get pods | grep jitserver`
10.5 Deploy the default AcmeAir instance with `kubectl apply -f AcmeAirKN_default.yaml`
A message should appear in the console saying that the service was created.
10.6 Deploy the AcmeAir instance with Semeru Cloud Compiler: `kubectl apply -f AcmeAirKN_SCC.yaml`
   or
     Deploy the AcmeAir instance with Semeru Cloud Compiler and InstantON: `kubectl apply -f AcmeAirKN_SCC_InstantON.yaml`

11. Apply external load
11.1 Find the external address of the two AcmeAir services.
   If knative CLI is installed, you can use `kn service list` to find the external address of the two services.
   If not, you can use `kubectl get all | http`
   In either case, extract the part that comes after "http://" or "https:" and use it as the address of the service.
   It should be something like "acmeair-baseline-default.apps.ocp.ibm.edu" and "acmeair-scc-default.apps.ocp.ibm.edu" (or "acmeair-sccio-default.apps.ocp.ibm.edu" for the service with InstantON)
11.2 Verify that the `runJMeter.sh` script contains these service addresses for the JHOST environment variable passed to the JMeter containers.
  Note: if you selected to start the `AcmeAirKN_SCC_InstantON` service instead of `AcmeAirKN_SCC`, then edit `runJMeter.sh` to comment out the second container invocation (the one with JHOST="acmeair-scc-default.apps.ocp.ibm.edu") and remove the comment from the third container invocation (the one with JHOST="acmeair-sccio-default.apps.ocp.ibm.edu").
11.3 Execute the `./runJMeter.sh` script. This will launch two JMeter containers that will generate load for the two AcmeAir services.
After 10 seconds or so, validate that there are no errors with `podman logs jmeter1` and `podman logs jmeter2`
11.4 Go to the grafana dashboard you configured before and watch the throughput results for the two services.


12. Cleanup
12.1 Delete the services you created with
   `kubectl delete -f AcmeAirKN_default.yaml`
   `kubectl delete -f AcmeAirKN_SCC.yaml`
   `kubectl delete -f AcmeAirKN_SCC_InstantON.yaml`
   `kubectl delete -f JITServer.yaml`
   `kubectl delete -f Mongo.yaml`
12.2 Delete the grafana and influxdb containers with
   `podman stop grafana`
   `podman stop influxdb`