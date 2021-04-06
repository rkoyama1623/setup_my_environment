#!/usr/bin/env bash
SUDO='sudo -E'
YES='-y --allow-unauthenticated'
APT='apt-get'

function remove_old_docker () {
    ${SUDO} ${APT} remove docker docker-engine docker.io containerd runc
}

function setup_repository () {
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install apt-transport-https ca-certificates curl gnupg lsb-releas
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | ${SUDO} gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

function install_docker_engine() {
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install docker-ce docker-ce-cli containerd.io
}

function main() {
    remove_old_docker
    setup_repository
    install_docker_engine
}

# main
main
