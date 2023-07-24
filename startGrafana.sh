podman run -d --rm --network=slirp4netns -p 3000:3000 --name=grafana --volume grafana-storage:/var/lib/grafana   docker.io/grafana/grafana-oss:8.4.6

