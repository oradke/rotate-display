
#!/bin/bash
set -Eeuo pipefail

# Installation paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_SCRIPT="$SCRIPT_DIR/rotate-display.sh"
SOURCE_SERVICE="$SCRIPT_DIR/rotate-display.service"

TARGET_SCRIPT="/usr/local/bin/rotate-display.sh"
TARGET_SERVICE="/etc/systemd/system/rotate-display.service"

# Require root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run this installer as root:"
    echo "sudo $0"
    exit 1
fi

# Check source files
for file in "$SOURCE_SCRIPT" "$SOURCE_SERVICE"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

echo "Installing display rotation script..."

install -o root -g root -m 0755 \
    "$SOURCE_SCRIPT" "$TARGET_SCRIPT"

echo "Installing systemd service..."

install -o root -g root -m 0644 \
    "$SOURCE_SERVICE" "$TARGET_SERVICE"

echo "Reloading systemd..."

systemctl daemon-reload

echo "Enabling display rotation service..."

systemctl enable rotate-display.service

echo
echo "Installation completed successfully."
echo
echo "Installed files:"
echo "  $TARGET_SCRIPT"
echo "  $TARGET_SERVICE"
echo
echo "The service will run automatically at the next boot."
echo
echo "To test it immediately, run:"
echo "  systemctl start rotate-display.service"
echo
echo "To check its status, run:"
echo "  systemctl status rotate-display.service"
