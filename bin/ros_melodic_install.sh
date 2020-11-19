#!/bin/bash

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update  -y
sudo apt install -y ros-melodic-desktop-full ros-melodic-joystick-drivers ros-melodic-image-proc python-osrf-pycommon python-catkin-tools ros-melodic-moveit

mkdir -p ~/catkin_ws/src

echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc.local
source ~/.zshrc

