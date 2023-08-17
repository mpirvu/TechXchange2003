# TechXchange2023

This repository contains artifacts to demonstrate some of the benefits
of Semeru Cloud Compiler (aka OpenJ9 JITServer).




0. Login as root using the provided password:
  `su --login root`
   Password: password

Login to OCP

Switch to the "default" namespace:
   `oc project default`

Clone the repository
```
cd /home/ibmuser/Lab-SCC
git clone https://github.com/mpirvu/TechXchange2023.git
cd TechXchange2023
```


1. Find the IP of the current machine with `ifconfig`. It should be something like "10.xxx.xxx.xxx".
   Then use the `./searchReplaceIPAddress.sh` script to change all "9.46.81.11" addresses from bash scripts to the IP of the current machine.
   Use the following command to do this (after replacing xxx.xxx.xxx.xxx with the IP of the current machine)
   ```
   ./searchReplaceIPAddress.sh 9.46.81.11 xxx.xxx.xxx.xxx
   ```

2. Start the influxdb container in normal operation mode:
   ```
   ./startInflux.sh
   ```
   Verify the influxdb container is up and running:
   ```
   podman ps -a | grep influxdb
   ```

   Create another data bucket:
   ```
   podman exec influxdb influx bucket create -n jmeter2 -o IBM -r 1d
   ```

   Verify that two buckets called jmeter and jmeter2 exist:
   ```
   podman exec influxdb influx bucket list
   ```


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


5. Create the two AcmeAir containers (with and without InstantON).
   ```
   cd BuildImages/LibertyContext
   ./build_acmeair.sh
   ./checkpoint.sh
   cd ../..
   ```


6. Push the images for AcmeAir and mongodb to the OCP private repository
   ```
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

	podman tag localhost/liberty-acmeair-ee8:23.0.0.6-instanton $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6-instanton
	podman push $(oc registry info)/$(oc project -q)/liberty-acmeair-ee8:23.0.0.6-instanton --tls-verify=false
   ```

7. Start the grafana container:
   ```
   ./startGrafana.sh
   ```

8. Using the grafana UI in a local browser (http://localhost:3000), configure grafana to get data from influxdb.

   Note: Initial credentials are admin/admin. You can skip the password change.

   Note: There are two pre-configured datasources called InfluxDB and InfluxDB2. However, the IP address of these datasources needs to be adjusted.

   To configure the datasources, select the gear from the left side menu, then select "Data sources", then select the data source you want to configure (InfluxDB or InfluxDB2).
   Change the "URL" of the data source to the IP machine that runs InfluxDB (this was determined in Step 1 using `ifconfig`). Then press "Save & Test" (at the bottom of the screen)to validate the connection.
   Make sure you change both data sources.


9. Display the pre-loaded dashboard in grafana UI

   From the left side menu select the "Dashboard" icon (4 squares), then select "Browse", then select "JMeter Load Test".
   Enable automatic refresh of the graphs by selecting `10 sec` in the top right menu of grafana dashboard.


10. Deploy the services in OCP
    1. Go to the Knative directory:
       ```
       cd Knative
       ```

    2. Validate that yaml files have the correct images specified:
       ```
       grep "image:" *.yaml
       ```
       The image should start with `image-registry.openshift-image-registry.svc:5000/` followed by the name of the project where the images were pushed (`default`) and followed by the image name and tag.

    3. Deploy mongodb:
       ```
       kubectl apply -f Mongo.yaml
       ```
       and validate that the pod is running with:
       ```
       kubectl get pods | grep mongodb
       ```

    4. Restore the mongo database:
       ```
       ./mongoRestore.sh
       ```

    5. Deploy Semeru Cloud Compiler:
       ```
       kubectl apply -f JITServer.yaml
       ```
       and verify it started sucessfully with:
       ```
       kubectl get pods | grep jitserver
       ```

    6. Deploy the default AcmeAir instance:
       ```
       kubectl apply -f AcmeAirKN_default.yaml
       ```
       A message should appear in the console saying that the service was created.

    7. Deploy the AcmeAir instance with Semeru Cloud Compiler:
       ```
       kubectl apply -f AcmeAirKN_SCC.yaml
       ```
       OR

       Deploy the AcmeAir instance with Semeru Cloud Compiler and InstantON:
       ```
       kubectl apply -f AcmeAirKN_SCC_InstantON.yaml
       ```

    8. Verify that 4 pods are running:
       ```
       kubectl get pods
       ```


11. Apply external load
    1. Find the external address of the two AcmeAir services. Use
       ```
       kubectl get all | grep http
       ```
       and extract the part that comes after "http://" or "https://" and use it as the address of the service.
       It should be something like `acmeair-baseline-default.apps.ocp.ibm.edu` and `acmeair-scc-default.apps.ocp.ibm.edu` (or `acmeair-sccio-default.apps.ocp.ibm.edu` for the service with InstantON)

    2. Verify that the `runJMeter.sh` script contains these service addresses for the JHOST environment variable passed to the JMeter containers:
       ```
       cat runJMeter.sh | grep JHOST
       ```
       Note: if you selected to start the `AcmeAirKN_SCC_InstantON` service instead of `AcmeAirKN_SCC`, then edit `runJMeter.sh` to comment out the second container invocation (the one with JHOST="acmeair-scc-default.apps.ocp.ibm.edu") and remove the comment from the third container invocation (the one with JHOST="acmeair-sccio-default.apps.ocp.ibm.edu").

    3. Launch jmeter containers:
       ```
       ./runJMeter.sh
       ```
       This will launch two JMeter containers that will generate load for the two AcmeAir services.

       After 10 seconds or so, validate that there are no errors with
       ```
       podman logs jmeter1
       podman logs jmeter2
       ```

    4. Go to the grafana dashboard you configured before and watch the throughput results for the two services.


12. Cleanup
    1. Delete the services you created:
       ```
       kubectl delete -f AcmeAirKN_default.yaml
       kubectl delete -f AcmeAirKN_SCC.yaml
       kubectl delete -f AcmeAirKN_SCC_InstantON.yaml
       kubectl delete -f JITServer.yaml
       kubectl delete -f Mongo.yaml
       ```
    2. Stop the grafana and influxdb containers:
       ```
       podman stop grafana
       podman stop influxdb
       ```