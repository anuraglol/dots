#!/usr/bin/env bash
# Restores suspend/wake fix for AMD laptops with spurious XHC wakeup sources.
# Run once after a fresh install.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Installing systemd service..."
sudo cp "$SCRIPT_DIR/disable-xhc-wakeup.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now disable-xhc-wakeup.service

echo ">>> Installing udev rule..."
sudo cp "$SCRIPT_DIR/99-disable-xhc-wakeup.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ">>> Verifying XHC wakeup status (all should be *disabled):"
cat /proc/acpi/wakeup | grep XHC

echo "Done. Reboot to confirm it persists."
