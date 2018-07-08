#!/usr/bin/env bash
DISTRO=kinetic

# get password
echo -n Password: 
read -s password
echo 

# ros
echo ${password}|sudo -kS sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
echo ${password}|sudo -kS apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

echo ${password}|sudo -kS apt-get update
echo ${password}|sudo -kS apt-get install ros-${DISTRO}-desktop -y

# run rosbuild
# bash jsk.rosbuild --from-source --rtm indigo -y
echo ${password}|sudo -kS apt-get install ros-${DISTRO}-rosbash python-rosdep python-wstool -y

# ntp settings
## ./scripts/ntp_setting.sh
