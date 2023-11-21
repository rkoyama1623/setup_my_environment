# Options
USE_PROXY:=false
USE_PYENV:=true

PROXY_SERVER:=example.com
PROXY_PORT:=8080

PYENV_ROOT:=$(HOME)/.pyenv

# Internal configuration
SHELL:=/bin/bash
MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SUDO:=sudo -E
YES:=-y
APT:=apt-get
PIP?=$(shell if $(USE_PYENV); then echo pyenv exec pip; else echo pip3; fi)
GIT?=$(shell if $(USE_PROXY); then echo git -c http.sslVerify=false; else echo git; fi)
PYTHON:=python

# PROXY
ifneq ($(http_proxy),)
	USE_PROXY:=true
endif
ifeq ($(USE_PROXY), true)
	ifeq ($(http_proxy),)
		USER_ID:=$(shell echo "Configure proxy setting:" 1>&2; read -p "  LDAP ID: > " tmp; echo $$tmp)
		USER_PASS:=$(shell read -s -p "  LDAP PASS: > " tmp; echo "" 1>&2; echo $$tmp)
		export http_proxy:=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PROXY_PORT)
		export https_proxy:=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PROXY_PORT)
	endif
	export GIT_SSL_NO_VERIFY:=true
endif

# PYENV
ifeq ($(USE_PYENV), true)
	export PATH:=$(PYENV_ROOT)/bin:$(PATH)
endif

# Public targets
help: ## Show this help
	@echo -e "make TARGET [OPTIONS]\n\
	OPTIONS:\n\
	  CATKIN_DIR=/path/to/catkin/dir\n\
	  USE_PROXY=(true|false)\n\
	TARGET:"
	@for f in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z_-]+\ *:.*?## .*$$' $$f | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}';\
	done

ALL_DEPS:=dot-files
ALL_DEPS+=basic-tools
ALL_DEPS+=gsettings
ALL_DEPS+=force-color-dot-bashrc
ifeq ($(USE_PYENV), true)
ALL_DEPS+=pyenv
endif
all: $(ALL_DEPS) ## Install all

dot-files: $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.tmux.conf ## Set .vimrc, .gitconfig, .tmux.conf

$(HOME)/.vimrc: $(MAKE_SOURCE_DIR)/dot-files/dot.vimrc
	cp $< $@
$(HOME)/.gitconfig:
	cp $(MAKE_SOURCE_DIR)/dot-files/dot.gitconfig $@
$(HOME)/.tmux.conf:
	cp $(MAKE_SOURCE_DIR)/dot-files/dot.tmux.conf $@
$(HOME)/.atom:
	ln -s $(MAKE_SOURCE_DIR)/dot-files/dot.atom $@
$(HOME)/.emacs.d:
	ln -s $(MAKE_SOURCE_DIR)/dot-files/dot.emacs.d $@

BASIC_TOOLS_DEPS:=build-essential
BASIC_TOOLS_DEPS+=basic-python-libraries
BASIC_TOOLS_DEPS+=vs-code
# BASIC_TOOLS_DEPS+=node
BASIC_TOOLS_DEPS+=~/.ccache
BASIC_TOOLS_DEPS+=$(HOME)/bin/commit
basic-tools: $(BASIC_TOOLS_DEPS) ## Install basic tools
	$(SUDO) $(APT) install aptitude ssh subversion git emacs vim-gtk tmux $(YES)
	$(SUDO) $(APT) install dconf-editor $(YES)
	$(SUDO) $(APT) install firefox $(YES)
	$(SUDO) $(APT) install colordiff vlc inkscape gimp tree tig $(YES)
	$(SUDO) $(APT) install xsel auto-install-el $(YES)
	$(SUDO) $(APT) install nkf $(YES)
	$(SUDO) $(APT) install pandoc $(YES)
	$(SUDO) $(APT) install rhino $(YES)
	$(SUDO) $(APT) install gnuplot-x11 $(YES)
	$(SUDO) $(APT) install cmake-curses-gui $(YES)
	if ! command rclone --version >/dev/null 2>&1; then \
		curl https://rclone.org/install.sh | $(SUDO) bash; \
	fi

build-essential:
	$(SUDO) $(APT) install build-essential $(YES)

basic-python-libraries:
	$(SUDO) $(APT) install $(PYTHON)-pip \
		i$(PYTHON) $(PYTHON)-pandas $(PYTHON)-numpy $(YES)

vs-code:
	$(SUDO) snap install --classic code
	for ext in $$(cat $(MAKE_SOURCE_DIR)/dot-files/dot.vscode/extension_list.txt); do \
		code --install-extension $$ext; \
	done

node:
	$(SUDO) $(APT) install npm $(YES)
	$(SUDO) npm install -g n
	$(SUDO) n latest
	$(SUDO) npm update -g npm

$(HOME)/.ccache:
	$(SUDO) $(APT) install ccache $(YES)
	$(SUDO) ln -sf /usr/bin/ccache /usr/local/bin/gcc
	$(SUDO) ln -sf /usr/bin/ccache /usr/local/bin/cc
	$(SUDO) ln -sf /usr/bin/ccache /usr/local/bin/g++
	$(SUDO) ln -sf /usr/bin/ccache /usr/local/bin/c++
	ccache -M 10G

pyenv: $(PYENV_ROOT) $(PYENV_ROOT)/plugins/pyenv-virtualenv ## Install pyenv

$(PYENV_ROOT):
	$(SUDO) $(APT) install make build-essential libssl-dev zlib1g-dev \
	               libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
	               xz-utils libxml2-dev libxmlsec1-dev liblzma-dev $(YES)
	$(SUDO) $(APT) install libffi-dev tk-dev $(YES)
	$(SUDO) $(APT) install libncurses5 libncurses5-dev libncursesw5 $(YES)
	$(GIT) clone https://github.com/pyenv/pyenv.git $(PYENV_ROOT)
	if ! grep pyenv $(HOME)/.bashrc >/dev/null 2>&1; then \
		echo '# pyenv' >> $(HOME)/.bashrc; \
		echo 'export PYENV_ROOT="$(PYENV_ROOT)"' >> $(HOME)/.bashrc; \
		echo 'export PATH="$$PYENV_ROOT/bin:$$PATH"' >> $(HOME)/.bashrc; \
		echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$$(pyenv init --path)"\n  eval "$$(pyenv init -)"\nfi' >> $(HOME)/.bashrc; \
	fi

$(PYENV_ROOT)/plugins/pyenv-virtualenv:
	$(GIT) clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_ROOT)/plugins/pyenv-virtualenv; \
	if ! grep virtualenv-init $(HOME)/.bashrc >/dev/null 2>&1; then \
		echo 'eval "$$(pyenv virtualenv-init -)"' >> $(HOME)/.bashrc; \
	fi

$(HOME)/bin/commit:
	mkdir -p $(dir $@) && cd $(dir $@); \
	ln -sf $(MAKE_SOURCE_DIR)/util/* ./; \
	grep '$${HOME}/bin' ~/.bashrc || \
		echo 'if [ -d $${HOME}/bin ]; then export PATH=$${HOME}/bin:$${PATH}; fi' >> ~/.bashrc

force-color-dot-bashrc: $(HOME)/.bashrc ## Force color prompt
	if grep '#force_color_prompt=yes' $(HOME)/.bashrc >/dev/null 2>&1; then \
		sed -ie 's/#force_color_prompt=yes/force_color_prompt=yes/g' $(HOME)/.bashrc; \
	fi

tex:
	$(SUDO) $(APT) install texlive-latex-base texlive-latex-extra # texlive-full $(YES)

octave:
	$(SUDO) add-apt-repository ppa:octave/stable $(YES)
	$(SUDO) $(APT) install octave $(YES)

config:
	bash $(MAKE_SOURCE_DIR)/config.sh

gsettings:  ## Set gsettings (instead of dconf-editor)
	# Switch tab
	gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
	# Power saving
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
	# 
	# https://nisshingeppo.com/ai/ubuntu-nonsleep/

timezone-to-jst:  ## Set timezone to JST
	timedatectl set-timezone Asia/Tokyo 

set-hardware-clock-to-use-local-time:  ## Set hardware clock to use local time
	# timedatectl set-local-rtc 1 --adjust-system-clock # Not checked!
	sudo hwclock -D --systohc --localtime # Checked.

define show_variable
	@echo "$(1): $($(1))"
endef

debug:
	$(call show_variable,USE_PROXY)
	$(call show_variable,GIT)
