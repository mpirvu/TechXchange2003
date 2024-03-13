FROM icr.io/appcafe/ibm-semeru-runtimes:open-17-jre-ubi
# FROM icr.io/appcafe/ibm-semeru-runtimes:open-21-ea-jre-ubi9-minimal

EXPOSE 38400
# Whack any options set by the OpenJ9 container definition
ENV OPENJ9_JAVA_OPTIONS=""

RUN mkdir /tmp/vlogs
WORKDIR /opt/java
ENTRYPOINT ["/opt/java/openjdk/bin/jitserver"]


