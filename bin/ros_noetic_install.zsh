#!/bin/zsh

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
if ! type curl > /dev/null; then
    sudo apt install curl # if you haven't already installed curl
fi
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

sudo apt update  -y
sudo apt install -y ros-noetic-desktop-full
sudo apt install -y ros-noetic-image-proc python3-osrf-pycommon python3-catkin-tools ros-noetic-moveit python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

mkdir -p ~/catkin_ws/src
( cd ~/catkin_ws && catkin build )

# echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc.local
# echo "source ~/catkin_ws/devel/setup.zsh" >> ~/.zshrc.local
source ~/.zshrc

