#!/bin/bash -e

NAME='shibboleth-idp'
IMAGE_NAME='redwyvern/shibboleth-idp'
DATA_ROOT='/opt/docker-containers'
IDP_DATA="${DATA_ROOT}/${NAME}"

HOST_NAME=shibboleth-idp
NETWORK_NAME=dev_nw
WEB_PORT=8030
AJP_PORT=8009

#mkdir -p "$IDP_DATA"

docker stop "${NAME}" 2>/dev/null && sleep 1
docker rm "${NAME}" 2>/dev/null && sleep 1
docker run --detach=true --name "${NAME}" --hostname "${HOST_NAME}" \
    --network=${NETWORK_NAME} \
    -p ${WEB_PORT}:8080 \
    -p ${AJP_PORT}:8009 \
    ${IMAGE_NAME}
