#!/bin/bash

# Exit the script immediately if any command fails
set -e

# Name of the image you want to build
IMAGE_NAME="deepstream-alpr"

# Build the Docker container
echo "Building Docker image: $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

# Automatically remove dangling images
echo "Removing dangling images..."
docker image prune -f

echo "Build and cleanup complete!"

