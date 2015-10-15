#!/bin/bash

# A time saving script which enables you to use a prebuilt *.ipa archive and repackage it with new files to test quicker on device.
# Use this script at your own risk - but it works on my machine!

# Check dependancies
command -v ios-deploy >/dev/null 2>&1 || { echo >&2 "Script requires 'ios-deploy'. Please install Node.js and run: \nnpm install -g ios-deploy"; exit 1; }
command -v ios-deploy >/dev/null 2>&1 || { echo >&2 "Script requires 'ideviceinstaller'. Please install Homebrew and run: \nbrew install ideviceinstaller"; exit 1; }

# Mandatory user params
FILE=

# Optional user params
REMOVE_DIR=
REPLACE_DIR=
IS_IPA=false
IS_DEBUG=true
PROVISION_PROFILE=

# iOS user params
CERT=

# iOS package names
APP=
APPNAME=
PAYLOAD_DIR="Payload"
CODESIGN_DIR="_CodeSignature"
ENTITLEMENTS="archived-expanded-entitlements.xcent"
EMBEDDED_PROVISION="embedded.mobileprovision"

# OS options
IS_PAYLOAD_REUSED=false
WORK_DIR=

# Script presets
SUFFIX="hotwired"

function usage {
	printf "Usage: %s [-f <ipa file>] [-d <delete app dir>] [-p <copy dir>]\n" $0
	printf "	-f <path>		path to *.ipa archive\n"
	printf "	-d <dir>		dir to delete inside app\n"
	printf "	-p <dir>		dir to copy in place\n"
	printf "	-c <string>		valid certificate code sign identity\n"
	printf "	-m <path>		path to *.mobileprovision profile\n"
	printf "	-i			install as *.ipa (faster install time for an app with many files)\n"
	printf "	-q			no debugging\n"
	printf "	-z			reuse unzipped $PAYLOAD_DIR dir\n"
	printf "Example: sh hotwire-ipa.sh -f ~/Desktop/App.ipa -c \"iPhone Developer: Your Name (XXXXXXXXXX)\" -d \"www\" -p ~/Sites/www\n"
	exit 1
}

if (($# == 0)); then
  usage
fi

START_TIME=$(date +"%s")

while getopts "f:d:p:c:m:iqz" opt; do
	case "$opt" in
		f)	FILE=$OPTARG;;
    d)	REMOVE_DIR=$OPTARG;;
    p)	REPLACE_DIR=$OPTARG;;
		c)	CERT=$OPTARG;;
		m)	PROVISION_PROFILE=$OPTARG;;
    i)	IS_IPA=true;;
    q)	IS_DEBUG=false;;
    z)	IS_PAYLOAD_REUSED=true;;
    ?)
			usage
			exit 1;;
		:)
			printf "Option -$OPTARG requires an argument."
			exit 1;;
	esac
done

# Mandatory args
if [ -z "$FILE" ]; then
	usage
	exit 1
fi

if [ ! -f $FILE ]; then
	echo "Error: file not found at '$FILE'"
	exit 1
fi

if [[ $FILE != *.ipa ]]; then
	echo "Error: file must be *.ipa"
	exit 1
fi

# Optional args
if [ -z "$CERT" ]; then
	certs=`security find-identity -v -p codesigning`
	regex="iPhone Developer: ([A-Z a-z])+ \([A-Z0-9]+\)"
	if [[ $certs =~ $regex ]]; then
		CERT=${BASH_REMATCH}
		echo "Found iPhone Developer Certificate \"$CERT\""
	else
		echo "Error: couldn't find valid iPhone Developer Certificate"
		exit 1
	fi
fi

WORK_DIR=`dirname $FILE`

cd $WORK_DIR

function extract {
	echo "Unzipping $FILE to $WORK_DIR"
	unzip -qo $FILE -d $WORK_DIR
}

# Clear working directory unless Payload reused
if [ $IS_PAYLOAD_REUSED == false ]; then
	if [ -d "$PAYLOAD_DIR" ]; then
		echo "Clearing '$PAYLOAD_DIR' working directory..."
		rm -rf "$PAYLOAD_DIR/"
	fi
fi

# Extract *.ipa to Payload directory
if [ ! -d "$PAYLOAD_DIR" ]; then
	echo "Unzipping $FILE to $WORK_DIR"
	unzip -qo $FILE -d $WORK_DIR
fi

cd $WORK_DIR/$PAYLOAD_DIR

# Get app name inside Payload
APP=`ls | grep \.app`
APPNAME=${APP%.*}
echo "Found app '$APPNAME'"

cd $APP

# Get app id
APP_ID=`/usr/libexec/plistbuddy -c "Print :CFBundleIdentifier" Info.plist`
echo "App ID: $APP_ID"

# Remove codesign
echo "Deleting existing code signature"
rm -rf "$CODESIGN_DIR/"

# Option to replace 'embedded.mobileprovision'
if [ ! -z "$PROVISION_PROFILE" ]; then
	if [[ -f $PROVISION_PROFILE ]]; then
		echo "Replacing '$EMBEDDED_PROVISION' with provising profile: $PROVISION_PROFILE"
		rm "$EMBEDDED_PROVISION"
		cp -v "$PROVISION_PROFILE" "$EMBEDDED_PROVISION"
	else
		echo "Error: *.mobileprovision profile not found at '$PROVISION_PROFILE'"
	fi
else
	echo "Using embedded mobile provision profile";
fi

# Delete bundle
if [ ! -z "$REMOVE_DIR" ]; then
	if [ -d "$REMOVE_DIR" ]; then
	  	echo "Deleting '$REMOVE_DIR' dir inside $PAYLOAD_DIR/$APP"
		rm -rf "$REMOVE_DIR/"
	else
		echo "Error: can't find '$REMOVE_DIR' directory to remove inside $PAYLOAD_DIR/$APP"
	fi
fi

# Replace bundle
if [ ! -z "$REPLACE_DIR" ]; then
	if [ -d "$REPLACE_DIR" ]; then
	  	echo "Copying '$REPLACE_DIR' dir into $PAYLOAD_DIR/$APP/$REMOVE_DIR"
		cp -R $REPLACE_DIR $WORK_DIR/$PAYLOAD_DIR/$APP/$REMOVE_DIR
	else
		echo "Error: can't find '$REPLACE_DIR' directory to copy"
	fi
fi

# Update entitlements
if [ $IS_DEBUG == true ]; then
	GET_TASK_ALLOW=`/usr/libexec/plistbuddy -c "Print :get-task-allow" $ENTITLEMENTS`
	if [ "$GET_TASK_ALLOW" == 'false' ] || [ "$GET_TASK_ALLOW" == 'true' ]; then
		echo "Updating 'get-task-allow' to entitlements to support debugging"
		/usr/libexec/plistbuddy -c "Set :get-task-allow true" $ENTITLEMENTS
	else
		echo "Adding 'get-task-allow' entry to entitlements to support debugging"
		/usr/libexec/plistbuddy -c "Add :get-task-allow bool true" $ENTITLEMENTS
	fi
fi

# Re-codesign
echo "Re-codesign using certificate identity: $CERT"
codesign -s "$CERT" -f --entitlements $ENTITLEMENTS $WORK_DIR/$PAYLOAD_DIR/$APP

# Verify codesign
codesign -vv $WORK_DIR/$PAYLOAD_DIR/$APP
echo "Verify codesign"

# Measure time taken
END_TIME=$(date +"%s")
echo "Time taken: $(($END_TIME - $START_TIME)) seconds"

# Repackage and install app
if [ $IS_IPA == true ]; then
	echo "Repackage as '$APPNAME-$SUFFIX.ipa'"
	/usr/bin/xcrun -sdk iphoneos PackageApplication $WORK_DIR/$PAYLOAD_DIR/$APP -o $WORK_DIR/$APPNAME-$SUFFIX.ipa
	if [ $IS_DEBUG == true ]; then
		echo "Debug mode (Note: entitlements and mobileprovision should allow debugging)"
		ideviceinstaller --debug --install $WORK_DIR/$APPNAME-$SUFFIX.ipa
	else
		ideviceinstaller --install $WORK_DIR/$APPNAME-$SUFFIX.ipa
	fi
	# Run app (requires debug mode)
	if [ $IS_DEBUG == true ]; then
		if [ -n "$(command -v idevice-app-runner 2>/dev/null)" ]; then
			sleep 1
			IDEVICE_APP=`ideviceinstaller -l -o xml | grep -A1 '<key>Path</key>' | grep '<string>' | tr '<>' '  ' | awk '{ print $2 }' | grep $APPNAME`
			echo "Running app on device: $IDEVICE_APP\n"
			idevice-app-runner --run $IDEVICE_APP
			exit
		else
			echo "To launch app automatically on device please install 'idevice-app-runner' and add it to your PATH."
		fi
	else
		echo "Automatically launching an *.ipa will require debug mode enabled!"
	fi
else
	echo "Deploying as *.app (type 'exit' to finish lldb session)"
	if [ $IS_DEBUG == true ]; then
		echo "Debug mode (Note: entitlements and mobileprovision should allow debugging)"
		ios-deploy --debug --bundle $WORK_DIR/$PAYLOAD_DIR/$APP
		exit
	else
		ios-deploy --bundle $WORK_DIR/$PAYLOAD_DIR/$APP
		exit
	fi
fi

echo "Deploy Complete"
