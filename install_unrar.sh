#!/bin/bash

# unrar build and install script
# origin : https://github.com/linuxserver/docker-sabnzbd/blob/444da02e31823289c4d4ca6ab407442bf6719e94/Dockerfile#L28-L38
# source : https://www.reddit.com/r/AlpineLinux/comments/13p4p5k/comment/jmrdr24/
# get letest unrar version : https://www.rarlab.com/rar_add.htm
set -euo pipefail
UNRAR_VERSION="7.1.6"

green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
yellow=$(tput setaf 3)

printf "\n%sℹ️ Installing unrar version %s%s\n" "${yellow}" "${UNRAR_VERSION}" "${reset}"
mkdir /tmp/unrar
curl -o \
  /tmp/unrar.tar.gz -L \
  "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz"

tar xf \
  /tmp/unrar.tar.gz -C \
  /tmp/unrar --strip-components=1
cd /tmp/unrar || {
  printf "%s❌ Failed to change directory to /tmp/unrar%s\n" "${red}" "${reset}"
  exit 1
}

make || {
  printf "%s❌ Make command failed%s\n" "${red}" "${reset}"
  exit 1
}
install -v -m755 unrar /usr/local/bin || {
  printf "%s❌ Installation of unrar failed%s\n" "${red}" "${reset}"
  exit 1
}
printf "\n%s✅ unrar version $(unrar -iver) installed successfully%s\n" "${green}" "${reset}"
