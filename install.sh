#!/bin/bash

# hitorigotos arch installer script
# stage 1
# basically does everything pre chroot

# silly function to make printing titles better and stuff
prettyPrint() {
    STRING="$1"
    length="${#STRING}"
    DASHES=$(printf "%-${length}s" "" | tr ' ' '-')
    echo "$DASHES"; echo "$STRING"; echo "$DASHES"
}

# error handling thingymabob
errorCheck() {
    if [[ $? = 1 ]]
    then
        prettyPrint "ERROR !!!"
        echo "an error occured at the current stage"
        echo "script will continue running, but be adviced it may fail ..."
    fi
}

prettyPrint "WARNING !!!"
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

prettyPrint "WARNING !!!"
echo "this script does not automatically partition drives because i suck at scripting. "
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
    echo "/dev/sda3 was not detected. you likely have not partitioned the drives properly."
    echo "exiting script ..."
    exit 1
fi

if [[ $CONFIRMATION = "y" ]]
then
    echo "continuing..."
else
    echo "exiting script ..."
    exit 1
fi

prettyPrint "formatting drives ..."
mkfs.ext4 /dev/sda3
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2

prettyPrint "mounting drives ..."
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
swapon /dev/sda2

PACKAGES="base base-devel linux linux-firmware vim dhcpcd grub efibootmgr"

#optional stuff, comment if not needed
PACKAGES="$PACKAGES iwd amd-ucode"

prettyPrint "preparing for pacstrap ..."
echo "would you like to install a desktop enviornment? (i3/plasma/n)"
read CONFIRMATION

if [[ $CONFIRMATION = "i3" ]]
then
    echo "using i3 ..."
    PACKAGES = "$PACKAGES xorg i3 lightdm lightdm-gtk-greeter"
elif [[ $CONFIRMATION = "plasma" ]]
then
    echo "using plasma ..."
    PACKAGES = "$PACKAGES xorg plasma"
else
    echo "not installing a DE ..."
fi

echo "would you like to install nvidia drivers? (y/n)"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    PACKAGES = "$PACKAGES linux-headers nvidia-dkms"
fi

pacstrap -K /mnt $PACKAGES

prettyPrint "creating the fstab ..."
genfstab -U /mnt >> /mnt/etc/fstab
errorCheck

# seems to fail sometimes bc it cant execute curl when chrooting
# might be best to merge this and stage 2 in the future
# and have all commands executed in the chroot
# just run with arch-chroot /mnt $COMMAND
prettyPrint "attemtping to chroot and execute stage 2 ..."
arch-chroot /mnt /bin/curl https://raw.githubusercontent.com/hitorigotoUwU/arch-installer/main/stage2.sh -o stage2.sh
arch-chroot /mnt /bin/chmod +x stage2.sh
arch-chroot /mnt ./stage2.sh

# check for error output
if [[ $? = 1 ]]
then
    prettyPrint "ERROR !!!"
    echo "failed to chroot for whatever reason."
    echo "please enter the command:" 
    echo "curl https://raw.githubusercontent.com/hitorigotoUwU/arch-installer/main/stage2.sh -o stage2.sh; chmod +x stage2.sh; ./stage2.sh"
    echo "attemtping to chroot w/o executing stage 2 automatically ..."
    arch-chroot /mnt
fi

#delete file after use
rm ./install.sh