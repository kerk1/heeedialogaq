# syntax=docker/dockerfile:1
#build edumeet 
FROM node:16-bullseye-slim AS edumeet-builder
ARG BASEDIR
ARG EDUMEETSERVER
ARG NODE_ENV
ARG SERVER_DEBUG
ARG GIT_SERVER
ARG REPOSITORY
ARG BRANCHSERVER
ARG REACT_APP_DEBUG
WORKDIR ${BASEDIR}

#install app dependency
RUN apt-get update;DEBIAN_FRONTEND=noninteractive apt-get install -yq git bash jq build-essential python python3-pip openssl libssl-dev pkg-config mc net-tools;apt-get clean
#checkout code
RUN git clone --single-branch --branch ${BRANCHSERVER} ${GIT_SERVER}/${REPOSITORY}/${EDUMEETSERVER}.git
WORKDIR ${BASEDIR}/${EDUMEETSERVER}/server

ENV NODE_ENV ${NODE_ENV}
ENV REACT_APP_DEBUG=${REACT_APP_DEBUG}
RUN yarn install --production=false

RUN yarn run build

COPY configs/server/ dist/config

COPY certs/ certs/

# Web PORTS
EXPOSE 8002 
EXPOSE 40000-49999/udp

# run server 
ENV DEBUG ${SERVER_DEBUG}



COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# for testing 
#ENTRYPOINT ["tail", "-f", "/dev/null"]
