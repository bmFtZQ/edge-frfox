#!/bin/bash

# VARIABLES, CHANGE AS NEEDED
GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
PROFILE_ROOTDIR=~/.mozilla/firefox/$(grep Default= ~/.mozilla/firefox/installs.ini | tail -1 | cut -c 9-);
CHANGED_PREFS=("toolkit.legacyUserProfileCustomizations.stylesheets" "svg.context-properties.content.enabled" "layout.css.color-mix.enabled")

# UTILITY FUNCTIONS
set_pref() {
  echo "setting $1 to $2 in prefs.js";
  echo "user_pref(\"$1\", $2);" >> $PROFILE_ROOTDIR/prefs.js;
}

delete_pref() {
  echo "resetting $1 to default"
  sed -i "/user_pref(\"$1\", \(true\|false\));/d" $PROFILE_ROOTDIR/prefs.js;
}

#####################
# PRE-INSTALL PHASE #
#####################

firefox_proc=$(pgrep firefox);
if [ ! -z $firefox_proc ]; then
  echo "Before installing, please make sure firefox is not running."
  echo "Otherwise, changes cannot be made to prefs.js"
  exit 0;
fi

# Prompting for correct install directory
read -e -i "$PROFILE_ROOTDIR" -p "Enter profile root directory: " newdir
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
  echo "Warning: the following command will delete said folder and wipe out everything in its sub-directories"
  rm -rfi $PROFILE_ROOTDIR/chrome;
  echo "uninstalling...";
  for pref in ${CHANGED_PREFS[@]}; do
    delete_pref $pref;
  done;

  echo "uninstall complete."
  exit 0;
fi

git --version 2>&1 > /dev/null;
if [ ! $? -eq 0 ]; then
  echo "ERROR: git is not installed... Please install it."
  exit 0;
fi

echo "Detecting if firefox is installed on your system..."
if [ ! -f /usr/bin/firefox ] && { [ ! -f /usr/lib/firefox/firefox ] && [ ! -f /usr/lib/firefox-developer-edition/firefox ]; }; then
  echo "ERROR: firefox not found..."

  ans="y"
  read -e -i "$ans" -p "Do you want to continue anyway? (y/n): " in
  ans="${in:-$ans}";

  if [[ ! ${ans,,} =~ ^(yes|y)$ ]]; then
    exit 0;
  fi
fi

#################
# INSTALL PHASE #
#################

echo "Installing..."
if [ ! -d ~/github/edge-frfox ]; then
  echo "cloning repository";
  if ! git clone $GITHUB_REPO ~/github/edge-frfox; then
    echo "Error while cloning repository into ~/github/edge-frfox..."
    exit 0;
  fi
fi

echo "Copying theme folder..."
cp -r ~/github/edge-frfox/chrome "$PROFILE_ROOTDIR"

# firefox will automatically sort out any duplicate issues, whatever is at the end of the file takes priority, so this works.
echo "Adding necessary configs..."
for pref in ${CHANGED_PREFS[@]}; do
  set_pref $pref "true"
done;

if [[ $OSTYPE == "darwin"* ]]; then
  set_pref "widget.macos.native-context-menus" "false"
fi

echo "Finished successfully! Please start firefox to see the changes.";
