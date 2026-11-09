#!/bin/bash

export HOME=/home/labwc
export XDG_RUNTIME_DIR=/tmp/labwc
export WAYLAND_DISPLAY=wayland-0

echo "Waiting for Wayland and display outputs..."

for i in $(seq 1 150); do

    OUTPUTS=$(wlr-randr 2>/dev/null)

    if [ -n "$OUTPUTS" ]; then
        ROTATED=0

        for DISPLAY in HDMI-A-1 DVI-I-1; do
            if echo "$OUTPUTS" | grep -q "^${DISPLAY} "; then
                echo "Found $DISPLAY"

                if wlr-randr --output "$DISPLAY" --transform 90; then
                    echo "Successfully rotated $DISPLAY"
                    ROTATED=1
                fi
            fi
        done

        if [ "$ROTATED" -eq 1 ]; then
            exit 0
        fi
    fi

    sleep 2
done

echo "ERROR: No suitable display found after 5 minutes"
exit 1
