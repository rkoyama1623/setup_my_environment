#!/bin/sh
# Usage:
# source proxy_config.sh
# proxy-config ...
proxy-config () {
    if [ $# -lt 1 ]; then
        proxy-config help
        return
    fi
    case $1 in
        "help")
            echo >&2 "Proxy Setting Manager"
            echo >&2 " "
            echo >&2 "set following configurations"
            echo >&2 "- Envitonment Variables"
            echo >&2 "- ~/.gitconfig"
            echo >&2 "- ~/.wgetrc"
            echo >&2 " "
            echo >&2 "Usage:"
            echo >&2 "    proxy-config set"
            echo >&2 "    proxy-config unset"
            echo >&2 "    proxy-config help"
            ;;

        "set")
            # Set Environment Variables
            USER='USER'
            PASS='PASS'
            PROXY_SERVER='proxy.server.com'
            PORT='8080'
            export proxy_server=${PROXY_SERVER}
            export http_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            export https_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            export ftp_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"

            # Prepare backup directory
            BACKUP_DIR='${HOME}/.proxy/backup'
            if [ ! -e ${BACKUP_DIR} ]; then
                mkdir -p ${BACKUP_DIR}
            fi

            # Set git
            cp ~/.gitconfig ${BACKUP_DIR}/dot.gitconfig
            cp ~/.gitconfig ${BACKUP_DIR}/dot.gitconfig
            git config --global http.proxy "http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            git config --global https.proxy "http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            git config --global ftp.proxy "http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            git config --global http.sslVerify false

            # Set wget
            cp "${HOME}/.wgetrc" "${BACKUP_DIR}/dot.wgetrc"

            has_use_proxy=0
            grep use_proxy ${HOME}/.wgetrc > /dev/null 2>&1|| has_use_proxy_flag=$?
            if [ -o $has_use_proxy ]; then
                sed "${BACKUP_DIR}/dot.wgetrc" -e 's/use_proxy.*=.*off/use_proxy = on/g' > ${HOME}/.wgetrc
            else
                echo -n "use_proxy = on
proxy_user = ${USER}
proxy_passwd = ${PASS}
http_proxy = http://${PROXY_SERVER}:${PORT}
https_proxy = http://${PROXY_SERVER}:${PORT}
ftp_proxy = http://${PROXY_SERVER}:${PORT}
" > ${HOME}/.wgetrc
            fi
            ;;

        "unset")
            export proxy_server=""
            export http_proxy=""
            export https_proxy=""
            export ftp_proxy=""

            # Prepare backup directory
            BACKUP_DIR='${HOME}/.proxy/backup'
            if [ ! -e ${BACKUP_DIR} ]; then
                mkdir -p ${BACKUP_DIR}
            fi

            # Set git
            cp ~/.gitconfig ${BACKUP_DIR}/dot.gitconfig
            git config --global http.proxy ""
            git config --global https.proxy ""
            git config --global ftp.proxy ""
            git config --global http.sslVerify true

            # Set wget
            cp ${HOME}/.wgetrc ${BACKUP_DIR}/dot.wgetrc
            sed ${BACKUP_DIR}/dot.wgetrc -e 's/use_proxy.*=.*on/use_proxy = off/g' > ${HOME}/.wgetrc
            ;;

        *)
            proxy-config help
    esac
}
