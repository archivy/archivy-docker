# Guide to using Archivy with Docker

This document contains enough information to help you get started with using Archivy as
a container, in this case, with Docker(although you can use any other container runtime).

This document will cover the following:

- [x] [Prerequisites](#prerequisites)
- [x] [Running Archivy](#running-archivy)
  - [x] [Via Docker-Compose](#via-docker-compose-recommended)
  - [x] [Via Docker Run](#via-docker-run-not-recommended)
  - [x] [Application Setup](#application-setup)
- [x] [Installing Plugins](#installing-plugins)

> **NOTE**:
> Parts of the document may be incomplete as it is a work in progress. In time, more information will be added to each section/topic. If some part of the documentation is ambiguous, feel free to ask questions or make suggestions on the Issues page of the project. If necessary, additional revisions to the documentation can be made based on user feedback.



## Prerequisites

* Docker needs to be installed.

You can check if Docker is installed by running

```sh
$ docker --version
Docker version 19.03.12, build 48a66213fe
```

If you don't have Docker installed, take a look at the [official installation guide](https://docs.docker.com/get-docker/) for your device.

* Docker-compose can also be installed for easier deployment.

You can check if Docker-compose is installed by running

```sh
$ docker-compose --version
docker-compose version 1.12.0, build unknown
```

If you don't have Docker-compose installed, take a look at the [official installation guide](https://docs.docker.com/compose/install/) for your device.

## Archivy Setup

### Via Docker-Compose (Recommended)

1) Download `docker-compose.yml` into the folder you want to use for Archivy (something like `~/docker/archivy`). Edit the compose file as needed for your network. 

2) In the folder from which you will start docker-compose, create a directory for persistent storage of your notes: `mkdir ./archivy_data`. 

Note: If your user ID is anything other than 1000 (you can check with the `id` command), you will need to change the owner of the directory to the 1000 UID and 1000 GID: `chown -R 1000:1000 ./archivy_data`. 
Both the Elasticsearch and Archivy containers also need persistent configuration volumes, but this is handled by docker-managed volumes by default. 

Note: If you want to use a direct host filesystem mount for the Archivy config files, you will need to copy the `config.yml` from this directory into that directory before bringing the stack up.

3) Start the docker-compose stack with: `docker-compose up -d`.

### Via Docker Run (Not Recommended)

If you opt not to install or use Docker-Compose, you can instead use the following commands:

1) Create the network to which both the Elasticsearch and Archivy containers will connect.

```
docker network create archivy
```

2) Navigate to the folder in which you would like to store your Archivy notes. Then create the necessary host directories with `mkdir ./archivy_data`. 

Note: If your user ID is anything other than 1000 (you can check with the `id` command), you will need to change the owner of the directory to the 1000 UID and 1000 GID: `chown -R 1000:1000 ./archivy_data`. 

3) Create and start your elasticsearch instance, which will act as the search backend for your Archivy database:
```
docker run -d \
--name elasticsearch \
-v elasticsearch_data:/usr/share/elasticsearch/data \
-e discovery.type=single-node \
elasticsearch:7.9.0
``` 
Because both Elasticsearch and Archivy will be on the same internal Docker network, you do not need to publish any ports.

4) Bring up the Archivy instance. 

```
docker run -d \
--name archivy \
-p 5000:5000 \
-e FLASK_DEBUG=0 \
-e ELASTICSEARCH_ENABLED=1 \
-e ELASTICSEARCH_URL=http://elasticsearch:9200/ \
-v ./archivy_data:/archivy/data \
-v archivy_config:/archivy/.local/share/archivy \
--network archivy \
uzayg/archivy:latest 
```

5) Connect the Elasticsearch instance to the archivy network with the `elasticsearch` network alias.

```
docker network connect --alias elasticsearch archivy elasticsearch
```

Done!

### Application Setup

You should now be able to access your Archivy installation at `http://<your-docker-host>:5000` where <your-docker-host> is the IP of the machine running your Docker environment. 

However, the base installation has no users, so you will be unable to log in. 

To create a new admin, run:

`docker exec -it archivy archivy create-admin --password <your-password> <your-username>`

  * `docker exec -it archivy` tells Docker to execute a command on the archivy container with an interactive pseudo-TTY. Read more [here](https://docs.docker.com/engine/reference/commandline/exec/).
  * `archivy create-admin --password <your-password> <your-username>` is the command run by docker which creates a new admin account with the password and username provided.

Congratulations! You can now log into your new Archivy instance (complete with search and persistent data) with the credentials you created above. Happy archiving!

## Installing Plugins

To install plugins into your Dockerized Archivy instance, you can simply run `pip` inside the container. For example:

`docker exec archivy pip install archivy_git` to install the [archivy-git](https://github.com/archivy/archivy-git) plugin. 

**NOTE**: Plugins will persist as long as the container's system volume does. If you turn off your Archivy instance `docker-compose down`, you will destroy the container's system volume. Turning off your Archivy instance with `docker container stop archivy` will not cause this issue. 

Note: Some plugins will require depencies installed into the container (e.g. [archivy-hn](https://github.com/archivy/archivy-hn)). In such cases, follow the Docker installation instructions provided by the plugin maintainer. If none exist, open an issue. 

