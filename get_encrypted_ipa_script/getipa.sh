#!/bin/bash

# HOW TO
# ./getipa -i 192.168.1.147 -n MyAppName

# Constants
input_error="Invalid input. Please, specify the device IP address and application name like: ./getipa.sh -i 192.168.1.147 -n MyAppName"
# All scripts should be in the same directory
ssh_script_path="$(pwd)/getipassh.sh"
sftp_script_path="$(pwd)/copyapp.sh"
# Placeholder name used in other scripts
placeholder_name="my_application.ipa"

# Input Variables
device_ip=""
app_name=""

# Process the command line arguments
while getopts ":i:n:" opt; do
  case "$opt" in
  \?)
    echo $input_error
    exit 0
    ;;
  :)
    echo $input_error
    exit 0
    ;;
  i)  
    device_ip=$OPTARG
    ;;
  n)
	app_name=$OPTARG
	;;
  esac
done

# Validate IP address not empty
if [ "$device_ip" = "" ]
then
  echo $input_error
  exit 0
fi 

# Validate application name is not empty
if [ "$app_name" = "" ]
then
  echo $input_error
  exit 0
fi 

# Validate if the device is reachable
echo "Looking for device at $device_ip"
if ping -c 1 $device_ip > /dev/null
then
  echo "Device is reachable"
else
  echo "Device is not reachable"
  echo $input_error
  exit 0
fi

# Starting ssh script
echo "Current directory: $(pwd)"
echo "Launching script $ssh_script_path on the device over SSH."
ssh root@$device_ip "bash -s -- -n $app_name" < $ssh_script_path
if [ "$?" = "0" ]
then 
	exit 0
fi

#Copy .ipa file to the desktop
echo "Launching script $sftp_script_path on the device."
sftp root@$device_ip 'bash -s' < $sftp_script_path
mv $placeholder_name "$app_name.ipa"
echo "Done"

