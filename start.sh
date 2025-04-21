#!/bin/bash

set -euo pipefail

bold=$(tput bold)
reset=$(tput sgr0)
green=$(tput setaf 2)
red=$(tput setaf 1)

print_box() {
  local txt="$1"
  local color="${2:-}"
  mapfile -t lines <<<"$txt"
  local max=0

  for line in "${lines[@]}"; do
    local len=${#line}
    ((len > max)) && max=$len
  done

  local border=$((max + 4))
  printf "\n${bold}${color}╭%*s╮\n" "$border" '' | tr ' ' '─'

  for line in "${lines[@]}"; do
    local len=${#line}
    local pad=$((max - len))
    local left=$((pad / 2))
    local right=$((pad - left))
    printf "│${reset}%*s%s%*s${color}│\n" $((left + 2)) '' "$line" $((right + 2)) ''
  done

  printf "╰%*s╯${reset}\n\n" "$border" '' | tr ' ' '─'
}

print_box $'\n🔥 unzip-bot 🔥\n\n» Copyright (c) 2022 - 2025 EDM115\n» MIT License\n\n»» Join @EDM115bots on Telegram\n»» Follow EDM115 on GitHub\n\n' "${green}"

if [ -f .env ] && [[ ! "$DYNO" =~ ^worker.* ]]; then
  if grep -qE '^[^#]*=\s*("|'\''?)\s*\1\s*$' .env; then
    print_box "Some required vars are empty, please fill them unless you're filling them somewhere else (ex : Heroku, Docker Desktop)" "${red}"
  else
    while IFS='=' read -r key value; do
      if [[ ! $key =~ ^# && -n $key ]]; then
        export "$key=$value"
      fi
    done <.env
  fi
fi

exec python -m unzipbot
