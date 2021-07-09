#!/bin/bash

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update  -y
sudo apt install -y ros-melodic-desktop-full ros-melodic-joystick-drivers ros-melodic-image-proc python-osrf-pycommon python-catkin-tools ros-melodic-moveit

mkdir -p ~/catkin_ws
mkdir -p ~/catkin_ws/src

grep -q setup.zsh ~/.zshrc.local
if [ "$?" -ne 0]; then
    echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc.local
fi

grep -q ros_catkin_dir ~/.zshrc.local
if [ "$?" -ne 0]; then
    echo "ros_catkin_dir=~/catkin_ws" >> ~/.zshrc.local
    echo "if [ -e $ros_catkin_dir ]; then source $ros_catkin_dir/devel/setup.zsh ;fi" >> ~/.zshrc.local
fi

source ~/.zshrc

