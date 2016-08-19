#!/bin/bash

SERVER_COUNT=3

eval $(docker-machine env default)

for ((i=0; i<SERVER_COUNT; i++))
do
  docker stop consul$i
  docker rm consul$i
done

docker stop agent0
docker rm agent0
