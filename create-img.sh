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
# btwifiset:country=GB|timeout=30

# Install apps
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#apps
apps:name=pushpinaudio|apps=apturl,automake,autopoint,build-essential,curl,gettext,git,jack2d,libasound2-dev,libbz2-dev,libcairo2-dev,libffi-dev,libgdbm-dev,libgtk-3-dev,libjack-dev,libjack-jackd2-dev,libjson-glib-dev,liblzma-dev,libncurses5-dev,libncursesw5-dev,libreadline-dev,libsamplerate0-dev,libsndfile1-dev,libsqlite3-dev,libssl-dev,libtool,libusb-1.0-0-dev,libxml2-dev,libxmlsec1-dev,llvm,lzma,lzma-dev,make,openssl,pkgconfig,python3-brlapi,python3-dev,raspberrypi-ui-mods,tcl-dev,tk-dev,wget,xz-utils,zlib1g-dev

# Configure network
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#network
network:wifissid=$WIFI_SSID|wifipassword=$WIFI_PASSWORD|wificountry=GB

# This configuration eliminates the need for piwiz so disable it
disables:piwiz

# Uncomment to enable trim on all disks
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#trim-enable
trim-enable

# Enable X11
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#graphics
graphics:graphics=wayland

# Configure localization settings to the same as this system
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#l10n
L10n:host

# Run config script
# runscript:script=$PWD/setup.sh

EOF
    ) | bash -c "cat >|$assets/my.plugins"
echo $assets/my.plugins

echo sdm --customize --plugin @$assets/my.plugins --extend --xmb 2048 --restart --regen-ssh-host-keys $IMAGE

$sudo sdm --customize --plugin @$assets/my.plugins --extend --xmb 2048 --restart --regen-ssh-host-keys $IMAGE