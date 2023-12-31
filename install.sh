#!/bin/bash

# VARIABLES, CHANGE AS NEEDED
GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
PROJECT_NAME=$(basename $GITHUB_REPO | cut -d '.' -f 1)

if [[ $OSTYPE == "darwin"* ]]; then
  FIREFOX_DIR="$HOME/Library/Application Support/Firefox"
else
  FIREFOX_DIR=$HOME/.mozilla/firefox
fi;

PROFILE_ROOTDIR=$FIREFOX_DIR/$(grep -E "Path=.*\.(dev-edition-default|default-.*)" "$FIREFOX_DIR/profiles.ini" | tail -1 | cut -c 6-);
OPTIONALS=(
  "widget.macos.native-context-menus" "false"
  "browser.theme.dark-private-windows" "false"
)

# COLORS
GREEN='\033[0;32m'
YELLOW='\033[0;93m'
NC='\033[0m'
CYAN='\033[0;36m'
RED='\033[0;31m'

# UTILITY FUNCTIONS
set_pref() {
  echo "setting $1 to $2 in user.js";
  echo "user_pref(\"$1\", $2);" >> "$PROFILE_ROOTDIR/user.js";
}

delete_pref() {
  echo "resetting $(echo $1 | cut -d '"' -f 2) to default";
  case $(sed --help 2>&1) in
    *GNU*) sed_i () { sed -i "$@"; };;
    *) sed_i () { sed -i '' "$@"; };;
  esac

  sed_i "/$1/d" "$PROFILE_ROOTDIR/user.js"

  if $2; then
    sed_i "/$1/d" "$PROFILE_ROOTDIR/prefs.js"
  fi;
}

ask_question() {
  local defaultAns="$2"
  
  read -e -p "$1" in
  defaultAns="${in:-$defaultAns}";
  defaultAns="$(echo $defaultAns | tr '[:upper:]' '[:lower:]')"
  [[ $defaultAns =~ ^(yes|y)$ ]];
}

#####################
# PRE-INSTALL PHASE #
#####################

firefox_proc=$(pgrep firefox);
if [ ! -z $firefox_proc ]; then
  echo "Before (un)installing, please make sure firefox is not running."
  echo "Otherwise, changes cannot be made to user.js"
  exit 0;
fi

# Prompting for correct install directory
echo "Please enter the path to your firefox profile directory."
echo "This can be found by opening about:support in firefox and looking for the Profile root directory."
echo "Press CTRL+C to abort installation now."

echo -e "${CYAN}Automatically detected: $PROFILE_ROOTDIR${NC}"
read -e -p "Press ENTER to use this directory, or type in a new one: " newdir
PROFILE_ROOTDIR="${newdir:-$PROFILE_ROOTDIR}"

if [ ! -d "$PROFILE_ROOTDIR" ]; then
  echo "ERROR: firefox profile directory could not be found"

  while [ ! -d "$PROFILE_ROOTDIR" ]; do
    read -p "Enter active root directory found in \"about:profiles\" here: " PROFILE_ROOTDIR;

    if [ ! -d "$PROFILE_ROOTDIR" ]; then
      echo "invalid directory: specified location does not exist. Try again..."
    fi
  done;
fi

# Check if issued `./installer.sh uninstall`
if [[ $1 == "uninstall" ]]; then
  echo -e "${YELLOW}NOTE: This is the final opportunity to abort uninstallation by pressing Ctrl+C${NC}";
  if ask_question "Delete all files in $PROFILE_ROOTDIR/chrome? [Y/n]: " "y"; then
    rm -rf "$PROFILE_ROOTDIR/chrome";
  fi;

  if ask_question "Reset settings in about:config to default? (a backup of user.js and prefs.js will be created if yes) [y/N]: " "n"; then
    reset_all=true;
  else
    reset_all=false;
  fi;

  if $reset_all; then
    cp "$PROFILE_ROOTDIR/prefs.js" "$PROFILE_ROOTDIR/prefs.js.bak";
    cp "$PROFILE_ROOTDIR/user.js" "$PROFILE_ROOTDIR/user.js.bak";
  fi;

  # Download changed user.js from online
  FETCHED_PREFS=();
  if ping -c 1 raw.githubusercontent.com &> /dev/null; then
    while read l;
      do FETCHED_PREFS+=("$l");
    done < <(curl -s "https://raw.githubusercontent.com/bmFtZQ/edge-frfox/main/user.js" | grep -E "user_pref\(\"([a-zA-Z0-9.-]+)\",\s*(true|false)\);")
  else
    echo -e "${YELLOW}WARNING: Failed to retrieve online user.js prefs. Continuing...${NC}"
  fi;

  for ((i = 0; i < ${#FETCHED_PREFS[@]}; i++)); do
    delete_pref "${FETCHED_PREFS[i]}" $reset_all;
  done;

  ans="y"
  echo -e "${CYAN}NOTE: enter 'a' to answer 'yes' to all questions.${NC}";
  for ((i = 0; i < ${#OPTIONALS[@]}; i+=2)); do
    setting="user_pref(\"${OPTIONALS[i]}\", ${OPTIONALS[i+1]});";

    if [[ ! "$ans" =~ ^(all|a)$ ]]; then
      if ! grep -qF "$setting" "$PROFILE_ROOTDIR/user.js" --no-messages; then
        continue;
      fi;

      ans="y"
      read -e -p "Remove setting $setting from user.js? [Y/a/n]: " in
      ans="${in:-$ans}";
      ans="$(echo "$ans" | tr '[:upper:]' '[:lower:]')"

      
      if [[ ! "$ans" =~ ^(yes|y|all|a)$ ]]; then
        continue;
      fi
    fi;

    delete_pref "$setting" $reset_all;
  done;

  echo "uninstall complete."
  exit 0;
fi

#################
# INSTALL PHASE #
#################

echo "Installing..."
TMP_DIR=$(mktemp -d -t "$PROJECT_NAME.XXXXXX");
if ! curl -L "https://github.com/bmFtZQ/edge-frfox/archive/refs/heads/main.tar.gz" | tar xz -C $TMP_DIR --strip-components=1; then
  echo -e "${RED}Installation failed: ${NC}Failed to get github repo tarball and extract it";
  exit 0;
fi

echo "Copying theme folder...";
cp -r $TMP_DIR/chrome "$PROFILE_ROOTDIR";
cat $TMP_DIR/user.js | 
  while read line; do
    path="$PROFILE_ROOTDIR/user.js";
    if ! grep -qF "$line" "$path" --no-messages; then
      echo "$line" >> "$path";
    fi;
  done;

#####################
# OPTIONAL SETTINGS #
#####################

echo "Optional settings, refer to https://github.com/bmFtZQ/edge-frfox/tree/main#how-to-install";
for ((i = 0; i < ${#OPTIONALS[@]}; i += 2)); do
  if grep -qF "user_pref(\"${OPTIONALS[i]}\", ${OPTIONALS[i+1]});" "$PROFILE_ROOTDIR/user.js" --no-messages; then
    continue;
  fi;

  if ! ask_question "Set ${OPTIONALS[i]} to ${OPTIONALS[i+1]}? [y/N]: " "n"; then
    continue;
  fi;

  set_pref ${OPTIONALS[i]} ${OPTIONALS[i+1]}

done;


echo -e "${GREEN}Finished successfully! Please start firefox to see the changes.";
