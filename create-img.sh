#!/bin/bash

#
# Simple script to use sdm with plugins
# Edit the text inside the EOF/EOF as appropriate for your configuration
# ** Suggestion: Copy this file to somewhere in your path and edit your copy
#    (~/bin is a good location)
#

function errexit() {
    echo -e "$1"
    exit 1
}

[ $EUID -eq 0 ] && sudo="" || sudo="sudo"

IMAGE="2024-07-04-raspios-bookworm-arm64-lite.img"

# service dbus start

if ! test -f $IMAGE; then
  curl -O https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/$IMAGE.xz
  xz -d $IMAGE.xz
fi

[ "$(type -t sdm)" == "" ] && errexit "? sdm is not installed"

assets="."

[ -f $assets/my.plugins ] &&  mv $assets/my.plugins $assets/my.plugins.1

(cat <<EOF
# Plugin List generated $(date +"%Y-%m-%d %H:%M:%S")

# Delete user pi if it exists
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#user
user:deluser=pi

# Add a new user
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#user
user:adduser=pushpin|password=groovebox|addgroup=audio

# Install btwifiset (Control Pi's WiFi from your phone)
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#btwifiset
btwifiset:country=GB|timeout=30

# Install apps
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#apps
apps:name=pushpin|apps=curl,libasound2-dev,libjack-dev,apturl,python3-brlapi,xserver-xorg,xserver-xorg-video-fbdev,xinit,pciutils,xinput,xfonts-100dpi,xfonts-75dpi,xfonts-scalable

# Configure network
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#network
network:wifissid=myssid|wifipassword=mypassword|wificountry=GB

# This configuration eliminates the need for piwiz so disable it
disables:piwiz

# Uncomment to enable trim on all disks
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#trim-enable
trim-enable

# Enable X11
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#graphics
graphics:graphics=X11

# Run config script
runscript:script=$PWD/setup.sh

EOF
    ) | bash -c "cat >|$assets/my.plugins"
echo $assets/my.plugins

echo sdm --customize --plugin @$assets/my.plugins --extend --xmb 2048 --restart --regen-ssh-host-keys $IMAGE

$sudo sdm --customize --plugin @$assets/my.plugins --extend --xmb 2048 --restart --regen-ssh-host-keys $IMAGE