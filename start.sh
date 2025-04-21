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
  declare -a disp_lens
  local max=0

  for line in "${!lines[@]}"; do
    local raw="${lines[line]}"
    local disp=0 prev_code=0 fudge=0

    while IFS= read -r -n1 ch; do
      [[ -z $ch ]] && break

      local code
      code=$(printf '%d' "'$ch")

      if ((code == 0x200D)); then
        continue
      fi

      if ((code == 0xFE0F)); then
        if (((\
          prev_code >= 0x1100 && prev_code <= 0x115F) || (\
          prev_code >= 0x2329 && prev_code <= 0x232A) || (\
          prev_code >= 0x2E80 && prev_code <= 0xA4CF) || (\
          prev_code >= 0xAC00 && prev_code <= 0xD7A3) || (\
          prev_code >= 0xF900 && prev_code <= 0xFAFF) || (\
          prev_code >= 0xFE10 && prev_code <= 0xFE19) || (\
          prev_code >= 0xFE30 && prev_code <= 0xFE6F) || (\
          prev_code >= 0xFF00 && prev_code <= 0xFF60) || (\
          prev_code >= 0xFFE0 && prev_code <= 0xFFE6) || (\
          prev_code >= 0x2600 && prev_code <= 0x26FF) || (\
          prev_code >= 0x2700 && prev_code <= 0x27BF) || (\
          prev_code >= 0x1F300 && prev_code <= 0x1F5FF) || (\
          prev_code >= 0x1F600 && prev_code <= 0x1F64F) || (\
          prev_code >= 0x1F900 && prev_code <= 0x1F9FF))) \
            ; then
          fudge=-1
        fi

        continue
      fi

      if (((\
        code >= 0x1100 && code <= 0x115F) || (\
        code >= 0x2329 && code <= 0x232A) || (\
        code >= 0x2E80 && code <= 0xA4CF) || (\
        code >= 0xAC00 && code <= 0xD7A3) || (\
        code >= 0xF900 && code <= 0xFAFF) || (\
        code >= 0xFE10 && code <= 0xFE19) || (\
        code >= 0xFE30 && code <= 0xFE6F) || (\
        code >= 0xFF00 && code <= 0xFF60) || (\
        code >= 0xFFE0 && code <= 0xFFE6) || (\
        code >= 0x2600 && code <= 0x26FF) || (\
        code >= 0x2700 && code <= 0x27BF) || (\
        code >= 0x1F300 && code <= 0x1F5FF) || (\
        code >= 0x1F600 && code <= 0x1F64F) || (\
        code >= 0x1F900 && code <= 0x1F9FF))) \
          ; then
        disp=$((disp + 2))
      else
        disp=$((disp + 1))
      fi

      prev_code=$code
    done <<<"$raw"

    disp=$((disp + fudge))
    disp_lens[line]=$disp
    ((disp > max)) && max=$disp
  done

  local border=$((max + 4))
  printf "\n${bold}${color}╭%*s╮\n" "$border" '' | tr ' ' '─'

  for i in "${!lines[@]}"; do
    local line="${lines[i]}"
    local dlen=${disp_lens[i]}
    local pad=$((max - dlen))
    local left=$((pad / 2))
    local right=$((pad - left))
    printf "│${reset}%*s%s%*s${color}│\n" $((left + 2)) "" "$line" $((right + 2)) ""
  done

  printf "╰%*s╯${reset}\n\n" "$border" '' | tr ' ' '─'
}

print_box $'\n🔥 unzip-bot 🔥\n\n» Copyright (c) 2022 - present EDM115\n» MIT License\n\n»» Join @EDM115bots on Telegram\n»» Follow EDM115 on GitHub\n\n' "${green}"

if [ -f .env ] && [[ ! "$DYNO" =~ ^worker.* ]]; then
  if grep -qE '^[^#]*=\s*("|'\''?)\s*\1\s*$' .env; then
    print_box "❗ Some required vars are empty, please fill them unless you're filling them somewhere else (ex : Heroku, Docker Desktop)" "${red}"
  else
    while IFS='=' read -r key value; do
      if [[ ! $key =~ ^# && -n $key ]]; then
        export "$key=$value"
      fi
    done <.env
  fi
fi

exec python -m unzipbot
