# arch-installer
simple script to install arch from a livecd.

## how to use
partition your drives beforehand so that sda1 can be formatted as a boot drive, sda2 can be used as swap and sda3 can be used as main storage.

run `curl -sL https://bit.ly/3XZoRGT | bash -s`
(if you dont feel comfortable executing scripts you havent read through, you can read through all the code on this repo and curl the install.sh file manually)

# issues
this is mainly taloured for how i like to install arch. it has hardcoded values for some things. might change that in the future so other people can use this script easier, but for now, you might have to manually make changes to some of the code.
