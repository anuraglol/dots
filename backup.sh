#!/bin/bash
set -e

DOTS="$HOME/Documents/dots"
BACKUP="$DOTS/system"

mkdir -p "$BACKUP"

echo "→ Pacman explicit packages..."
pacman -Qqen > "$BACKUP/pkgs-pacman.txt"

echo "→ AUR packages..."
pacman -Qqem > "$BACKUP/pkgs-aur.txt"

echo "→ Flatpak packages..."
flatpak list --app --columns=application > "$BACKUP/pkgs-flatpak.txt"

echo "→ GNOME gsettings..."
dconf dump / > "$BACKUP/gnome-settings.dconf"

echo "→ systemd user services..."
systemctl --user list-unit-files --state=enabled --no-legend \
  | awk '{print $1}' > "$BACKUP/systemd-user-services.txt"

echo "Done."
