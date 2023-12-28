#!/bin/bash

# VARIABLES, CHANGE AS NEEDED
GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
PROJECT_NAME=$(basename $GITHUB_REPO | cut -d '.' -f 1)
TMP_DIR="${TMPDIR:-$(dirname $(mktemp))}"

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
  echo "user_pref(\"$1\", $2);" >> $PROFILE_ROOTDIR/user.js;
}

delete_pref() {
  echo "resetting $(echo $1 | cut -d '"' -f 2) to default";
  Userjs=$PROFILE_ROOTDIR/user.js
  grep -v $1 $Userjs > "$Userjs.tmp"
  mv "$Userjs.tmp" $Userjs
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
  ans="n"
  read -e -p "Do you want to delete $PROFILE_ROOTDIR/chrome? [y/N]: " in
  ans="${in:-$ans}";

  if [[ ${ans,,} =~ ^(yes|y)$ ]]; then
    rm -rf $PROFILE_ROOTDIR/chrome;
  fi

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
    delete_pref ${FETCHED_PREFS[i]};
  done;

  ans="n"
  echo -e "${CYAN}NOTE: enter 'a' to answer 'yes' to all questions.${NC}";
  for ((i = 0; i < ${#OPTIONALS[@]}; i+=2)); do
    setting="user_pref(\"${OPTIONALS[i]}\", ${OPTIONALS[i+1]});";

    if [[ ! ${ans,,} =~ ^(all|a)$ ]]; then
      ans="n"
      read -e -p "Remove setting $setting from user.js? [y/a/N]: " in
      ans="${in:-$ans}";

      
      if [[ ! ${ans,,} =~ ^(yes|y|all|a)$ ]]; then
        continue;
      fi
    fi;

    delete_pref $setting;
  done;

  echo "uninstall complete."
  exit 0;
fi

#################
# INSTALL PHASE #
#################

echo "Installing..."
if ! curl -L "https://github.com/bmFtZQ/edge-frfox/archive/refs/heads/main.tar.gz" | tar xz -C $TMP_DIR --strip-components=1 --one-top-level=$PROJECT_NAME; then
  echo -e "${RED}Installation failed: ${NC}Failed to get github repo tarball and extract it";
  exit 0;
fi

echo "Copying theme folder...";
cp -r $TMP_DIR/$PROJECT_NAME/chrome $PROFILE_ROOTDIR;
cat $TMP_DIR/$PROJECT_NAME/user.js | tee -a $PROFILE_ROOTDIR/user.js >/dev/null;

#####################
# OPTIONAL SETTINGS #
#####################

echo "Optional settings, refer to https://github.com/bmFtZQ/edge-frfox/tree/main#how-to-install";
for ((i = 0; i < ${#OPTIONALS[@]}; i += 2)); do
  ans="n"
  read -e -p "Set ${OPTIONALS[i]} to ${OPTIONALS[i+1]?} [y/N]: " in
  ans="${in:-$ans}";

  if [[ ! ${ans,,} =~ ^(yes|y)$ ]]; then
    continue;
  fi

  set_pref ${OPTIONALS[i]} ${OPTIONALS[i+1]}

done;


echo -e "${GREEN}Finished successfully! Please start firefox to see the changes.";
