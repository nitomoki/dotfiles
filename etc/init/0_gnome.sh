#!/bin/bash

# hide gnome-dock
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false && gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false && gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# chage default dir name to Eng
LANG=C xdg-user-dirs-gtk-update

# change caps-lock to ctrl
gsettings set org.gnome.libgnomekbd.keyboard options "['ctrl\tctrl:nocaps']"
