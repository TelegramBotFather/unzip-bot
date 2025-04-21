#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# ANSI styling
bold=$(tput bold)
reset=$(tput sgr0)
blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)

# Draw a box around text
print_box() {
  local txt="$1"
  local color="${2:-}"
  # split into lines
  mapfile -t lines <<<"$txt"
  # compute maximum line length
  local max=0

  for line in "${lines[@]}"; do
    local len=${#line}
    ((len > max)) && max=$len
  done

  local border=$((max + 4))
  # top border
  printf "\n${bold}${color}╭%*s╮\n" "$border" '' | tr ' ' '─'

  # centered lines
  for line in "${lines[@]}"; do
    local len=${#line}
    local pad=$((max - len))
    local left=$((pad / 2))
    local right=$((pad - left))
    printf "│${reset}%*s%s%*s${color}│\n" $((left + 2)) '' "$line" $((right + 2)) ''
  done

  # bottom border
  printf "╰%*s╯${reset}\n\n" "$border" '' | tr ' ' '─'
}

# Validate variable against regex
validate_var() {
  local name="$1" value="$2" regex="$3"

  if [[ ! "$value" =~ $regex ]]; then
    print_box "Error : invalid $name [ $value ]" "${red}"
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

    echo "${red}Value cannot be empty${reset}"
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
    print_box $'Usage : setup.sh [options]\n\nOptions :\n-a|--ci • Run in CI mode (automated)\n-e|--env • Path to env file (required in CI mode)\n-d|--dir • Directory to clone into (current/home)\n-f|--folder • Folder name to clone into\n-h|--help • Display this help message' "${blue}"
    exit 0
    ;;
  -a | --ci)
    shift
    ;;
  -e | --env)
    if ! $CI_MODE; then
      print_box "Error : -e|--env requires -a|--ci" "${red}"
      exit 1
    fi

    ENV_FILE="$2"
    shift 2
    ;;
  -d | --dir)
    if ! $CI_MODE; then
      print_box "Error : -d|--dir requires -a|--ci" "${red}"
      exit 1
    fi

    case "$2" in
    current) DIR=$(realpath ".") ;; home) DIR=$(realpath "~") ;;
    *)
      print_box 'Error : -d|--dir must be "current" or "home"' "${red}"
      exit 1
      ;;
    esac

    shift 2
    ;;
  -f | --folder)
    if ! $CI_MODE; then
      print_box "Error : -f|--folder requires -a|--ci" "${red}"
      exit 1
    fi

    FOLDER=$(realpath "$2")
    shift 2
    ;;
  *)
    print_box "Unknown option : $1" "${red}"
    exit 1
    ;;
  esac
done

# 1) Welcome & confirm
print_box $'unzip-bot setup script\nBy EDM115\n\nThis script allows you to easily set up the unzip-bot on your VPS !' "${blue}"
printf "Automated usage available, run with -h|--help for more info.\n\n"

if $CI_MODE; then
  printf "%sCI mode : proceeding without confirmation%s\n\n" "${red}" "${reset}"
else
  prompt_confirm "Proceed with setup ?" || {
    print_box "Setup aborted" "${red}"
    exit 0
  }
fi

# In CI mode, env file is mandatory
printf "\n--- Step 1 : Configuration ---\n\n"

if $CI_MODE; then
  if [[ -z "$ENV_FILE" ]]; then
    print_box "Error : in CI mode, -e|--env is required" "${red}"
    exit 1
  fi

  if [[ ! -f "$ENV_FILE" ]]; then
    print_box "Error : env file $ENV_FILE not found" "${red}"
    exit 1
  fi

  printf "%sCI mode, skipping configuration prompts%s\n\n" "${blue}" "${reset}"
else
  printf "Tip : Press Enter to accept default values\n\n"
  # ask directory
  dir_choice=$(prompt_input 'Install directory ("current" or "home")' "home")

  case "$dir_choice" in
  current) DIR=$(realpath ".") ;;
  home) DIR=$(realpath "~") ;;
  *)
    print_box "Error : invalid choice [ $dir_choice ]" "${red}"
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
printf "\n--- Step 2 : Cloning repository into %s... ---\n\n" "$TARGET"
parent_dir=$(dirname "$TARGET")

# Check write permission on parent directory
if [[ ! -w "$parent_dir" ]]; then
  print_box "Error : no write permission to $parent_dir" "${red}"
  exit 1
fi

git clone --quiet https://github.com/EDM115/unzip-bot.git "$TARGET"
cd "$TARGET"

# 3) Prepare .env
printf "\n--- Step 3 : Preparing .env file ---\n\n"
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
      print_box "Error : $name missing in $ENV_FILE" "${red}"
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

    printf "Tip : Press Enter to accept default values\n\n"
  fi

  for name in "${vars[@]}"; do
    default="${defaults[$name]:-}"
    prompt="Enter $name"
    val=$(prompt_input "$prompt" "$default")
    validate_var "$name" "$val" "${regexes[$name]}"
    echo "$name=$val" >>.env
  done
fi

printf "\n%s.env file filled%s\n\n" "${green}" "${reset}"

# 4) Build Docker image
printf "\n--- Step 4 : Building Docker image ---\n\n"
docker build -t edm115/unzip-bot .

# 5) Run Docker container
printf "\n--- Step 5 : Starting Docker container ---\n\n"
docker run -d \
  -v downloaded-volume-prod:/app/Downloaded \
  -v thumbnails-volume-prod:/app/Thumbnails \
  --env-file ./.env \
  --name unzipbot edm115/unzip-bot
print_box $'Setup complete\nThe bot is running, check Telegram !' "${green}"
info=$(docker inspect -f $'ID : {{.Id}}\nName : {{.Name}}\nStatus : {{.State.Status}}\nImage : {{.Config.Image}}\nCreated at : {{.Created}}' unzipbot)
print_box "$info" "${blue}"
