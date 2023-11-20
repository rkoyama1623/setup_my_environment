SUDO=sudo
APT=apt
YES=-y

function main() {
    ${SUDO} ${APT} update
    ${SUDO} ${APT} install git make ${YES}
    mkdir -p ~/src && cd ~/src
    git clone https://github.com/rkoyama1623/setup_my_environment.git
    cd setup_my_environment && make all
}

main
