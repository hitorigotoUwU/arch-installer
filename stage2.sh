#!/bin/bash

# hitorigotos arch installer script
# stage 2
# does system config stuff

# silly function to make printing titles better and stuff
prettyPrint() {
    STRING="$1"
    length="${#STRING}"
    DASHES=$(printf "%-${length}s" "" | tr ' ' '-')
    echo "$DASHES"; echo "$STRING"; echo "$DASHES"
}

clear

prettyPrint "chroot successful !!!"
prettyPrint "executing stage 2 ..."
prettyPrint "setting timezone ..."
ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime

prettyPrint "setting locale ..."
sed -i 's/^#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen
touch /etc/locale.conf && echo "LANG=en_AU.UTF-8" > /etc/locale.conf
locale-gen

prettyPrint "setting hostname ..."
echo "what would you like the system hostname to be?"
read HOSTNAME
echo "$HOSTNAME" > /etc/hostname

prettyPrint "root user configuration ..."
echo "creating root password. please enter a password for the root account"
passwd 

prettyPrint "user account config ..."
echo "what would you like the username to be?"
read USERNAME
useradd -m -G wheel -s /bin/bash $USERNAME

echo "creating user password. please enter a password for the $USERNAME account"
passwd $USERNAME

prettyPrint "sudo config ..."
echo "editing sudoers file ..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

prettyPrint "installing bootloader ..."
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

prettyPrint "extra utils ..."
echo "would you like to install paru?"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    echo "installing paru ..."
    cd /tmp/
    git clone https://github.com/Morganamilo/paru
    cd paru/
    makepkg -si
    cd /

    if [[ NVIDIA = "true" ]]
    then
        paru -S envycontrol
    fi

    if [[ i3 = "true" ]]
    then
        paru -S autotiling
    fi
fi

prettyPrint "install complete !!!"
echo "would you like to restart? (y/n)"
read CONFIRMATION

if [[ $CONFIRMATION = "y" ]]
then
    exit
    umount -a
    rm ./stage2.sh
    reboot
fi

#delete file after use
rm ./stage2.sh