#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# ANSI styling
bold=$(tput bold)
blue=$(tput setaf 4)
green=$(tput setaf 2)
magenta=$(tput setaf 5)
red=$(tput setaf 1)
reset=$(tput sgr0)
yellow=$(tput setaf 3)

# Draw a box around text
print_box() {
  local txt="$1"
  local color="${2:-}"
  # split into lines
  mapfile -t lines <<<"$txt"
  declare -a disp_lens
  # compute maximum line length
  local max=0

  for line in "${!lines[@]}"; do
    local raw="${lines[line]}"
    local disp=0 prev_code=0 fudge=0

    # read each code‑point (UTF‑8 locale)
    while IFS= read -r -n1 ch; do
      [[ -z $ch ]] && break

      # codepoint integer
      local code
      code=$(printf '%d' "'$ch")

      # skip zero‑width joiner
      if ((code == 0x200D)); then
        continue
      fi

      # if it's VS‑16, only pad if the base wasn't already counted as "wide"
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

      # classify wide vs narrow
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

    # tack on that single‑column VS‑16 fudge where needed
    disp=$((disp + fudge))

    disp_lens[line]=$disp
    ((disp > max)) && max=$disp
  done

  local border=$((max + 4))
  # top border
  printf "\n${bold}${color}╭%*s╮\n" "$border" '' | tr ' ' '─'

  # centered lines
  for i in "${!lines[@]}"; do
    local line="${lines[i]}"
    local dlen=${disp_lens[i]}
    local pad=$((max - dlen))
    local left=$((pad / 2))
    local right=$((pad - left))
    printf "│${reset}%*s%s%*s${color}│\n" $((left + 2)) "" "$line" $((right + 2)) ""
  done

  # bottom border
  printf "╰%*s╯${reset}\n\n" "$border" '' | tr ' ' '─'
}

# Validate variable against regex
validate_var() {
  local name="$1" value="$2" regex="$3"

  if [[ ! "$value" =~ $regex ]]; then
    print_box "❌ Error : invalid $name [ $value ]" "${red}"
    exit 1
  fi
}

# Prompt for input with default and optional non-empty validation
prompt_input() {
  local prompt="$1" default="$2" allow_empty="${3:-false}" val

  while true; do
    if [[ -n "$default" ]]; then
      read -e -rp "$prompt [ ${green}$default${reset} ] : " val
      val="${val:-$default}"
    else
      read -e -rp "$prompt : " val
    fi

    # if empty allowed or value non-empty, accept
    if [[ "$allow_empty" == "true" ]] || [[ -n "$val" ]]; then
      echo "$val"
      return
    fi

    echo "${red}❗ Value cannot be empty${reset}"
  done
}

# Prompt for yes/no with arrow keys
prompt_confirm() {
  local opts=(Yes No) cursor=0 key

  while true; do
    # build display : highlight selected option in green
    local left=${opts[0]} right=${opts[1]}

    if ((cursor == 0)); then
      printf "\r${bold}[ ${green}%s${reset}${bold} / %s ]${reset}" "$left" "$right"
    else
      printf "\r${bold}[ %s / ${green}%s${reset}${bold} ]${reset}" "$left" "$right"
    fi

    read -rsn3 key

    case "$key" in
    $'\x1b[C' | $'\x1b[B') ((cursor = (cursor + 1) % 2)) ;; # → or ↓
    $'\x1b[D' | $'\x1b[A') ((cursor = (cursor + 1) % 2)) ;; # ← or ↑
    "") break ;;                                            # Enter
    esac
  done

  printf "\n"
  [[ "${opts[cursor]}" == "Yes" ]]
}

# Parse flags : require -a|--ci for other params
CI_MODE=false

for arg in "$@"; do [[ "$arg" =~ ^(-a|--ci)$ ]] && CI_MODE=true; done

# Defaults
DIR="$HOME/"
FOLDER="unzip-bot-EDM115"
ENV_FILE=""
WORKING_DIR=$(pwd)

# Argument parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    print_box $'ℹ️ Usage : setup.sh [options]\n\n⚙️  Options :\n-a|--ci • Run in CI mode (automated)\n-e|--env • Path to env file (required in CI mode)\n-d|--dir • Directory to clone into (current/home)\n-f|--folder • Folder name to clone into\n-h|--help • Display this help message' "${blue}"
    exit 0
    ;;
  -a | --ci)
    shift
    ;;
  -e | --env)
    if ! $CI_MODE; then
      print_box "❌ Error : -e|--env requires -a|--ci" "${red}"
      exit 1
    fi

    ENV_FILE="$2"
    shift 2
    ;;
  -d | --dir)
    if ! $CI_MODE; then
      print_box "❌ Error : -d|--dir requires -a|--ci" "${red}"
      exit 1
    fi

    case "$2" in
    current) DIR=$(realpath ".") ;; home) DIR=$(realpath "~") ;;
    *)
      print_box '❌ Error : -d|--dir must be "current" or "home"' "${red}"
      exit 1
      ;;
    esac

    shift 2
    ;;
  -f | --folder)
    if ! $CI_MODE; then
      print_box "❌ Error : -f|--folder requires -a|--ci" "${red}"
      exit 1
    fi

    FOLDER=$(realpath "$2")
    shift 2
    ;;
  *)
    print_box "❓ Unknown option : $1" "${red}"
    exit 1
    ;;
  esac
done

# 1) Welcome & confirm
print_box $'⚡ unzip-bot setup script ⚡\n👨‍💻 By EDM115 👨‍💻\n\nThis script allows you to easily set up the unzip-bot on your VPS !' "${blue}"
printf "%sℹ️ Automated usage available, run with -h|--help for more info%s\n\n" "${magenta}" "${reset}"

if $CI_MODE; then
  printf "%s‼️ CI mode : proceeding without confirmation%s\n\n" "${red}" "${reset}"
else
  prompt_confirm "Proceed with setup ?" || {
    print_box "❌ Setup aborted" "${red}"
    exit 0
  }
fi

# In CI mode, env file is mandatory
printf "\n%s--- ⚙️  Step 1 : Configuration ---%s\n\n" "${yellow}" "${reset}"

if $CI_MODE; then
  if [[ -z "$ENV_FILE" ]]; then
    print_box "❌ Error : in CI mode, -e|--env is required" "${red}"
    exit 1
  fi

  if [[ ! -f "$ENV_FILE" ]]; then
    print_box "❌ Error : env file $ENV_FILE not found" "${red}"
    exit 1
  fi

  printf "%s❗ CI mode, skipping configuration prompts%s\n\n" "${blue}" "${reset}"
else
  printf "%sℹ️ Tip : Press Enter to accept default values%s\n\n" "${magenta}" "${reset}"
  # ask directory
  dir_choice=$(prompt_input 'Install directory ("current" or "home")' "home")

  case "$dir_choice" in
  current) DIR=$(realpath ".") ;;
  home) DIR=$(realpath "~") ;;
  *)
    print_box "❌ Error : invalid choice [ $dir_choice ]" "${red}"
    exit 1
    ;;
  esac

  # ask folder name
  FOLDER=$(prompt_input "Folder name to clone into" "$FOLDER")
  # ask env file path
  ENV_FILE=$(prompt_input "Path to env file containing pre-filled values (optional)" "" true)
fi

if [[ -n "$ENV_FILE" && ! "$ENV_FILE" =~ ^/ ]]; then
  ENV_FILE="$WORKING_DIR/$ENV_FILE"
fi

# 2) Clone repo into named folder
TARGET="${DIR%/}/$FOLDER"
printf "\n%s--- 📋 Step 2 : Cloning repository into %s... ---%s\n\n" "${yellow}" "$TARGET" "${reset}"
parent_dir=$(dirname "$TARGET")

# Check write permission on parent directory
if [[ ! -w "$parent_dir" ]]; then
  print_box "❌ Error : no write permission to $parent_dir" "${red}"
  exit 1
fi

git clone --quiet https://github.com/EDM115/unzip-bot.git "$TARGET"
cd "$TARGET"

# 3) Prepare .env
printf "\n%s--- 📝 Step 3 : Preparing .env file ---%s\n\n" "${yellow}" "${reset}"
# variable definitions and regex patterns
vars=(APP_ID API_HASH BOT_OWNER BOT_TOKEN MONGODB_DBNAME MONGODB_URL LOGS_CHANNEL)

declare -A regexes=(
  [APP_ID]='^[0-9]+$'
  [API_HASH]='^[A-Fa-f0-9]+$'
  [BOT_OWNER]='^[0-9]+$'
  [BOT_TOKEN]='^[0-9]+:[A-Za-z0-9_-]+$'
  [MONGODB_DBNAME]='^[A-Za-z0-9._-]+$'
  [MONGODB_URL]='^.+://.+$'
  [LOGS_CHANNEL]='^-?[0-9]+$'
)

if [[ -z "$ENV_FILE" ]]; then
  ENV_FILE="${TARGET}/.env"
fi

if $CI_MODE; then
  # load and validate from ENV_FILE
  for name in "${vars[@]}"; do
    val=$(grep -E "^$name=" "$ENV_FILE" |
      cut -d= -f2- |
      tr -d $'\r')
    [[ -n "$val" ]] || {
      print_box "❌ Error : $name missing in $ENV_FILE" "${red}"
      exit 1
    }
    validate_var "$name" "$val" "${regexes[$name]}"
    echo "$name=$val" >>.env
  done
else
  # interactive prompts
  # read existing .env defaults if present
  declare -A defaults

  if [[ -f $ENV_FILE ]]; then
    while IFS= read -r line; do
      line="${line//$'\r'/}"
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      key="${line%%=*}"
      val="${line#*=}"

      for want in "${vars[@]}"; do
        if [[ "$key" == "$want" ]]; then
          defaults[$key]="$val"
          break
        fi
      done
    done <"$ENV_FILE"

    printf "%sℹ️ Tip : Press Enter to accept default values%s\n\n" "${magenta}" "${reset}"
  fi

  for name in "${vars[@]}"; do
    default="${defaults[$name]:-}"
    prompt="Enter $name"
    val=$(prompt_input "$prompt" "$default")
    validate_var "$name" "$val" "${regexes[$name]}"
    echo "$name=$val" >>.env
  done
fi

printf "\n%s✅ .env file filled%s\n\n" "${green}" "${reset}"

# 4) Build Docker image
printf "\n%s--- 🛠️ Step 4 : Building Docker image ---%s\n\n" "${yellow}" "${reset}"
docker build -t edm115/unzip-bot .

# 5) Run Docker container
printf "\n%s--- 🚀 Step 5 : Starting Docker container ---%s\n\n" "${yellow}" "${reset}"
docker run -d \
  -v downloaded-volume-prod:/app/Downloaded \
  -v thumbnails-volume-prod:/app/Thumbnails \
  --env-file ./.env \
  --name unzipbot edm115/unzip-bot
print_box $'✅ Setup complete\nThe bot is running, check Telegram !' "${green}"
info=$(docker inspect -f $'ℹ️ Docker info\n\nID : {{.Id}}\nName : {{.Name}}\nStatus : {{.State.Status}}\nImage : {{.Config.Image}}\nCreated at : {{.Created}}' unzipbot)
print_box "$info" "${blue}"
