# consulcluster
A simple example of using [Docker](https://www.docker.com) to create a local [Consul](https://www.consul.io) cluster for testing and development purposes. The intention is to be able to run a production-like cluster on a local development machine, although it should be noted that the cluster (currently) does not persist any state.

The Docker invocations pull the *latest* Consul image from [Docker Hub](https://hub.docker.com/_/consul/), which at the time of my doing this work was v0.6.4.

## Building

There is no build required, however there are certain pre-requisites:

* you have Docker installed and are interacting via *docker-machine*;
* the *default* Docker Machine is running;
* port 8500 is available in the host environment.

Please harrass me if you cannot get this working due to deficiencies in this documentation!

## Use

To start the cluster, assuming it's not already running:

    ./start.sh

This will launch a Consul cluster consisting of 3 server nodes and a single agent node. It is intended that interactions with the cluster are done via this agent node.

Note that after launching the Docker containers, this does some simple smoke tests of the state of the cluster, and finally reports the apparent address of the agent, e.g.:

    ==== consul agent location ====
    http://192.168.99.100:8500

Which means that you can call the API from your host environment, e.g.:

    http://192.168.99.100:8500/v1/catalog/nodes?pretty
    
DNS resolution via the agent is enabled, but is not included in the smoke tests. If you have *dig* or similar, you can explore resolution doing something like

    dig @192.168.99.100 consul.service.consul
    
Similarly other containers can use the agent for resolution (here I am using *alpine* to dig into the resolution)

    docker run -it --rm --dns 192.168.99.100 alpine nslookup consul.service.consul

To stop the cluster, assuming it's running:

    ./stop.sh

## Logging
The Consul agents inside the container are using their default logging configuration, and so are just writing to *stdout* and *stderr*, thus exposing the logs to the *docker logs* command:

    docker logs consul0
    docker logs -f agent0