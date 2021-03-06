#!/bin/bash

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update  -y
sudo apt install -y ros-noetic-desktop-full ros-noetic-joystick-drivers ros-noetic-image-proc python3-osrf-pycommon python3-catkin-tools ros-noetic-moveit

mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
catkin_init_workspace
cd ~/catkin_ws
catkin_make

echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc.local
source ~/.zshrc

