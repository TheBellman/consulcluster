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

    $ ./start.sh 
    ==== creating encryption key ====
    ==== starting servers ====
    63672c755b067e3406f8fe60836be37fc9dcac1dbe61263ee5d870d5f10f4443
    677eba0496049dc03cc20a1fe594589e437b5940117e61c62964de4d793476d2
    1ea9f048753e4a0aa289d8b35cc0ee6318de24f9bcb60c768fbfa0ec2a38e11e
    ==== starting agent ====
    8b0ce0566abf3054aac8c1f07a6a7b5f9d4f60bd0fa7a051723adc9176494f55
    ==== pausing ====
    ==== docker processes ====
    NAMES               STATUS              PORTS
    agent0              Up 2 seconds        8300-8302/tcp, 8400/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, 192.168.99.100:53->8600/tcp, 192.168.99.100:53->8600/udp
    consul2             Up 2 seconds        8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp
    consul1             Up 2 seconds        8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp
    consul0             Up 2 seconds        8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp
    ==== consul members ====
    Node     Address          Status  Type    Build  Protocol  DC
    agent0   172.17.0.5:8301  alive   client  0.6.4  2         dc1
    consul0  172.17.0.2:8301  alive   server  0.6.4  2         dc1
    consul1  172.17.0.3:8301  alive   server  0.6.4  2         dc1
    consul2  172.17.0.4:8301  alive   server  0.6.4  2         dc1
    ==== consul node catalog ====
    [
        {
            "Node": "agent0",
            "Address": "172.17.0.5",
            "TaggedAddresses": null,
            "CreateIndex": 6,
            "ModifyIndex": 6
        },
        {
            "Node": "consul0",
            "Address": "172.17.0.2",
            "TaggedAddresses": null,
            "CreateIndex": 3,
            "ModifyIndex": 3
        },
        {
            "Node": "consul1",
            "Address": "172.17.0.3",
            "TaggedAddresses": {
                "wan": "172.17.0.3"
            },
            "CreateIndex": 4,
            "ModifyIndex": 7
        },
        {
            "Node": "consul2",
            "Address": "172.17.0.4",
            "TaggedAddresses": null,
            "CreateIndex": 5,
            "ModifyIndex": 5
        }
    ]
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