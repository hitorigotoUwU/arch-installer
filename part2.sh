#!/bin/bash
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