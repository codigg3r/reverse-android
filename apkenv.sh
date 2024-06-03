#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to echo messages in different colors
function echo_color() {
  local color="$1"
  shift
  echo -e "${color}$*${NC}"
}

# Function to clean the working directory
function clean_working_directory() {
  echo_color $YELLOW "\n--- Cleaning the working directory..."
  echo_color $YELLOW "\n--- Removing the 'aapt' 'apktool_2.9.3.jar' and 'uber-apk-signer-1.3.0.jar' files..."
  rm aapt apktool_2.9.3.jar uber-apk-signer-1.3.0.jar
  echo_color $YELLOW "\n--- Removing the 'wvc' directory..."
  rm -r wvc
}

function printApkMetaData() {
    # Extract package name and launcher activity from the manifest file
    PACKAGE=$(./aapt dump badging $APK_FILE | awk -F" " '/package:/ {print $2}' | sed s/name=//g | sed s/\'//g)
    LAUNCHER_ACTIVITY=$(./aapt dump badging $APK_FILE | awk -F" " '/launchable-activity:/ {print $2}' | sed s/name=//g | sed s/\'//g)
    echo_color $GREEN "\n--- Package Name: $PACKAGE"
    echo_color $GREEN "\n--- Launcher Activity: $LAUNCHER_ACTIVITY"
}

# Check if the first argument is -c
if [ "$1" == "-c" ]; then
  echo "The -c option was passed in to the script"
  # Add your code here that should be executed when the -c option is passed
  clean_working_directory
fi


# Get a list of all APK files in the current directory
APK_FILES=(*.apk)

# If no APK files were found, exit the script
if [ ${#APK_FILES[@]} -eq 0 ]; then
  echo_color $RED "No APK files found in the current directory."
  exit 1
fi

# Present a menu of APK files to the user and get their selection
echo_color $GREEN "Please select an APK file:"
select APK_FILE in "${APK_FILES[@]}"; do
  if [[ -n $APK_FILE ]]; then
    echo_color $GREEN "You selected $APK_FILE"
    break
  else
    echo_color $RED "Invalid selection. Please try again."
  fi
done

echo_color $GREEN "\n--- Creating working directory... of  $APK_FILE"

# Download the required tools if not already present appt and uber-apk-signer
echo_color $GREEN "\n--- Downloading the required tools..."
if [ ! -f uber-apk-signer-1.3.0.jar ]; then
  echo_color $GREEN "\n---Downloading uber-apk-signer..."
  curl -L https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar > uber-apk-signer-1.3.0.jar
fi
if [ ! -f apktool_2.9.3.jar ]; then
  echo_color $GREEN "\n---Downloading apktool..."
  curl -L  https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar > apktool_2.9.3.jar
fi

if [ ! -f aapt ]; then
  echo_color $GREEN "\n---Downloading aapt..."
  curl -L https://github.com/codigg3r/android-tools/releases/download/v0.2-9306103/aapt > aapt
  chmod +x aapt
fi

printApkMetaData

# Decompiles the APK file

echo_color $YELLOW "\n--- Decompiling the APK file..."
java -jar apktool_2.9.3.jar d "$APK_FILE"
echo_color $GREEN "\n--- APK decompiled successfully."
echo_color $YELLOW "\n--- Moving the required files to the working directory..."
WS_DIR=$(basename $APK_FILE .apk)

cp uber-apk-signer-1.3.0.jar $WS_DIR
cp apktool_2.9.3.jar $WS_DIR
cp aapt $WS_DIR
cp b2uildapk.sh $WS_DIR
chmod +x $WS_DIR/b2uildapk.sh 
echo $APK_FILE > $WS_DIR/apkname.txt
