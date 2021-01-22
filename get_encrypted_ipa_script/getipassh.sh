#!/bin/bash

# Constants
ipa_dir="/var/root/IPA"
apps_dir="/var/containers/Bundle/Application"
placeholder_name="my_application.ipa"

# Variables
app_path=""
app_name=""

# Input variables
search_app=""

echo "Running script on the device: Started"
echo "Current directory: $(pwd)"

# Clean up previous script artifacts
rm -rf $ipa_dir

# Check zip is installed
echo "Your device should have zip installed"
has_zip=$(dpkg -l | grep -w zip)
if [ "$has_zip" = "" ]
then
	echo "Error: zip is not installed. Use apt-get to install it on the device. Update and upgrade if needed."
	exit 0
else
	echo "Checked: zip package was found"
fi

# Process the command line arguments
while getopts ":n:" opt; do
  case "$opt" in
  \?)
    echo "Internal error 1. Invalid input."
    exit 0
    ;;
  :)
    echo "Internal error 2. Invalid input."
    exit 0
    ;;
  n)  
    echo "File search input: $OPTARG"
    search_app=$OPTARG
    ;;
  esac
done

# Navigating to Application directory and finding the .app file
cd $apps_dir
app_path=$(find "$(pwd)" -maxdepth 2 | grep -i $search_app)
app_name=$(ls * | grep -i $search_app)

# Case for 0 results
if [ "$app_path" = "" ]
then
	echo "No apps with search phrase $search_app where found"
	echo "Look at the list below to see the existing apps:"
	echo $(ls * | grep -i .app)
	exit 0
fi

# Case for 2+ relults
search_count=$(find "$(pwd)" -maxdepth 2 | grep -i $search_app | wc -l)
echo "Search count = $search_count"
if [ "$search_count" != "1" ]
then 
	echo "Several apps with search phrase $search_app where found"
	echo "Look at the list below to see the existing apps and make request more specific or delete unneeded apps:"
	echo $(ls * | grep -i .app)
	exit 0
fi

# Success
echo "Application .app filename: $app_name"
echo "Path to the .app file: $app_path"

# Pack the .ipa file
mkdir $ipa_dir
cd $ipa_dir
mkdir Payload
cp -r $app_path Payload
zip -r $placeholder_name Payload
rm -rf Payload

echo "Running script on the device: Complete"
exit 1