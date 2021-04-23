#!/usr/bin/env bash
SUDO='sudo -E'
YES='-y --allow-unauthenticated'
APT='apt-get'

function cuda() {
    curl -sSL 'http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub' | ${SUDO} apt-key add -
    ${SUDO} sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install ${YES} cuda-toolkit-11-2
}

function main() {
    cuda
}

# main
main
