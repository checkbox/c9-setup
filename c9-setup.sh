#!/bin/sh
# This file is part of Checkbox.
#
# Copyright 2014 Canonical Ltd.
# Written by:
#   Zygmunt Krynicki <zygmunt.krynicki@canonical.com>
#
# Checkbox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3,
# as published by the Free Software Foundation.
#
# Checkbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Checkbox.  If not, see <http://www.gnu.org/licenses/>.


# c9.io setup script for checkbox
# ===============================
# This script configures a fresh c9.io workspace
# for hacking on the Checkbox project.


check_os() {
    if [ ! -f /etc/os-release ]; then
        echo "Woah, /etc/os-release doesn't exist"
        echo "What are you running, Mac?"
        echo "This script is indended for c9.io, go and setup a workspace there"
        exit 255
    fi
    . /etc/os-release
    if [ $ID != "ubuntu" ]; then
        echo "Only Ubuntu is currently supported on c9.io"
        exit 254
    fi
    if [ $VERSION_ID != "14.04" ]; then
        echo "Only Ubuntu 14.04 is currently supported on c9.io"
        exit 253
    fi
}

mkdir_src() {
    if [ -d "$HOME/src" ]; then
        echo "mkdir ~/src: ok"
    else
        echo "Creating ~/src for all our external code"
        mkdir -p "$HOME/src"
    fi
}

mkdir_bin() {
    if [ -d "$HOME/bin" ]; then
        echo "mkdir ~/bin: ok"
    else
        echo "Creating ~/bin for all our scripting needs"
        mkdir -p "$HOME/bin"
        export PATH="$PATH:$HOME/bin"
        echo "NOTE: you have to open a new terminal changes to PATH"
    fi
}

_is_installed() {
    [ "$(dpkg-query -s $1 2>/dev/null | grep '^Status:')" = "Status: install ok installed" ]
}

gitlp_get_deps() {
    local wanted_pkgs="git bzr bzr-fastimport git-flow patch"
    local pkgs_to_install=""
    local pkg=""
    for pkg in $wanted_pkgs; do
        if ! _is_installed $pkg; then
            echo "Installing package $pkg"
            pkgs_to_install="$pkgs_to_install $pkg"
        fi
    done
    if [ -z "$pkgs_to_install" ]; then
        echo "git-lp deps: ok"
    else
        sudo apt-get install --quiet --yes $pkgs_to_install
    fi
}

gitlp_patch_bzrlib() {
    local file=/usr/lib/python2.7/dist-packages/bzrlib/index.py
    local vanilla=917f04f90bc54f1ef6fd45c7f62544ce
    local patched=be697c0baccfae2641fd1ed036e96334
    local actual=$(md5sum $file | cut -f 1 -d ' ')
    case $actual in
        $vanilla)
            sudo patch -p1 $file $HOME/src/git-lp/bzr.patch
            ;;
        $patched)
            echo "patch bzrlib: ok"
            ;;
        *)
            echo "patch bzrlib: unsupported"
            ;;
    esac
}

gitlp_install_symlink() {
    if [ -h $HOME/bin/git-lp ] && [ $(readlink $HOME/bin/git-lp) = "$HOME/src/git-lp/git-lp" ]; then
        echo "git-lp exec: ok"
    else
        echo "Installing git-lp into ~/bin"
        ln -fs $HOME/src/git-lp/git-lp $HOME/bin/git-lp
    fi
}

gitlp_clone_repo() {
    if [ -d $HOME/src/git-lp ]; then
        echo "git-lp repo: ok"
    else
        echo "Getting git-lp, the amazing git collaboration suite for bzr"
        git clone --quiet git://github.com/zyga/git-lp.git $HOME/src/git-lp
    fi
}

deploy_gitlp() {
    mkdir_src
    mkdir_bin
    gitlp_get_deps
    gitlp_clone_repo
    gitlp_patch_bzrlib
    gitlp_install_symlink
}


setup_bzr() {
    if bzr lp-login >/dev/null 2>&1; then
        echo "launchpad account: ok"
    else
        echo "What is your launchpad.net username?"
        read LP_USERNAME
        bzr lp-login $LP_USERNAME
    fi
}

setup_checkbox() {
    if [ ! -d $HOME/workspace ]; then
        echo "Where is your c9 workspace directory?"
        return
    fi
    if [ -e $HOME/workspace/.git ]; then
        echo "Remove the .git directory from your workspace"
        return
    fi
    if [ -e $HOME/workspace/README.md ]; then
        echo "Remove the README.md file from your workspace"
        return
    fi
    echo "Setting up ~/workspace/.git for checkbox"
    ( cd /tmp && git lp init checkbox )
    mv /tmp/checkbox/.git $HOME/workspace/
    rm -rf /tmp/checkbox
    echo "Getting all the bits (this takes time)"
    ( cd $HOME/workspace && git lp fetch )
    echo "Switching your repository to trunk aka launchpad/+upstream"
    ( cd $HOME/workspace && git checkout launchpad/+upstream )
}

deploy_gitlp
# setup_bzr
setup_checkbox

