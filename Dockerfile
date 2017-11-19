FROM tomcat:8.0.38
MAINTAINER Nick Weedon <nick@weedon.org.au>

# The timezone for the image (set to Etc/UTC for UTC)
ARG IMAGE_TZ=America/New_York

USER root
RUN echo ${IMAGE_TZ} > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

ARG IDP_HOST_NAME=idp
ARG IDP_DOMAIN_NAME=weedon.int

# TODO: Fix security issue
ARG BACKCHANNEL_PKCS12_PASSWORD=password
ARG COOKIE_ENCRYPTION_KEY_PASSWORD=password
ARG SHIBBOLETH_VERSION=3.3.2

COPY conf/server.xml /usr/local/tomcat/conf/server.xml

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    curl

COPY merge.properties /tmp/merge.properties

RUN sed -i "s/==IDP_HOST_NAME==/${IDP_HOST_NAME}/g" /tmp/merge.properties && \
    sed -i "s/==IDP_DOMAIN_NAME==/${IDP_DOMAIN_NAME}/g" /tmp/merge.properties

RUN cd /opt && \
    echo Downloading Shibboleth IDP v${SHIBBOLETH_VERSION} software package... && \
    curl -s -O https://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-${SHIBBOLETH_VERSION}.tar.gz && \
    tar -xzf shibboleth-identity-provider-${SHIBBOLETH_VERSION}.tar.gz && rm shibboleth-identity-provider-${SHIBBOLETH_VERSION}.tar.gz && \
    cd /opt/shibboleth-identity-provider-${SHIBBOLETH_VERSION}/bin && ./install.sh \
      -Didp.src.dir=/opt/shibboleth-identity-provider-${SHIBBOLETH_VERSION} \
      -Didp.target.dir=/opt/shibboleth-idp \
      -Didp.host.name=${IDP_HOST_NAME}.${IDP_DOMAIN_NAME} \
      -Dentityid=https://${IDP_HOST_NAME}.${IDP_DOMAIN_NAME}/idp/shibboleth \
      -Didp.scope=${IDP_DOMAIN_NAME} \
      -Didp.keystore.password=$BACKCHANNEL_PKCS12_PASSWORD \
      -Didp.sealer.password=$COOKIE_ENCRYPTION_KEY_PASSWORD \
      -Didp.merge.properties=/tmp/merge.properties && \
    cd /opt && rm -r shibboleth-identity-provider-${SHIBBOLETH_VERSION} && \
    mv /opt/shibboleth-idp/war/idp.war /usr/local/tomcat/webapps

