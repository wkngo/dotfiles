#!/bin/bash
set -e

[[ "$(uname)" != "Linux" ]] && exit 0

# Skip on desktops — no backlight devices means this is unnecessary
[[ -z "$(ls /sys/class/backlight/ 2>/dev/null)" ]] && exit 0

echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules

sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight
sudo usermod -aG video "$USER"
