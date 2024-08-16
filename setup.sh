#!/bin/bash

echo "Adding Push2 support"
curl -o /etc/udev/rules.d/99-ableton-push2.rules https://raw.githubusercontent.com/Ardour/ardour/master/tools/udev/50-ableton-push2.rules

echo "Installing Surge-XT"
echo 'deb http://download.opensuse.org/repositories/home:/surge-synth-team/Raspbian_12/ /' | sudo tee /etc/apt/sources.list.d/home:surge-synth-team.list
curl -fsSL https://download.opensuse.org/repositories/home:surge-synth-team/Raspbian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_surge-synth-team.gpg > /dev/null
apt update
apt install surge-xt-nightly

echo "Installing Overwitch"
curl -OL https://github.com/aendra-rininsland/overwitch-aarch64/archive/refs/tags/1.1.tar.gz
tar -xzvf 1.1.tar.gz
cp -R 1.1/aarch64/* /

echo "Installing Pushpin"
git clone https://github.com/kingajanicka/pushpin-groovebox /pushpin
chown -R pushpin /pushpin

echo "Installing PushPin deps"


echo "DONE"