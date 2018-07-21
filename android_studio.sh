#!/usr/bin/env bash

# get password
if ! [ -v password ]; then
	echo -n Password: 
	read -s password
	echo; 
fi

# install android studio
echo ${password}|sudo -kS add-apt-repository ppa:maarten-fonville/android-studio -y
echo ${password}|sudo -kS apt update
echo ${password}|sudo -kS apt install android-studio -y
