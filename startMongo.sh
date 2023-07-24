podman run --rm -d --name mongodb --network=slirp4netns -p 27017:27017 localhost/mongo-acmeair-ee8:5.0.15 --nojournal
sleep 1
./mongoRestore.sh
