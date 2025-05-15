#!/bin/bash

# Script to build and run nuclei.io with GUI support
set -e  # Exit on error

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux system"
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS system"
    PLATFORM="macos"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Create data directory if it doesn't exist
mkdir -p data
echo "Created data directory"

# Build the Docker image
echo "Building Docker image..."
docker build -t nuclei-gui -f Dockerfile.gui .

# Enable X11 forwarding
if [[ "$PLATFORM" == "linux" ]]; then
    echo "Enabling X11 forwarding for Linux..."
    xhost +local:docker

    echo "Running nuclei.io with GUI on Linux..."
    docker run --rm -it \
      -v "$(pwd)/data:/app/data" \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -e DISPLAY="$DISPLAY" \
      --network=host \
      nuclei-gui
elif [[ "$PLATFORM" == "macos" ]]; then
    echo "For macOS, XQuartz must be installed and running"
    echo "Ensure you have allowed connections from network clients in XQuartz preferences"
    echo "Run the following command in a terminal before running this script:"
    echo "xhost +localhost"
    echo ""
    echo "Press Enter to continue once XQuartz is configured, or Ctrl+C to cancel"
    read

    echo "Running nuclei.io with GUI on macOS..."
    docker run --rm -it \
      -v "$(pwd)/data:/app/data" \
      -e DISPLAY=host.docker.internal:0 \
      nuclei-gui
fi