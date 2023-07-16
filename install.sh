#!/bin/bash
echo "WARNING !!!"
echo "this is a personal script mainly just meant for myself."
echo "it is also a work in progress."
echo "it could very well have issues with your setup."
echo "im not responsible if this script causes any damage."
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    echo "continuing..."
else
    echo "exiting script"
    exit 1
fi

echo "please partition your drive accordingly before continuing:"
echo "/dev/sda1 will be used for boot"
echo "/dev/sda2 will be used as swap"
echo "/dev/sda3 will be used for boot"
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

#make sure user actually has /dev/sda3 as a partition
lsblk | grep -q sda3
if [[ $? = 1 ]]
then
    echo "sda3 was not detected. you likely have not partitioned the drives properly."
    echo "exiting script"
    exit 1
fi

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
curl https://raw.githubusercontent.com/hitorigotoUwU/arch-installer/main/stage2.sh -o /tmp/stage2.sh
chmod +x /tmp/stage2.sh
cp stage2.sh /mnt/tmp

echo "attemtping to chroot and execute stage 2 ..."
arch-chroot /mnt /bin/bash curl https://raw.githubusercontent.com/hitorigotoUwU/arch-installer/main/stage2.sh -o /tmp/stage2.sh && chmod +x /tmp/stage2.sh && /tmp/stage2.sh