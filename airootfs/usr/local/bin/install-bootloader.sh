#!/bin/bash

# Detect boot mode
if [ -d /sys/firmware/efi ]; then
    # UEFI mode
    echo "Installing GRUB for UEFI..."
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
else
    # BIOS mode
    echo "Installing GRUB for BIOS..."
    # Get the disk (not partition) from the mounted root
    ROOT_DISK=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /))
    grub-install --target=i386-pc --recheck /dev/$ROOT_DISK
fi

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
