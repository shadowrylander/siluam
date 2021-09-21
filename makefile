.RECIPEPREFIX := |
.DEFAULT_GOAL := emacs

# Adapted From: https://www.systutorials.com/how-to-get-the-full-path-and-directory-of-a-makefile-itself/
mkfilePath := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfileDir := $(dir $(mkfilePath))

init: pre-init tangle

pre-init:
|-fd . -HIt d -t e -x rm -rf
|-git -C $(mkfileDir) config include.path "$(mkfileDir)/.gitconfig"

tangle-setup:
|cp $(mkfileDir)/settings/org-tangle.sh $(mkfileDir)/settings/backup-tangle.sh
|chmod +x $(mkfileDir)/settings/org-tangle.sh $(mkfileDir)/settings/backup-tangle.sh

tangle: tangle-setup
|yes yes | fd . $(mkfileDir) \
    -HId 1 -e org \
    -E testing.aiern.org \
    -E resting.aiern.org \
    -x $(mkfileDir)/settings/backup-tangle.sh
|fd . $(mkfileDir)/settings \
    -HIe sh \
    -x chmod +x

subinit: init
|-git clone --depth 1 https://github.com/emacsmirror/epkgs.git $(mkfileDir)/epkgs
|-git -C $(mkfileDir)/epkgs checkout master
|-git clone --depth 1 https://github.com/emacsmirror/epkgs.git $(mkfileDir)/var/epkgs
|-git -C $(mkfileDir)/var/epkgs checkout master

# Adapted From:
# Answer: https://stackoverflow.com/a/56621295/10827766
# User: https://stackoverflow.com/users/1600536/alim-giray-aytar
|git -C $(mkfileDir) submodule update --force --init --depth 1 --recursive --remote

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
