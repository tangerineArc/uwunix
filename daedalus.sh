#! /usr/bin/env bash
set -e

echo "[daedalus] started working"

read -p "[daedalus] enter username: " USERNAME
read -p "[daedalus] enter hostname: " HOSTNAME
read -p "[daedalus] enter full name for Git: " GIT_NAME
read -p "[daedalus] enter email for Git: " GIT_EMAIL

sed -i "s/user = \"[^\"]*\"/user = \"$USERNAME\"/" flake.nix
sed -i "s/host = \"[^\"]*\"/host = \"$HOSTNAME\"/" flake.nix
sed -i "s/gitName = \"[^\"]*\"/gitName = \"$GIT_NAME\"/" flake.nix
sed -i "s/gitEmail = \"[^\"]*\"/gitEmail = \"$GIT_EMAIL\"/" flake.nix
echo "[daedalus] updated flake.nix with User: $USERNAME, Host: $HOSTNAME and Git profile"

echo "[daedalus] generating hardware-configuration.nix..."
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

echo "[daedalus] copying dotfiles to permanent storage..."
TARGET_DIR="/mnt/home/$USERNAME/.dotfiles"
mkdir -p "/mnt/home/$USERNAME"
cp -r . "$TARGET_DIR"

echo "[daedalus] installing nixos..."
nixos-install --flake "$TARGET_DIR#$HOSTNAME"

echo "[daedalus] set password for $USERNAME >>>"
nixos-enter --root /mnt -c "passwd $USERNAME"

echo "[daedalus] granting $USERNAME basic rights..."
nixos-enter --root /mnt -c "chown -R $USERNAME:users /home/$USERNAME"

echo "[daedalus] finished installation"
echo "[daedalus] stopped working"
