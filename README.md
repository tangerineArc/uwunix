## Installation Guide

### 1. Boot from NixOS Live USB
Boot into the NixOS installer, connect to the internet and switch to the root user:
```sh
sudo su
```

### 2. Partition and format the disk
**NOTE**: Make sure to change `/dev/nvme0n1` to your actual disk.
```sh
# identify your disk using:
lsblk
# and set it as a variable:
DISK=/dev/nvme0n1
```

Assuming your target drive is `/dev/nvme0n1` (change accordingly if it's `/dev/sda`, etc.):
```sh
# create partition table and partitions
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 512MiB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary 512MiB 100%
```

**NOTE**: If using SATA (e.g., `/dev/sda`), change "p1" to "1" and so on.
```sh
# formatting partitions with exact labels
mkfs.fat -F 32 "${DISK}p1"
fatlabel "${DISK}p1" NIXBOOT
mkfs.ext4 -L NIXROOT "${DISK}p2"
```

### 3. Mount the partitions
```sh
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
```

### 4. Clone Dotfiles and Wake Daedalus
```sh
nix-shell -p git

git clone https://github.com/tangerineArc/uwunix.git labyrinth-setup
cd labyrinth-setup

./daedalus.sh
```

### 5. Post-Installation (Home Manager)
Once daedalus stops working, type `reboot`, remove your USB drive, and boot into your new state-of-the-art system.

Log in with your newly created user and password, open a terminal, and apply your Home Manager configuration:
```sh
cd ~/.dotfiles
nix run home-manager/master -- switch --flake .
```
