#!/bin/bash

# Check if a version parameter is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

version=$1

docker load -i cashkontrolleur_docker_image_"$version".tar

IMAGE_VERSION=$version docker-compose --env-file .env up -d