# setup_my_environment

# Usage
## Setup Ubuntu
```bash
wget https://raw.githubusercontent.com/rkoyama1623/setup_my_environment/master/apt-get.sh -O apt-get.sh
bash apt-get.sh
git clone https://github.com/rkoyama1623/setup_my_environment.git
cd setup_my_environment
./config.sh
./install_ros.sh
```
## Setup Atom
```bash
apm list -bi > atomfile
apm install --packages-file atomfile
```

## Setup Git
```
ssh -T git@github.com
cd $HOME
cp /path/to/setup_my_environment/dot-files/dot.gitconfig .gitconfig
```

