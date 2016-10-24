#!/bin/bash -e

NAME='shibboleth-idp'
IMAGE_NAME='redwyvern/shibboleth-idp'
DATA_ROOT='/opt/docker-containers'
IDP_DATA="${DATA_ROOT}/${NAME}"

HOST_NAME=shibboleth-idp
NETWORK_NAME=dev_nw
AGENT_PORT=50000
WEB_PORT=8030

#mkdir -p "$IDP_DATA"

docker stop "${NAME}" 2>/dev/null && sleep 1
docker rm "${NAME}" 2>/dev/null && sleep 1
docker run --detach=true --name "${NAME}" --hostname "${HOST_NAME}" \
    --network=${NETWORK_NAME} \
    -p ${WEB_PORT}:8080 \
    ${IMAGE_NAME}
