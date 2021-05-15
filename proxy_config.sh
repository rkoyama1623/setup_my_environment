#!/bin/sh
proxy-config () {
    # For user
    USER='USER-NAME'
    PASS='PASSWORD'
    PROXY_SERVER='example.com'
    PORT='80'
    DNS_SERVER_IP='0.0.0.0'

    # For developper
    SET_APT='false'
    COMMAND='help'

    function usage {
        echo "proxy-config is a tool for setting up proxy server.
You can write ID/PASS in the script file, source the file, and run.
This function edit following files:
- ~/.wgetrc
- ~/.gitconfig
- ~/etc/apt/apt.conf (when --apt option was specified)

Usage:
proxy-config [<options>] command
command: set or unset
Options:
-h, --help           print this
--id <ID>       specify ID
--pass <PASS>  specify Password
--dns  <IP>          specify DNS Server IP
--apt                also set proxy for apt (require sudo)
Example:
$ source /path/to/setup_rd_environment/proxy_config.sh
$ proxy-config set
$ proxy-config set --user hoge --pass fuga --apt
$ proxy-config unset
"
    }


    while [ $# -gt 0 ];
    do
        case ${1} in
            help|--help|-h)
            COMMAND='help'
            shift
            ;;

            set)
            COMMAND='set'
            shift
            ;;

            unset)
            COMMAND='unset'
            shift
            ;;

            --id)
            USER=${2}
            shift 2
            ;;

            --pass)
            PASS=${2}
            shift 2
            ;;

            --dns)
            DNS_SERVER_IP=${2}
            shift
            ;;

            --apt)
            SET_APT=true
            shift
            ;;

            *)
            usage
            return 1
        esac
    done

    function set_variables {
        if [ ! -z "$PROXY_SERVER" ]; then
            export proxy_server=${PROXY_SERVER}
            export http_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            export https_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
            export ftp_proxy="http://${USER}:${PASS}@${PROXY_SERVER}:${PORT}"
        else
            export proxy_server=''
            export http_proxy=''
            export https_proxy=''
            export ftp_proxy=''
        fi
    }

    function prepare_backup_dir {
        BACKUP_DIR=${HOME}/.proxy/backup
        if [ ! -e ${BACKUP_DIR} ]; then
            mkdir -p ${BACKUP_DIR}
        fi
    }

    function set_git {
        cp ~/.gitconfig ${BACKUP_DIR}/dot.gitconfig
        cp ~/.gitconfig ${BACKUP_DIR}/dot.gitconfig
        git config --global http.proxy "${http_proxy}"
        git config --global https.proxy "${https_proxy}"
        git config --global ftp.proxy "${ftp_proxy}"
        git config --global http.sslVerify false
    }

    function set_wget {
        if [ ! -f ~/.wgetrc ]; then
            touch ~/.wgetrc
        fi
        # Backup
        cp ${HOME}/.wgetrc ${BACKUP_DIR}/dot.wgetrc
        # Set use_proxy
        if [ ! -z ${http_proxy} ]; then
            if grep -q use_proxy ~/.wgetrc; then
                sed -i ~/.wgetrc -e 's/use_proxy.*=.*off/use_proxy = on/g'
            else
                echo 'use_proxy = on' >> ~/.wgetrc
            fi
        else
            if grep -q use_proxy ~/.wgetrc; then
                sed -i -e 's/use_proxy.*=.*/use_proxy = off/g' ~/.wgetrc
            fi
        fi
        regex_proxy_server=${proxy_server//\//\\/}
        regex_proxy_server=${regex_proxy_server//\./\\.}
        sed -i -e "s/proxy_user.*=.*/proxy_user = ${USER}/g" ~/.wgetrc
        sed -i -e "s/proxy_passwd.*=.*/proxy_passwd = ${PASS}/g" ~/.wgetrc
        if [ ! -z ${proxy_server} ]; then
            sed -i -e "s/http_proxy.*=.*/http_proxy = http:\/\/${regex_proxy_server}:${PORT}/g" ~/.wgetrc
            sed -i -e "s/https_proxy.*=.*/https_proxy = http:\/\/${regex_proxy_server}:${PORT}/g" ~/.wgetrc
            sed -i -e "s/ftp_proxy.*=.*/ftp_proxy = http:\/\/${regex_proxy_server}:${PORT}/g" ~/.wgetrc
        else
            sed -i -e "s/http_proxy.*=.*/http_proxy = /g" ~/.wgetrc
            sed -i -e "s/https_proxy.*=.*/https_proxy = /g" ~/.wgetrc
            sed -i -e "s/ftp_proxy.*=.*/ftp_proxy = /g" ~/.wgetrc
        fi
    }

    function set_apt {
        if ! grep -q proxy /etc/apt/apt.conf; then
            sudo sh -c 'echo Acquire::http::proxy >> /etc/apt/apt.conf'
            sudo sh -c 'echo Acquire::https::proxy >> /etc/apt/apt.conf'
            sudo sh -c 'echo Acquire::ftp::proxy >> /etc/apt/apt.conf'
        fi
        if [ ! -z ${proxy_server} ]; then
            regex_proxy_server=${proxy_server//\//\\/}
            regex_proxy_server=${regex_proxy_server//\./\\.}
            sudo sed -i -e "s/Acquire::http::proxy.*/Acquire::http::proxy \"http:\/\/${USER}:${PASS}@${regex_proxy_server}:${PORT}\/\";/" /etc/apt/apt.conf
            sudo sed -i -e "s/Acquire::https::proxy.*/Acquire::https::proxy \"http:\/\/${USER}:${PASS}@${regex_proxy_server}:${PORT}\/\";/" /etc/apt/apt.conf
            sudo sed -i -e "s/Acquire::ftp::proxy.*/Acquire::ftp::proxy \"http:\/\/${USER}:${PASS}@${regex_proxy_server}:${PORT}\/\";/" /etc/apt/apt.conf
        else
            sudo sed -i -e "/^Acquire::http::proxy.*/d" /etc/apt/apt.conf
            sudo sed -i -e "/^Acquire::https::proxy.*/d" /etc/apt/apt.conf
            sudo sed -i -e "/^Acquire::ftp::proxy.*/d" /etc/apt/apt.conf
        fi
    }

    case $COMMAND in
        "help")
            usage
            ;;

        "set")
            # Set sudo alias
            alias sudo='sudo -E'

            # Set Environment Variables
            set_variables

            # Change settings
            prepare_backup_dir
            set_git
            set_wget
            if [ ${SET_APT} = true ]; then set_apt; fi;
            ;;

        "unset")
            # Set sudo alias
            alias sudo='sudo'

            # Unset Environment Variables
            USER=''
            PASS=''
            PROXY_SERVER=''
            PORT=''
            DNS_SERVER_IP=''
            set_variables

            # Change settings
            prepare_backup_dir
            set_git
            set_wget
            if [ ${SET_APT} = true ]; then set_apt; fi;
            ;;

        *)
            return 1
    esac

    unset usage
    unset set_variables
    unset prepare_backup_dir
    unset set_git
    unset set_wget
    unset set_apt
}
