FROM tomcat:8.0.38
MAINTAINER Nick Weedon <nick@weedon.org.au>

# The timezone for the image (set to Etc/UTC for UTC)
ARG IMAGE_TZ=America/New_York

USER root
RUN echo ${IMAGE_TZ} > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

ARG IDP_HOST_NAME=shibboleth-idp
ARG IDP_DOMAIN_NAME=localdomain

# TODO: Fix security issue
ARG BACKCHANNEL_PKCS12_PASSWORD=password
ARG COOKIE_ENCRYPTION_KEY_PASSWORD=password

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    curl

COPY merge.properties /tmp/merge.properties

RUN sed -i "s/==IDP_HOST_NAME==/${IDP_HOST_NAME}/g" /tmp/merge.properties && \
    sed -i "s/==IDP_DOMAIN_NAME==/${IDP_DOMAIN_NAME}/g" /tmp/merge.properties

RUN cd /opt && \
    echo Downloading Shibboleth IDP software package... && \
    curl -s -O https://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-3.2.1.tar.gz && \
    tar -xzf shibboleth-identity-provider-3.2.1.tar.gz && \
    cd /opt/shibboleth-identity-provider-3.2.1/bin && \
    ./install.sh \
      -Didp.src.dir=/opt/shibboleth-identity-provider-3.2.1 \
      -Didp.target.dir=/opt/shibboleth-idp \
      -Didp.host.name=${IDP_HOST_NAME}.${IDP_DOMAIN_NAME} \
      -Dentityid=https://${IDP_HOST_NAME}.${IDP_DOMAIN_NAME}/idp/shibboleth \
      -Didp.scope=${IDP_DOMAIN_NAME} \
      -Didp.keystore.password=$BACKCHANNEL_PKCS12_PASSWORD \
      -Didp.sealer.password=$COOKIE_ENCRYPTION_KEY_PASSWORD \
      -Didp.merge.properties=/tmp/merge.properties

      
