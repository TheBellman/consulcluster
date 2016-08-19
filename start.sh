#!/bin/bash

SERVER_COUNT=3

eval $(docker-machine env default)

DOCKER_IP=$(docker-machine ip default)

echo "==== creating encryption key ===="
KEY=$(docker run -t --rm consul keygen)

echo "==== starting servers ===="
docker run -d --name=consul0 \
  -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
  consul agent \
    -server \
    -node=consul0 \
    -encrypt=$KEY \
    -bootstrap-expect=3

CONSUL0=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul0)

for ((i=1; i<SERVER_COUNT; i++))
do
  docker run -d --name=consul$i \
    -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
    consul agent \
      -server \
      -node=consul$i \
      -encrypt=$KEY \
      -retry-join=$CONSUL0 \
      -bootstrap-expect=$SERVER_COUNT
done

echo "==== starting agent ===="
docker run -d --name=agent0 \
  -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
  -p 8500:8500 \
  -p $DOCKER_IP:53:8600/tcp \
  -p $DOCKER_IP:53:8600/udp \
  consul agent \
    -node=agent0 \
    -encrypt=$KEY \
    -client=0.0.0.0 \
    -retry-join=$CONSUL0 \
    -ui

echo "==== pausing ===="
sleep 2

echo "==== docker processes ===="
docker ps --format "table {{ .Names }}\t{{ .Status }}\t{{ .Ports }}"

echo "==== consul members ===="
docker exec -t consul0 consul members

echo "==== consul node catalog ===="
curl $DOCKER_IP:8500/v1/catalog/nodes?pretty

echo "==== consul agent location ===="
echo "http://$DOCKER_IP:8500"
