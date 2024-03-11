#!/bin/bash

target_image="thechristech/storj-exporter"

tag_a="latest"
tag_b="2.1.5"
docker buildx create --use --name multi-arch-builder
docker buildx build --platform linux/386,linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/arm/v8 --pull --rm -f "Dockerfile" -t "${target_image}:${tag_a}" -t "${target_image}:${tag_b}" "." --progress=plain --no-cache --push