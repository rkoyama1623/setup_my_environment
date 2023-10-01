#!/usr/bin/env bash
SUDO='sudo -E'
YES='-y --allow-unauthenticated'
APT='apt-get'

function linux_remove_old_docker () {
    ${SUDO} ${APT} remove docker docker-engine docker.io containerd runc
}

function linux_setup_repository () {
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install apt-transport-https ca-certificates curl gnupg lsb-releas
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | ${SUDO} gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

function linux_install_docker_engine() {
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install docker-ce docker-ce-cli containerd.io
}

function mac_install_docker_engine() {
    # brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve
    # brew install docker docker-machine
    # sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve 
    # sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
    # docker-machine create default --driver xhyve --xhyve-experimental-nfs-share

    # https://dhwaneetbhatt.com/blog/run-docker-without-docker-desktop-on-macos
    # minikube is used to run a Kubernetes cluster on local environment.
    
    # Install hyperkit and minikube
    brew install hyperkit
    brew install minikube

    # Install Docker CLI
    brew install docker
    brew install docker-compose

    # Start minikube
    minikube start

    # Tell Docker CLI to talk to minikube's VM
    if ! grep 'eval $(minikube docker-env)' ~/.zshrc; then
        echo 'eval $(minikube docker-env)' >> ~/.zshrc;
    fi

    # Save IP to a hostname
    echo "`minikube ip` docker.local" | sudo tee -a /etc/hosts > /dev/null

    # # Test
    # docker run hello-world
}

function main() {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)
            machine=Linux;
            linux_remove_old_docker;
            linux_setup_repository;
            linux_install_docker_engine;
            ;;
        Darwin*)
            machine=Mac;
            mac_install_docker_engine;
            ;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        MSYS_NT*)   machine=Git;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
}

# main
main
