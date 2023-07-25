# TechXchange2023

This repository contains artifacts to demonstrate some of the benefits
of Semeru Cloud Compiler (aka OpenJ9 JITServer).

Go to the directory for the demo (/home/ibmuser/JITServerDemo/TeckXchange2023)
and perform the following steps (NOTE! Use the `searchReplaceIPAddress.sh` script to change all "9.46.81.11" addresses from bash scripts to the IP of the machine where the demo is running):



1. Execute the `initInfluxdb.sh` script
This starts the influxdb container in setup mode to create user, password, bucket, token.
Two directories are created, `data` and `config` and they will persist data for influx database.
Note that the `organization` and `token` created at this step must match the one from `.jmx` file used by JMeter.


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
   ./checkpoint.sh
   cd ../..
```
  Note: for the checkpointing process, the container must have the same amount amount of memory and CPU as used in production.

6. Push the images for AcmeAir and mongodb to the OCP private repository

7. Setup grafana:
 Create a persistent volume for your data with:
`podman volume create grafana-storage`
and verify that the volume was created correctly with
`podman volume inspect grafana-storage`
Start the grafana container with:
`startGrafana.sh`

8. Using the UI, configure grafana to get data from influxdb.
  Create two data sources, , one for each influxdb bucket.
  - Type: influxdb
  - Query Language ==> Flux
  - URL: http://YOUR_INFLUXDB_IP:8086
  - Access: server
  - Skip TLS verify
  - Basic auth details: admin/Administrat0r
  - Organization: IBM
  - Token: o9ceP5FUCKNluez0il8rucFE5lsd4exc1CPf3hu7MJoaSsNnsvNnYIfB_LJqpuCopa646K9SFiPQslR-OIPxGw==
  - Default bucket: jmeter (or jmeter2, depending on which bucket I want to track)

9. Load the dashboard in grafana

10. Go to the Knative directory
10.1 Deploy mongodb with `kubectl apply -f Mongo.yaml`
10.2 Find the mongodb pod with `kubectl get pods | grep mongo` and restore the database with `.\mongoRestore MONGOPOD`
10.3 Deploy Semeru Cloud Compiler with `kubectl apply -f JITServer`
10.4 Deploy the default AcmeAir instance with `kubectl apply -f AcmeAirKN_default.yaml`
10.5 Deploy the AcmeAir instance with SemeruCloudCompiler and JITServer: `kubectl apply -f AcmeAirKN.yaml`

11. Apply load
11.1 Find the external address of the two AcmeAir services (`kubetctl get all`)
11.2 Change the `runJMeter.sh` script to replace the two addresses of JHOST with the addresses found above
11.3 Execite `./runJMeter.sh` and watch the throughput results in grafana









