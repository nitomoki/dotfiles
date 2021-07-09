#!/bin/bash

ros_include_links=(
    ros
    nodelet
    pluginlib
    moveit
    moveit_msgs
    moveit_visual_tools
    )

for link in "${ros_include_links[@]}"; do
    sudo ln -sfnv /opt/ros/$ROS_DISTRO/include/$link /usr/include/$link
done
#sudo ln -sfnv /opt/ros/melodic/include/ros /usr/include/ros
#sudo ln -sfnv /opt/ros/melodic/include/nodelet /usr/include/nodelet
#sudo ln -sfnv /opt/ros/melodic/include/pluginlib /usr/include/pluginlib

