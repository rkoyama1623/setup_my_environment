# Options
USE_PROXY:=false

# Variable definitions
SHELL:=/bin/bash
MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SUDO:=sudo -E
YES:=-y
APT:=apt-get

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
ALL_DEPS+=$(HOME)/bin/commit
ALL_DEPS+=force-color-dot-bashrc
all: $(ALL_DEPS) ## Install all

dot-files: $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.tmux.conf 

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
basic-tools: $(BASIC_TOOLS_DEPS)
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
	curl https://rclone.org/install.sh | $(SUDO) bash

build-essential:
	$(SUDO) $(APT) install build-essential $(YES)

basic-python-libraries:
	$(SUDO) $(APT) install python-pip python3-pip \
		ipython ipython-qtconsole python-pandas python-numpy $(YES)

vs-code:
	$(SUDO) snap install --classic code

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

$(HOME)/bin/commit:
	mkdir -p $(dir $@) && cd $(dir $@); \
	ln -sf $(MAKE_SOURCE_DIR)/util/* ./; \
	grep '$${HOME}/bin' ~/.bashrc || \
		echo 'if [ -d $${HOME}/bin ]; then export PATH=$${HOME}/bin:$${PATH}; fi' >> ~/.bashrc

force-color-dot-bashrc:
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
	gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
