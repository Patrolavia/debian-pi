#!/bin/bash

source lib.sh

IMG=$1
VER=$2
REPO=$3

if [[ $IMG == "" || $VER == "" || $REPO == "" ]]
then
    echo "Usage: $0 image_name debian_version repo_url"
    echo "Example: $0 patrolavia/debian-pi jessie http://httpredir.debian.org/debian"
    exit 1
fi

shift;shift;shift

$DOCKER rmi $IMG:$VER

[[ -f raspbian-archive-keyring.deb ]] \
    || wget -q -O raspbian-archive-keyring.deb http://ftp.yzu.edu.tw/Linux/raspbian/raspbian/pool/main/r/raspbian-archive-keyring/raspbian-archive-keyring_20120528.2_all.deb \
    || exit 1

set -e
$SUDO rm -fr $VER
mkdir $VER
$SUDO debootstrap --variant minbase "$@" $VER $VER $REPO
echo "deb http://httpredir.debian.org/debian $VER main" | $SUDO tee $VER/etc/apt/sources.list > /dev/null
echo "deb http://mirrordirector.raspbian.org/raspbian/ $VER main rpi" | $SUDO tee $VER/etc/apt/sources.list.d/rpi.list > /dev/null
$SUDO cp raspbian-archive-keyring.deb $VER/
$SUDO chroot $VER dpkg -i raspbian-archive-keyring.deb
$SUDO rm $VER/raspbian-archive-keyring.deb
$SUDO tar cf - -C $VER . | $DOCKER import -c 'CMD ["bash"]' - $IMG:$VER
$SUDO rm -fr $VER

## run ls to test image
$DOCKER run -it --rm $IMG:$VER ls
