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

for conf in $(ls $CONFDIR); do
    echo "Link $conf"
    ln -sf $CONFDIR/$conf ~/.config/opencode/$conf
done

OPENCODE_CONFIG=~/.config/opencode/opencode.jsonc
SKILLS_PATH="${SKILLSDIR}/superpowers/skills/"

echo "Update opencode skills path"
if jq -e --arg p "$SKILLS_PATH" '(.skills.paths // []) | any(. == $p)' "$OPENCODE_CONFIG" > /dev/null 2>&1; then
    echo "  skills path already present, skipping"
else
    echo "  adding skills path: $SKILLS_PATH"
    tmp=$(mktemp)
    jq --arg p "$SKILLS_PATH" '.skills.paths = ((.skills.paths // []) + [$p])' \
        "$OPENCODE_CONFIG" > "$tmp" && mv "$tmp" "$OPENCODE_CONFIG"
fi
