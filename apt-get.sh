#!/usr/bin/env bash

#################
## This file process apt-get
################

APT_GET_YES="-y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew"
SUDO="sudo -E"
YES="-y"

# basic tools
${SUDO} apt-get update
${SUDO} apt-get install aptitude ssh subversion git emacs vim-gtk tmux ${YES}
#${SUDO} apg-get upgrade firefox -y

# basic developper tools
${SUDO} apt install build-essential ${YES}

# basic applications
# ${SUDO} add-apt-repository ppa:octave/stable ${YES}
# ${SUDO} apt-get install octave ${YES}
${SUDO} apt-get install colordiff vlc inkscape gimp tree tig ${YES}

# for .emacs
${SUDO} apt-get install xsel auto-install-el ${YES}

# for shell scripts
${SUDO} apt-get install nkf ${YES} #encoding
${SUDO} apt-get install pandoc ${YES}

## programing env
# pip
${SUDO} apt-get install python-pip python3-pip ipython ipython-qtconsole python-pandas python-numpy ${YES}
${SUDO} apt-get install rhino ${YES}
# boost c compile
${SUDO} apt-get install ccache ${YES}
${SUDO} ln -sf /usr/bin/ccache /usr/local/bin/gcc
${SUDO} ln -sf /usr/bin/ccache /usr/local/bin/cc
${SUDO} ln -sf /usr/bin/ccache /usr/local/bin/g++
${SUDO} ln -sf /usr/bin/ccache /usr/local/bin/c++
ccache -M 10G

# gnuplot
${SUDO} apt-get install gnuplot-x11 ${YES}

# ccmake (gui for cmake)
${SUDO} apt-get install cmake-curses-gui ${YES}

# rclone
curl https://rclone.org/install.sh | ${SUDO} bash

# node
${SUDO} apt install npm ${YES}
${SUDO} npm install -g n
${SUDO} n latest
${SUDO} npm update -g npm

## Tex
# ${SUDO} apt-get install texlive-latex-base texlive-latex-extra # texlive-full
