#!/bin/bash

# VARIABLES, CHANGE AS NEEDED
GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
PROFILE_ROOTDIR=~/.mozilla/firefox/$(grep Default= ~/.mozilla/firefox/installs.ini | tail -1 | cut -c 9-);

echo "Detecting if firefox is installed on your system..."
if [ ! -f /usr/bin/firefox ] || { [ ! -f /usr/lib/firefox/firefox ]; }; then
  echo "ERROR: firefox not found..."

  ans="y"
  read -e -i "$ans" -p "Do you want to continue anyway? (y/n): " in
  ans="${in:-$ans}";

  if [[ ! ${ans,,} =~ ^(yes|y)$ ]]; then
    exit 0;
  fi
fi

git --version 2>&1 > /dev/null;
if [ ! $? -eq 0 ]; then
  echo "git is not installed... Please install it."
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

echo "cloning repository";
if [ ! -d ~/github/firefox-dracula ]; then
  if ! git clone $GITHUB_REPO ~/github/firefox-dracula; then
    echo "Error while cloning repository into ~/github/firefox-dracula..."
    exit 0;
  fi
fi

echo "Copying theme folder..."
cp -r ~/github/firefox-dracula/chrome "$PROFILE_ROOTDIR"

# firefox will automatically sort out any duplicate issues, whatever is at the end of the file takes priority, so this works.
echo "Adding necessary configs..."
echo "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);" >> $PROFILE_ROOTDIR/prefs.js;
echo "user_pref(\"svg.context-properties.content.enabled\", true);" >> $PROFILE_ROOTDIR/prefs.js;
echo "user_pref(\"layout.css.color-mix.enabled\", true);" >> $PROFILE_ROOTDIR/prefs.js;
if [[ $OSTYPE == "darwin"* ]]; then
  echo "user_pref(\"widget.macos.native-context-menus\", false);" >> $PROFILE_ROOTDIR/prefs.js;
fi

echo "Finished successfully! Please (re)start firefox to see the changes.";
