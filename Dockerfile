# ========================================================================
# Hyperscan - Alpine 3.8 Based Image
# ---------------------------------------
#
# Build Image:
#
#     >>> docker build -t sniperkit/repology:latest-alpine3.8 --build-arg REPOLOGY_VERSION=master .
#     >>> docker build -t sniperkit/repology:latest-alpine3.8 .
#
# Run Image:
#
#     >>> docker run -ti sniperkit/repology:dev-alpine3.8 bash
#     >>> docker run -ti sniperkit/repology:api-latest-alpine3.8
#
# ========================================================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Stage 1 - Create layer  with access to alpine edge packages
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------------------------------------
# Layer Name: repologyBase
# ----------------------------------------------------------------------------------------------------
FROM alpine:3.8 as repologyBase
LABEL maintainer="Rosco Pecoltran <sniperkit@protonmail.com>"

ARG ALPINE_VERSION=${ALPINE_VERSION:-"3.8"}

RUN \
    echo "http://nl.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
    && echo "@edge http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Stage 2 - Create layer for compiling dependencies
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------------------------------------
# Layer Name: repologyBuilder
# ----------------------------------------------------------------------------------------------------
FROM repologyBase as repologyBuilder

LABEL maintainer="Rosco Pecoltran <sniperkit@protonmail.com>"
LABEL description="Compare package versions in many repositories https://repology.org"

WORKDIR /usr/local/searx

RUN adduser -D -h /usr/local/repology -s /bin/sh repology repology

# COPY requirements.txt ./requirements.txt

RUN echo "@commuedge http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    \
    && apk add -U --no-cache --no-progress build-base \
            python python-dev py-pip libffi-dev tini@commuedge openssl openssl-dev ca-certificates \
            libxml2 libxml2-dev libxslt libxslt-dev \
            bash nano tree \
            \
            && pip install --no-cache -r requirements.txt \
                \
                && apk del build-base python-dev libffi-dev openssl-dev libxslt-dev libxml2-dev openssl-dev ca-certificates \
                && rm -f /var/cache/apk/*

COPY . .

CMD ["bash"]


