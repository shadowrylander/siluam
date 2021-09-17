.RECIPEPREFIX := |
.DEFAULT_GOAL := emacs

# Adapted From: https://www.systutorials.com/how-to-get-the-full-path-and-directory-of-a-makefile-itself/
mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))
makefly := make -f $(mkfileDir)/makefly.mk

init: pre-init tangle

pre-init:
|-git -C $(mkfileDir) config include.path "$(mkfileDir)/.gitconfig"
|git -C $(mkfileDir) submodule add --depth 1 -f https://github.com/shadowrylander/settings.git
|git -C $(mkfileDir)/settings checkout main

tangle-setup:
|cp $(mkfileDir)/org-tangle.sh $(mkfileDir)/backup-tangle.sh
|chmod +x $(mkfileDir)/org-tangle.sh $(mkfileDir)/backup-tangle.sh

tangle: tangle-setup
|yes yes | fd . $(mkfileDir) \
    -HId 1 -e org \
    -E testing.aiern.org \
    -E resting.aiern.org \
    -x $(mkfileDir)/backup-tangle.sh
|fd . $(mkfileDir) \
    -HId 1 -e sh \
    -x chmod +x

subinit: init
|-git clone --depth 1 https://github.com/emacsmirror/epkgs.git $(mkfileDir)/epkgs
|-git -C $(mkfileDir)/epkgs checkout master
|-$(makefly) subinit
|git -C $(mkfileDir) submodule update --init --depth 1 --recursive
|git -C $(mkfileDir) submodule sync
# |git -C $(mkfileDir) submodule foreach 'git -C $$toplevel config submodule.$$name.ignore all'

pull: subinit
|git -C $(mkfileDir) pull

add:
|git -C $(mkfileDir) add .

commit:
|-git -C $(mkfileDir) commit --allow-empty-message -am ""

cammit: init add commit

push: cammit
|-git -C $(mkfileDir) push

super-push: tangle push

include tests.mk
