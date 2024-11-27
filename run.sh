#!/bin/bash

# Allow connections to the X server
xhost +

# Run the DeepStream container
docker run --runtime nvidia -it --rm --gpus all \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    --name deepstream-alpr \
    deepstream-alpr

# Revoke connections to the X server
xhost -
