#!/bin/bash
set -e

# Function to test X11 connectivity
test_x11() {
    if [ -z "$DISPLAY" ]; then
        echo "DISPLAY environment variable not set, defaulting to :0"
        export DISPLAY=:0
    fi
    
    echo "Testing X11 connection to $DISPLAY..."
    if ! xdpyinfo >/dev/null 2>&1; then
        echo "Error: Cannot connect to X server at $DISPLAY"
        echo "If running on Linux, make sure to:"
        echo "  1. Run 'xhost +local:docker' before starting the container"
        echo "  2. Mount the X11 socket with '-v /tmp/.X11-unix:/tmp/.X11-unix'"
        echo "  3. Set the DISPLAY variable with '-e DISPLAY=\$DISPLAY'"
        echo ""
        echo "If running on macOS:"
        echo "  1. Install XQuartz and enable 'Allow connections from network clients'"
        echo "  2. Run 'xhost +localhost' before starting the container"
        echo "  3. Set DISPLAY to host.docker.internal:0"
        echo ""
        echo "Falling back to Xvfb (no GUI will be visible)"
        exec xvfb-run --auto-servernum "$@"
    else
        echo "X11 connection successful. Starting application with GUI..."
        exec "$@"
    fi
}

# Run the test and execute command
test_x11 "$@"