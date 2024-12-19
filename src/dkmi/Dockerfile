FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    opendkim \
    opendkim-tools \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8891