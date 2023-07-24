#influxdb2-2.2.0-linux-amd64/influxd --reporting-disabled
podman run -d --rm -p 8086:8086 \
      --network=slirp4netns \
      --name influxdb \
       -v $PWD/data:/var/lib/influxdb2 \
       -v $PWD/config:/etc/influxdb2 \
      influxdb:2.2.0 --reporting-disabled

