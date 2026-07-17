#!/bin/bash +x

CURDIR=$(dirname $(readlink -f ${BASH_SOURCE}))
TOPDIR=${CURDIR}/..
CONFDIR=${TOPDIR}/config
SKILLSDIR=${TOPDIR}/skills

echo "Link .vimrc"
ln -sf ${CONFDIR}/.vimrc ~/.vimrc

echo "Update .bashrc"
egrep -rni "bashrc_profile" ~/.bashrc &>/dev/null || \
  echo "source ${CURDIR}/bashrc_profile" >> ~/.bashrc

echo "Update locale"
egrep -rni "LC_ALL" ~/.bashrc &>/dev/null || \
  echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc

for conf in $(ls $CONFDIR); do
    echo "Link $conf"
    ln -sf $CONFDIR/$conf ~/.config/opencode/$conf
done

echo "Update gitconfig"
git config --global core.editor "vim"
git config --global core.quotepath false
git config --global diff.tool meld
git config --global difftool.prompt false
git config --global difftool.meld.cmd "meld \"\$LOCAL\" \"\$REMOTE\""

echo "Update tmux config"
egrep -rni "set -g mouse on" ~/.tmux.conf &>/dev/null || \
  echo "set -g mouse on" >> ~/.tmux.conf

OPENCODE_CONFIG=~/.config/opencode/opencode.jsonc
SKILLS_PATH="${SKILLSDIR}/superpowers/skills/"

echo "Update opencode global AGENTS.md"
ln -sf ${SKILLSDIR}/AGENTS.md ~/.config/opencode/AGENTS.md

echo "Update opencode skills path"
if jq -e --arg p "$SKILLS_PATH" '(.skills.paths // []) | any(. == $p)' "$OPENCODE_CONFIG" > /dev/null 2>&1; then
    echo "  skills path already present, skipping"
else
    echo "  adding skills path: $SKILLS_PATH"
    tmp=$(mktemp)
    jq --arg p "$SKILLS_PATH" '.skills.paths = ((.skills.paths // []) + [$p])' \
        "$OPENCODE_CONFIG" > "$tmp" && mv "$tmp" "$OPENCODE_CONFIG"
fi
