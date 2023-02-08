#!/usr/bin/env bash

# This script pushes a Docker image to a repository.
#
# It takes a multi stage Dockerfile or its extension on the 1st argument,
# the target stage as the 2nd argument and the docker repository the as 
# 3nd argument. Optionally it can take a image name as 4nd argument if 
# you want to override the script name choice.
#
# If the extension is provided the script will search for a Dockerfile
# with that extension. It assumes that the extension will be after a dot
# like Dockerfile.<extension>.
#
# The stage refers to the build type like:
#   development
#   run
#
# The extension and stage are used to name the image, like:
#   <system>-<project>-<stage>
#   alpine-hook-development
#   alpine-hook-run
#
# The repository is used to push the image to a repository, like:
#   <repository>/<system>-<project>-<stage>
#   user/alpine-hook-development
#   user/alpine-hook-run
#
# Usage: ./docker_push.sh <Dockerfile|extension> <stage> <repository> [image_name]
#        ./docker_push.sh Dockerfile.alpine-hook run user
#        ./docker_push.sh alpine-hook run user
#        ./docker_push.sh alpine-hook development user test-bug-fix
#
if ! docker info &>/dev/null; then
    echo "ERROR: You must have the Docker installed and permission to run it."
    exit 1
fi

if [ ! -f ".env" ]; then
    echo "INFO: The .env file does not exist."
else
    echo "INFO: Loading the .env file."
    source .env
fi

ARGUMENT="$1"
STAGE="$2"
REPOSITORY_NAME="$3"
IMAGE_NAME="$4"

DOCKER_FILE="$ARGUMENT"

if [[ "$ARGUMENT" != Dockerfile* ]]; then
    DOCKER_FILE="Dockerfile.$ARGUMENT"
    echo "INFO: Using the 1st argument as Dockerfile extension: '$DOCKER_FILE'."
fi

if [[ ! -f "./$DOCKER_FILE" ]]; then
    echo "ERROR: This script must be run from the directory where the Dockerfile '$DOCKER_FILE' exists."
    exit 1
fi

EXTENSION="${DOCKER_FILE#Dockerfile.}"

if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME="$EXTENSION-$STAGE"
    echo \
        "INFO: Using '$IMAGE_NAME' as the Docker image name.
    You can specify a different name at (in order of priority):
    - the 4nd argument of this script:
        '$0 <Dockerfile|extension> <stage> <repository> [image_name]';
    - the IMAGE_NAME enviroment variable;
    - the .env file with a IMAGE_NAME variable."
fi

docker push "$REPOSITORY_NAME/$IMAGE_NAME:latest"
