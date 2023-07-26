# TechXchange2023

This repository contains artifacts to demonstrate some of the benefits
of Semeru Cloud Compiler (aka OpenJ9 JITServer).




Go to the directory for the demo (/home/ibmuser/JITServerDemo/TeckXchange2023)
and perform the following steps:

1. Use the `searchReplaceIPAddress.sh` script to change all "9.46.81.11" addresses from bash scripts to the IP of the machine where the demo is running):

2. Execute the `startInflux.sh` script to start the influxdb container in normal operation mode.
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

6. Push the images for AcmeAir and mongodb to the OCP private repository

7. Start the grafana container with:
`startGrafana.sh`

8. Using the grafana UI (http://GRAFANA_IP:3000), configure grafana to get data from influxdb (initial credentials are admin/admin)
  There are two pre-configured datasources called InfluxDB and InfluxDB2. However, the IP address of these datasources needs to be adjusted. To configure the datasources, select the gear from the left side menu, then select "Data sources", then select the data source you want to configure (InfluxDB or InfluxDB2).
  Change the "URL" of the data source to the IP machine that runs InfluxDB.


9. Display the pre-loaded dashboard in grafana UI
   From the left side menu select the "Dashboard" icon (4 squares), then select "Browse", then select "JMeter Load Test".

10. Go to the Knative directory
10.1 Deploy mongodb with `kubectl apply -f Mongo.yaml`
10.2 Find the mongodb pod with `kubectl get pods | grep mongodb` and restore the database with `./mongoRestore.sh MONGOPOD`
10.3 Deploy Semeru Cloud Compiler with `kubectl apply -f JITServer.yaml`
10.4 Deploy the default AcmeAir instance with `kubectl apply -f AcmeAirKN_default.yaml`
10.5 Deploy the AcmeAir instance with Semeru Cloud Compiler: `kubectl apply -f AcmeAirKN_SCC.yaml`

11. Apply load
11.1 Find the external address of the two AcmeAir services (`kubectl get route`)
11.2 Change the `runJMeter.sh` script to replace the two addresses of JHOST with the addresses found above
11.3 Execute `./runJMeter.sh` and watch the throughput results in a web browser (http://GRAFANA_IP:3000)









