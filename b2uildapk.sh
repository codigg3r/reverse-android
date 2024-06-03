#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

APK_NAME_WITH_SUFFIX=$(cat apkname.txt)
APK_NAME=$(basename $APK_NAME_WITH_SUFFIX .apk)

APK_FILE=dist/$APK_NAME.apk
SIGNED_APK_FILE=dist/$APK_NAME-aligned-debugSigned.apk

# Function to echo messages in different colors
function echo_color() {
  local color="$1"
  shift
  echo -e "${color}$*${NC}"
}

echo_color $YELLOW "\n--- Removing existing 'dist' directory..."
# Remove existing "dist" directory
rm -rf dist

echo_color $YELLOW "\n--- Rebuilding the project using apktool..."
# Rebuild the project using apktool
java -jar apktool_2.9.3.jar b -f -d .

echo_color $YELLOW "\n--- Signing the APK using uber-apk-signer..."
# Sign the APK using uber-apk-signer
java -jar uber-apk-signer-1.3.0.jar --apks $APK_FILE

echo_color $YELLOW "\n--- Uninstalling the app from the connected device/emulator..."
# Uninstall the app from the connected device/emulator
#adb shell pm uninstall --user 0 com.dcsapp.iptv
#adb shell pm uninstall com.dcsapp.iptv

echo_color $YELLOW "\n--- Installing the newly signed APK..."
# Install the newly signed APK
adb install $SIGNED_APK_FILE

echo_color $GREEN "\n--- Running the application..."

# Extract package name and launcher activity from the manifest file
PACKAGE=$(./aapt dump badging $SIGNED_APK_FILE | awk -F" " '/package:/ {print $2}' | sed s/name=//g | sed s/\'//g)
LAUNCHER_ACTIVITY=$(./aapt dump badging $SIGNED_APK_FILE | awk -F" " '/launchable-activity:/ {print $2}' | sed s/name=//g | sed s/\'//g)

# Run the application
adb shell am start -n $PACKAGE/$LAUNCHER_ACTIVITY

echo_color $GREEN "\nScript execution completed."
