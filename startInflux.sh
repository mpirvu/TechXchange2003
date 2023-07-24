podman run -d --rm -p 8086:8086 \
      --network=slirp4netns \
      --name influxdb \
       -v $PWD/data:/var/lib/influxdb2 \
       -v $PWD/config:/etc/influxdb2 \
      docker.io/influxdb:2.2.0 --reporting-disabled

