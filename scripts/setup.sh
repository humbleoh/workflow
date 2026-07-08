#!/bin/bash +x

CURDIR=$(dirname $(readlink -f ${BASH_SOURCE}))
TOPDIR=${CURDIR}/..
CONFDIR=${TOPDIR}/config

echo "Link .vimrc"
ln -sf ${CONFDIR}/.vimrc ~/.vimrc

echo "Update .bashrc"
egrep -rni "bashrc_profile" ~/.bashrc &>/dev/null || \
  echo "source ${CURDIR}/bashrc_profile" >> ~/.bashrc

for conf in $(ls $CONFDIR); do
    echo "Link $conf"
    ln -sf $CONFDIR/$conf ~/.config/opencode/$conf
done

