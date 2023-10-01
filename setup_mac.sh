# use .bashrc in mac
# echo -e 'if [ -f ~/.bashrc ]; then\n    source ~/.bashrc\nfi' >> ~/.bash_profile
sudo pmset -a disablesleep 1 
brew install tmux
brew install git tig python-tk

brew install libffi cmake xz zlib sqlite3 pyenv pyenv-virtualenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

brew install libjpeg # For pillow
echo 'export PATH="/usr/local/opt/jpeg/bin:$PATH"' >> ~/.zshrc
echo 'export LDFLAGS="-L/usr/local/opt/jpeg/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/usr/local/opt/jpeg/include"' ~/.zshrc
echo 'export PKG_CONFIG_PATH="/usr/local/opt/jpeg/lib/pkgconfig"' >> ~/.zshrc

echo 'backend: TkAgg' >> ~/.matplotlib/matplotlibrc
