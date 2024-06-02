# Installation Guide

## Step 1: Download Necessary Files
1. Download both `apkenv.sh` and `b2uildapk.sh`.
2. Place them into a folder.
3. Put the APK file that you want to reverse in the same folder.

## Step 2: Run Initialization Script
1. Execute the following command to initialize the workspace:
   ```bash
   ./apkenv.sh
   ```

## Usage

### Step 1: Configure Android Studio
1. Open Android Studio.
2. Add a Run configuration:
   - Select "Script" file type.
   - Provide the path to `b2uildapk.sh` inside your workspace.

### Step 2: Build and Deploy the App
1. When you run the configuration, it will build the app and attempt to push it to a device.

## Script Descriptions

### apkenv.sh
This script is responsible for initializing the workspace:
- Downloads and copies necessary tools into a new workspace.
- Requires `b2uildapk.sh` to function properly.

### b2uildapk.sh
This script is used by the Run configuration in Android Studio to build and push the APK to a device.
