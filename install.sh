#!/bin/bash
echo "WARNING !!!"
echo "this is a personal script mainly just meant for myself."
echo "it could very well have issues with your setup."
echo "im not responcible if this script causes any damage."
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    echo "continuing..."
else
    echo "exiting script"
    exit 1
fi

echo "please format your drive accordingly before continuing:"
echo "dev/sda1 = boot"
echo "dev/sda2 = swap"
echo "dev/sda3 = boot"
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    echo "continuing..."
else
    echo "exiting script"
    exit 1
fi

echo "formatting drives ..."
mkfs.ext4 /dev/sda3
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2

echo "mounting drives ..."
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
swapon /dev/sda2

echo "would you like to install nvidia drivers? (y/n)"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    echo "pacstrapping stuff w/ nvidia ..."
    pacstrap -K /mnt linux linux-firmware base base-devel grub efibootmgr iwd dhcpcd vim hyfetch git nvidia-dkms linux-headers --noconfirm
else
    echo "pacstrapping stuff  ..."
    pacstrap -K /mnt linux linux-firmware base base-devel grub efibootmgr iwd dhcpcd vim hyfetch git --noconfirm
fi

echo "creating the fstab ..."
genfstab -U /mnt >> /mnt/etc/fstab

# prepare for chroot
mkdir -p /mnt/tmp
curl https://raw.githubusercontent.com/hitorigotoUwU/arch-installer/main/part2.sh -o /mnt/tmp/install-part2.sh
chmod +x /mnt/tmp/install-part2.sh

echo "chrooting ..."
arch-chroot /mnt /bin/bash /tmp/install-part2.sh