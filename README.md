# Guide to using Archivy with Docker

This document contains enough information to help you get started with using Archivy as
a container, in this case, with Docker(although you can use any other container runtime).

This document will cover the following:

- [x] [Prerequisites](#prerequisites)
- [x] [Building Archivy](#building-archivy)
  - [x] [Cloning this repository](#cloning-this-respository)
  - [x] [Optional: Configure your Installation](#optional-configure-your-installation)
- [x] [Running Archivy](#running-archivy)
  - [x] [Quick Start](#quick-start)

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


## Building Archivy

### Cloning this repository

Before you can build the Dockerfile, you will need to clone this repository into the directory you want to contain your Archivy installation. It is recommended that you create a directory for Archivy before cloning the repository (something like `~/docker/archivy/`). Run the following command to clone the repository:

```sh
git clone https://github.com/archivy/archivy-docker.git
```

This will clone the git respository hosted at `https://github.com/archivy/archivy-docker` into the `./archivy-docker` folder relative to your current working directory. 

### (Optional) Configure your installation

After cloning, you can make changes to the `docker-compose.yml` to tailor it to your environment. **Note:** Make sure to update the `VERSION=` build argument in the `docker-compose.yml` file to whichever 

* `docker-compose.yml` contains the instructions Docker will use to create your containers. 

```yml
version: '3'

services:

  archivy:
    build:
      context: .
      args: 
        -VERSION=0.11.1 # update this to whatever the latest release of Archivy is
    container_name: archivy
#   networks: # If you are using a reverse proxy, you will need to edit this file to add Archivy to your reverse proxy network. You can also remove the host-to-container port mapping, as that should be handled by the reverse proxy
    ports:
      - 5000:5000 # this is a host-to-container port mapping. If your Docker environment already uses the host's port `:5000`, then you can remap this to any `<port>:5000` you need
    environment:
      - FLASK_DEBUG=0 # this sets the level of verbosity printed to the Archivy container's logs
      - ELASTICSEARCH_ENABLED=1 # this sets whether the container should check if an Elasticsearch container is running before it attempts to start the Archivy server. Note: This *does not* check whether the elasticsearch server is working properly, only if an Elasticsearch container is working. Further, this setting is overridden by the contents of `config.yml`
      - ELASTICSEARCH_URL=http://elasticsearch:9200/ # sets the URL that the `entrypoint.sh` script should use to check for a running Elasticsearch container
    volumes:
      - archivy_data:/archivy:rw # this looks for a Docker volume on the host called `archivy_data` and mounts it into the container's `/archivy` directory. You can change the name of the Docker volume on the host, but not the mount path
  elasticsearch:
    image: elasticsearch:7.9.0
    container_name: elasticsearch
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    environment:
      - "discovery.type=single-node"

volumes:
  archivy_data: # this creates the archivy_data volume that we call for under services/archivy/volumes:
  elasticsearch_data: # this creates the elasticsearch_data volume that we call for under services/archivy/volume:
```

After you've edited the `docker-compose.yml` file to your liking, you're ready to start Archivy.

## Running Archivy

### Quick Start

After completing the steps in the Building Archivy section, you are ready to start your Archivy server.

To start the docker-compose stack, simply run the following in the directory containing the docker-compose file:

`docker-compose up -d`

You should now be able to access your Archivy installation at `http://<your-docker-host>:5000` where <your-docker-host> is the IP of the machine running your Docker environment. 

However, the base installation has no users, so you will be unable to log in. 

To create a new admin, run:

`docker exec -it archivy archivy create-admin --password <your-password> <your-username>`

  * `docker exec -it archivy` tells Docker to execute a command on the archivy container with an interactive pseudo-TTY. Read more [here](https://docs.docker.com/engine/reference/commandline/exec/).
  * `archivy create-admin --password <your-password> <your-username>` is the command run by docker which creates a new admin account with the password and username provided.

Congratulations! You can now log into your new Archivy instance (complete with search and persistent data) with the credentials you created above. Happy archiving!

# Contributors

- @HarshaVardhanJ - Creator and maintainer of the image
