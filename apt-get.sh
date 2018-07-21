#!/usr/bin/env bash

#################
## This file process apt-get
################

APT_GET_YES="-y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew"
YES="-y"

# get password
if ! [ -v password ]; then
	echo -n Password: 
	read -s password
	echo; 
fi

echo ${password}|sudo -kS add-apt-repository ppa:octave/stable
echo ${password}|sudo -kS apt-get update
echo ${password}|sudo -kS apt-get install aptitude ssh subversion git emacs vim-gtk tmux ${YES}
#echo ${password}|sudo -kS apg-get upgrade firefox -y

# ubuntu basic tools
echo ${password}|sudo -kS apt-get install colordiff vlc inkscape gimp tree tig octave ${YES}

# for .emacs
echo ${password}|sudo -kS apt-get install xsel auto-install-el ${YES}

# for shell scripts
echo ${password}|sudo -kS apt-get install nkf ${YES} #encoding
echo ${password}|sudo -kS apt-get install pandoc ${YES} 

## programing env
# pip
echo ${password}|sudo -kS apt-get install python-pip python3-pip ipython ipython-qtconsole python-pandas python-numpy ${YES}
echo ${password}|sudo -kS apt-get install rhino ${YES}
# boost c compile
echo ${password}|sudo -kS apt-get install ccache ${YES}
echo ${password}|sudo -kS ln -sf /usr/bin/ccache /usr/local/bin/gcc
echo ${password}|sudo -kS ln -sf /usr/bin/ccache /usr/local/bin/cc
echo ${password}|sudo -kS ln -sf /usr/bin/ccache /usr/local/bin/g++
echo ${password}|sudo -kS ln -sf /usr/bin/ccache /usr/local/bin/c++
ccache -M 10G

# gnuplot
echo ${password}|sudo -kS apt-get install gnuplot-x11 ${YES}

# ccmake (gui for cmake)
echo ${password}|sudo -kS apt-get install cmake-curses-gui ${YES}
