#!/bin/bash
set -e

echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight
sudo usermod -aG video "$USER"
