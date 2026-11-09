# Raspberry Pi Display Rotation (Wayland / labwc)

A small systemd-based solution for automatically rotating displays on a Raspberry Pi running DietPi, Debian, or a similar Linux distribution using the **labwc Wayland compositor**.

The script detects connected displays and applies the configured rotation automatically during system startup. It supports both the standard HDMI output and DisplayLink USB graphics adapters.

## Concept

On a Wayland desktop using labwc, the traditional `xrandr` utility cannot be used to rotate displays. Instead, this project uses [`wlr-randr`](https://github.com/emersion/wlr-randr), a command-line utility for configuring Wayland outputs.

The solution consists of two files:

- `rotate-display.sh` – detects connected displays and applies the rotation.
- `rotate-display.service` – a systemd service that executes the script during boot.

The script checks for the following display outputs:

| Output | Description |
|---|---|
| `HDMI-A-1` | Standard Raspberry Pi HDMI output |
| `DVI-I-1` | DisplayLink USB graphics output |

If either or both outputs are detected, the script applies the configured rotation. It waits for the Wayland session and display outputs to become available, checking periodically for up to five minutes.

The systemd service runs once during startup. No continuously running background process is required.

## Requirements

- Raspberry Pi running Linux (tested with Raspberry Pi OS / DietPi).
- Wayland compositor: labwc.
- `wlr-randr` installed and available in the system PATH.
- A working Wayland session.
- For DisplayLink monitors, a correctly installed and functioning DisplayLink driver.

Check whether `wlr-randr` is available:

```bash
which wlr-randr
```

If it is not installed, install it using:

```bash
sudo apt update
sudo apt install wlr-randr
```

## Installation

Download or clone this repository:

```bash
git clone https://github.com/oradke/rotate-display.git
```

Change to the project directory:

```bash
cd rotate-display
```

Make the installation script executable:

```bash
chmod +x install.sh
```

Run the installer:

```bash
sudo ./install.sh
```

The installer performs the following operations:

1. Copies `rotate-display.sh` to `/usr/local/bin/`.
2. Copies `rotate-display.service` to `/etc/systemd/system/`.
3. Reloads the systemd configuration.
4. Enables the service for automatic execution during boot.

The display will be rotated automatically after the next reboot.

To test the configuration immediately without rebooting:

```bash
sudo systemctl start rotate-display.service
```

Check the service status:

```bash
sudo systemctl status rotate-display.service
```

View the service log:

```bash
sudo journalctl -u rotate-display.service
```

A successful execution should show messages similar to:

```text
Waiting for Wayland and display outputs...
Found HDMI-A-1
Successfully rotated HDMI-A-1
```

## Changing the rotation

The default configuration rotates displays by **90 degrees clockwise**.

To use a different rotation, edit the installed script:

```bash
sudo nano /usr/local/bin/rotate-display.sh
```

Find this line:

```bash
wlr-randr --output "$DISPLAY" --transform 90
```

Change the number according to the desired orientation:

| Transform | Orientation |
|---|---|
| `normal` | Landscape, no rotation |
| `90` | 90° clockwise |
| `180` | Upside down |
| `270` | 90° counterclockwise |

For example, to rotate the display by 180 degrees:

```bash
wlr-randr --output "$DISPLAY" --transform 180
```

For 270 degrees:

```bash
wlr-randr --output "$DISPLAY" --transform 270
```

Save the file and reboot:

```bash
sudo reboot
```

Alternatively, test the new rotation immediately:

```bash
sudo systemctl restart rotate-display.service
```

**Note:** The rotation setting is applied to every detected output listed in the script. If you only want to rotate one particular display, remove the other output name from the `for DISPLAY in HDMI-A-1 DVI-I-1` line.

## Removing the installation

To remove the service and its installed files, run:

```bash
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The uninstaller:

1. Stops the running service.
2. Disables automatic startup.
3. Removes `/usr/local/bin/rotate-display.sh`.
4. Removes `/etc/systemd/system/rotate-display.service`.
5. Reloads systemd.

The original files in the repository directory are not deleted.

## Troubleshooting

**The display does not rotate after reboot**

Check the service status:

```bash
sudo systemctl status rotate-display.service
```

Inspect its log:

```bash
sudo journalctl -u rotate-display.service -b
```

**Check the available display outputs**

Run the following commands as the user running the Wayland session (in this setup, `dietpi`):

```bash
export XDG_RUNTIME_DIR=/tmp/labwc
export WAYLAND_DISPLAY=wayland-0

wlr-randr
```

Make sure the output names match those used in `rotate-display.sh`.

**Test rotation manually**

For HDMI:

```bash
XDG_RUNTIME_DIR=/tmp/labwc WAYLAND_DISPLAY=wayland-0 \
wlr-randr --output HDMI-A-1 --transform 90
```

For DisplayLink:

```bash
XDG_RUNTIME_DIR=/tmp/labwc WAYLAND_DISPLAY=wayland-0 \
wlr-randr --output DVI-I-1 --transform 90
```

If manual rotation works but automatic rotation does not, check the systemd service logs and verify that the service is enabled:

```bash
sudo systemctl is-enabled rotate-display.service
```

## License

This project is provided as-is. You are free to modify and adapt it to your own Raspberry Pi display setup.
