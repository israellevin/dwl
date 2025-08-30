#!/bin/bash -e
mkdir -p /usr/local/{include,lib/x86_64-linux-gnu,share/{man,wayland-sessions}}/
docker build . -t dwl-builder
docker run --rm --name dwl -dp 80:8000 dwl-builder
curl localhost | tar -xC /
ldconfig
