#!/bin/bash

# Allow connections to the X server
xhost +

# Define paths to AWS IoT certificates (adjust paths if they differ in your setup)
CERT_DIR=/path/to/aws-certificates

# Run the DeepStream container
docker run --runtime nvidia -it --rm --gpus all \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $CERT_DIR:/app/aws-certificates:ro \
    -e DISPLAY=$DISPLAY \
    --name deepstream-alpr \
    deepstream-alpr

# Revoke connections to the X server
xhost -
