#!/usr/bin/env bash
# TODO: password is required. where??
# get ros version
# TODO: get ros version from linux kernel version
ROS_DISTRO=kinetic
YES='-y'
APT='apt-get'

function pre_install_ros() {
    # for wsl
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        sudo ${APT} install x11-apps ${YES}
    fi
}

function install_ros() {
	ROS_APT_PACKAGE_BASE=desktop-full
    # preparation for ros
    pre_install_ros
	# setting source.list
	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	# setting for key
	sudo apt-key adv --keyserver 'hkp://ha.pool.sks-keyservers.net:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
	# install ros
	sudo ${APT} update
	sudo ${APT} install ros-${ROS_DISTRO}-${ROS_APT_PACKAGE_BASE} ${YES}
}


function set_environment_parameter() {
	echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
	source ~/.bashrc
}

function install_additional_ros_tools() {
    tools=(python-rosinstall python-catkin-tools)
    sudo ${APT} install ${YES} ${tools[@]} # TODO: password required
}

function setup_ros_env(){
    sudo rosdep init
    rosdep update
}

function main() {
    install_ros
    set_environment_parameter
    install_additional_ros_tools
    setup_ros_env
}

# main
main




