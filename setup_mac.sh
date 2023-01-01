# use .bashrc in mac
# echo -e 'if [ -f ~/.bashrc ]; then\n    source ~/.bashrc\nfi' >> ~/.bash_profile
sudo pmset -a disablesleep 1 
brew install tmux
brew install git tig

brew install libffi xz zlib sqlite3 pyenv pyenv-virtualenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc


