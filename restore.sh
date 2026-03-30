#!/bin/bash
set -e

DOTS="$HOME/Documents/dots"
BACKUP="$DOTS/system"

# --- 1. Clone dots ---
echo "→ Cloning dots repo..."
mkdir -p "$(dirname "$DOTS")"
git clone git@github.com:anuraglol/dots.git "$DOTS"

# --- 2. Stow ---
echo "→ Stowing config + bin..."
stow --dir="$DOTS" --target="$HOME" config bin

# --- 3. Pacman packages ---
echo "→ Installing pacman packages..."
sudo pacman -S --needed - < "$BACKUP/pkgs-pacman.txt"

# --- 4. AUR packages ---
echo "→ Installing AUR packages..."
# Install yay first if not present
if ! command -v yay &>/dev/null; then
  echo "  yay not found, installing..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi
yay -S --needed - < "$BACKUP/pkgs-aur.txt"

# --- 5. Flatpak packages ---
echo "→ Installing Flatpak packages..."
if ! command -v flatpak &>/dev/null; then
  sudo pacman -S --needed flatpak
fi
while read -r app; do
  flatpak install -y flathub "$app" || echo "  Skipping $app (not found)"
done < "$BACKUP/pkgs-flatpak.txt"

# --- 6. GNOME settings ---
echo "→ Restoring GNOME settings..."
dconf load / < "$BACKUP/gnome-settings.dconf"

# --- 7. systemd user services ---
echo "→ Enabling systemd user services..."
while read -r svc; do
  systemctl --user enable "$svc" || echo "  Skipping $svc"
done < "$BACKUP/systemd-user-services.txt"

systemctl --user daemon-reload

echo "All done. Reboot recommended."
