MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

all: $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.tmux.conf $(HOME)/.atom $(HOME)/.emacs.d

$(HOME)/.vimrc:
	cp $(MAKE_SOURCE_DIR)/dot-files/dot.vimrc $@
$(HOME)/.gitconfig:
	cp $(MAKE_SOURCE_DIR)/dot-files/dot.gitconfig $@
$(HOME)/.tmux.conf:
	cp $(MAKE_SOURCE_DIR)/dot-files/dot.tmux.conf $@
$(HOME)/.atom:
	ln -s $(MAKE_SOURCE_DIR)/dot-files/dot.atom $@
$(HOME)/.emacs.d:
	ln -s $(MAKE_SOURCE_DIR)/dot-files/dot.emacs.d $@
