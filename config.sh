# yes_or_no_while　<message>
function yes_or_no_while() {
    while true;do
        echo ${1};read answer;
        case $answer in
            yes)
                echo -e "tyeped yes.";return 0;;
            no)
                echo -e "tyeped no.";return 1;;
            *)
                echo -e "cannot understand $answer.";;
        esac
    done
}
# set root pass
yes_or_no_while "set root pass. show the command Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    echo "sudo su -"
    echo "sudo passwd"
    echo "[sudo] password for <user名>        ← 現在のユーザのパスワードを入力"
    echo "[sudo] password for <user名> (input current pass)"
    echo "Enter new UNIX password:            ← 設定するパスワードを入力"
    echo "Retype new UNIX password:           ← 設定するパスワードを入力"
    echo "donee";fi

## capslock ctrl
yes_or_no_while "change caps and ctrl. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    sudo apt install x11-xserver-utils
    WORKSPACE=${HOME}
    sudo sed /etc/default/keyboard -e 's/XKBOPTIONS=.*/XKBOPTIONS="ctrl:nocaps"/' > /tmp/keyboard
    sudo mv /tmp/keyboard /etc/default/keyboard
    if [ ! -e ${WORKSPACE}/.Xmodmap ];then
        echo "! caps -> ctrl"      >> ${WORKSPACE}/.Xmodmap
        echo "remove Lock = Caps_Lock"      >> ${WORKSPACE}/.Xmodmap
        echo "keysym Caps_Lock = Control_L" >> ${WORKSPACE}/.Xmodmap
        echo "add Control = Control_L"      >> ${WORKSPACE}/.Xmodmap
        # echo "! left ctrl -> caps"      >> ${WORKSPACE}/.Xmodmap
        # echo "remove Control = Control_L"   >> ${WORKSPACE}/.Xmodmap
        # echo "keysym Control_L = Caps_Lock" >> ${WORKSPACE}/.Xmodmap
        # echo "add Lock = Caps_Lock"         >> ${WORKSPACE}/.Xmodmap
    fi
    echo "done";fi

## change name of dir
yes_or_no_while "change name of dir. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    LANG=C;xdg-user-dirs-gtk-update
    LANG=ja_JP.UTF-8
    echo "donee";fi

# mozc
yes_or_no_while "install mozc. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    firefox http://symfoware.blog68.fc2.com/blog-entry-1397.html
    sudo apt-get install ibus-mozc
    killall ibus-daemon
    ibus-daemon -d -x &  #resart ibus
fi

# input
yes_or_no_while "ignore Upeer/Lower letter. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    echo "make .inputrc and process"
    f=${HOME}/.inputrc
    touch ${f}
    if ! $(grep completion-ignore-case ${f});then
        echo "set completion-ignore-case on" >> ${f}
    fi
fi

# git cache
yes_or_no_while "configure git to cache 24h. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    git config --global credential.helper cache
    git config --global credential.helper cache --timeout=86400 #24h
    echo "donee";fi

# dropbox
yes_or_no_while "install dropbox. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    echo "please install dropbox manually"
    firefox https://www.dropbox.com/ja/install?os=linux
    echo "donee";fi

# chrome
yes_or_no_while "install chrome. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    echo "please install chrome manually"
    firefox https://www.google.com/intl/ja/chrome/browser/desktop/index.html
    echo "donee";fi

# ntp setting (security)
yes_or_no_while "set ntp. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    ./ntp.sh
    echo "done";fi

# pyenv
yes_or_no_while "set pyenv. Do you agree? (yes/no)";ret=$?;
if [ ${ret} -eq 0 ]; then
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv init -
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.profile
    echo "done";fi



# firefox
# manual setting
echo "please set firefox to sync"
echo "ディスプレイの設定をしないと、ディスプレイを閉じた時スリープ"
