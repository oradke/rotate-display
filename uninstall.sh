
#!/bin/bash
set -Eeuo pipefail

SERVICE="rotate-display.service"
TARGET_SCRIPT="/usr/local/bin/rotate-display.sh"
TARGET_SERVICE="/etc/systemd/system/$SERVICE"

# Require root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run this uninstaller as root:"
    echo "sudo $0"
    exit 1
fi

echo "Stopping display rotation service..."

systemctl disable --now "$SERVICE" 2>/dev/null || true

echo "Removing installed files..."

rm -f "$TARGET_SCRIPT"
rm -f "$TARGET_SERVICE"

echo "Reloading systemd..."

systemctl daemon-reload
systemctl reset-failed "$SERVICE" 2>/dev/null || true

echo
echo "Uninstallation completed successfully."
echo "Removed:"
echo "  $TARGET_SCRIPT"
echo "  $TARGET_SERVICE"
echo
echo "The display rotation service will no longer run at boot."
