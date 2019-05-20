#!/bin/bash

systemctl --user stop Electrify
sudo cp -f "$1/.build/armv7-unknown-linux-gnueabihf/release/Electrify" /home/pi/.electrify/Electrify
sudo chown pi:pi /home/pi/.electrify/Electrify
systemctl --user enable Electrify
systemctl --user start Electrify
