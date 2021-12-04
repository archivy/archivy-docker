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

* Docker.

You can check if Docker is installed by running

```sh
$ docker --version
Docker version 19.03.12, build 48a66213fe
```

If you don't have Docker installed, take a look at the [official installation guide](https://docs.docker.com/get-docker/) for your device.

* Docker-compose.

You can check if Docker-compose is installed by running

```sh
$ docker-compose --version
docker-compose version 1.12.0, build unknown
```

If you don't have Docker-compose installed, take a look at the [official installation guide](https://docs.docker.com/compose/install/) for your device.

# Setup

## Docker-Compose
1) Download `docker-compose.yml` or `docker-compose-light.yml` into the folder you want to use for Archivy (something like `~/docker/archivy`). Edit the compose file as needed for your network (host, port...). The default compose file (`docker-compose.yml`) is setup with Elasticsearch whereas the other one is more lightweight, using ripgrep for search. See [here](https://archivy.github.io/setup-search/) for more info on this.

2) In the folder from which you will start docker-compose, create a directory for persistent storage of your notes: `mkdir ./archivy_data`. 

3) (optional): Archivy has many [config options](https://archivy.github.io/config/) that allow you to finetune its behavior. If you want to define your own configuration, instead of using the [default ones we wrote for use with Docker](https://github.com/archivy/archivy-docker/blob/main/config.yml), create an `archivy_config` directory in the same directory as `archivy_data`. We recommend you at least build off the defaults.

Note: If your user ID is anything other than 1000 (you can check with the `id` command), you will need to change the owner of these directories to the 1000 UID and 1000 GID. Example: `chown -R 1000:1000 ./archivy_data`. 

3) Start the docker-compose stack with: `docker-compose up -d` or `docker-compose up -d -f docker-compose-lite.yml` for the lightweight option. If you're using your custom configuration, add `-f docker-compose.custom-config.yml` as an option to the preceding command.

## Application Setup

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

Note: Some plugins will require dependencies installed into the container (e.g. [archivy-hn](https://github.com/archivy/archivy-hn)). In such cases, follow the Docker installation instructions provided by the plugin maintainer. If none exist, open an issue. 

