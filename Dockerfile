#/######    Dockerfile for Archivy Built On Alpine Linux     ########
#                                                                   #
#####################################################################
#        CONTAINERISED ARCHIVY BUILT ON TOP OF ALPINE LINUX         #
#####################################################################
#                                                                   #
# This Dockerfile does the following:                               #
#                                                                   #
#    1. Starts with a base image of Python3.9 built on Debian       #
#       Buster Slim to be used as builder stage. (then replaced     #
#       with Alpine 3.9 (some dependencies fail otherwise (brotli)) #
#    2. Pins a version of archivy.                                  #
#    3. Installs Archivy using pip in the /install directory.       #
#    4. Creates a non-root user account and group which will be     #
#       used to run run Archivy, creates the directory which        #
#       Archivy uses to store its data.                             #
#    5. The ownership of all copied files is set to                 #
#       archivy user and group.                                     #
#    6. Creates a mount point so that external volumes can be       #
#       mounted/attached to it. Useful for data persistence.        #
#    7. Exposes port 5000 on the container.                         #
#    8. Runs archivy                                                #
#####################################################################



# Starting with base image of python3.9 built on Debian Buster Slim
FROM python:3.9-slim AS builder
# Installing pinned version of Archivy using pip
# Archivy version
ARG VERSION
RUN pip3.9 install --prefix=/install archivy==$VERSION

FROM python:3.9-alpine

# ARG values for injecting metadata during build time
# NOTE: When using ARGS in a multi-stage build, remember to redeclare
#       them for the stage that needs to use it. ARGs last only for the
#       lifetime of the stage that they're declared in.
ARG BUILD_DATE
ARG VCS_REF

# Archivy version
ARG VERSION
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update && apk add --no-cache \
        build-base \
		ripgrep \
		libxml2 \
		libxslt

    # Creating non-root user and group for running Archivy
    && addgroup -S -g 1000 archivy \
    && adduser -h /archivy -g "User account for running Archivy" \
    -s /sbin/nologin -S -D -G archivy -u 1000 archivy \
    # Creating directory in which Archivy's files will be stored
    # (If this directory isn't created, Archivy exits with a "permission denied" error)
    && mkdir -p /archivy/data \
    && mkdir -p /archivy/.local/share/archivy \
    # Changing ownership of all files in user's home directory
    && chown -R archivy:archivy /archivy

COPY --from=builder --chown=archivy:archivy /install /usr/local/
# Copying pre-generated config.yml from host
COPY --chown=archivy:archivy entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY --chown=archivy:archivy config.yml /archivy/.local/share/archivy/config.yml

# Run as user 'archivy'
USER archivy

# Exposing port 5000
EXPOSE 5000

# System call signal that will be sent to the container to exit
STOPSIGNAL SIGTERM

ENTRYPOINT ["entrypoint.sh"]

# The 'run' CMD is required by the 'entrypoint.sh' script to set up the Archivy server. 
# Any command given to the 'docker container run' will override the CMD below.
CMD ["run"]

# Labels
LABEL org.opencontainers.image.vendor="Uzay G" \
      org.opencontainers.image.authors="https://github.com/Uzay-G" \
      org.opencontainers.image.title="Archivy" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/archivy/archivy-docker" \
      org.label-schema.vcs-url="https://github.com/archivy/archivy-docker" \
      org.opencontainers.image.documentation="https://github.com/archivy/archivy-docker/" \
      org.opencontainers.image.source="https://github.com/archivy/archivy-docker/blob/main/Dockerfile" \
      org.opencontainers.image.description="Archivy is a self-hosted knowledge repository that \
      allows you to safely preserve useful content that contributes to your knowledge bank." \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.build-date=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.version=$VERSION \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      software.author.repository="https://github.com/archivy/archivy" \
      software.release.version=$VERSION
