#!/bin/bash
echo "WARNING !!!"
echo "this is a personal script mainly just meant for myself."
echo "it could very well have issues with your setup."
echo "im not responcible if this script causes any damage."
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

if [ $CONFIRMATION = "y"]
    echo "continuing..."
else
    echo "exiting script"
    exit 1
fi

echo "please format your drive accordingly before continuing:"
echo "dev/sda1 = boot"
echo "dev/sda2 = swap"
echo "dev/sda3 = root"
echo "type 'y' to show you understand this and wish to continue"
read CONFIRMATION

if [ $CONFIRMATION = "y"]
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

if [ $CONFIRMATION = "y"]
    echo "pacstrapping stuff w/ nvidia ..."
    pacstrap -K /mnt linux linux-firmware base base-devel grub efibootmgr iwd dhcpcd vim hyfetch git nvidia-dkms linux-headers --noconfirm
else
    echo "pacstrapping stuff  ..."
    pacstrap -K /mnt linux linux-firmware base base-devel grub efibootmgr iwd dhcpcd vim hyfetch git --noconfirm
fi

echo "creating the fstab ..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "chrooting ..."
arch-chroot /mnt

echo "time & locale stuff ..."
ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime
sed -i 's/^#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
touch /etc/locale.conf && echo "LANG=en_AU.UTF-8" > /etc/locale.conf

echo "what would you like the system hostname to be?"
read HOSTNAME
echo "$HOSTNAME" > /etc/hostname

echo "creating root password. please enter a password for the root account"
passwd 

echo "creating user account."
echo "what would you like the username to be?"
read USERNAME
useradd -m -G wheel -s /bin/bash $USERNAME

echo "creating user password. please enter a password for the $USERNAME account"
passwd $USERNAME

echo "editing sudoers file ..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "configuring grub ..."
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg