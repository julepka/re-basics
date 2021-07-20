# RE-Basics

This is my personal repository used for taking notes about iOS reverse engineering tools usage. As I work on solutions aiming to detect malicious activity I need to have a basic understanding of what reverse engineering looks like from the inside. And my goal here is to gather notes and structure my knowledge.

This setup was used for iPhone 7 iOS 13.1.3, macOS Big Sur in July 2021

## Setting up an environment

### Jailbreak the device

I've used checkra1n 0.12.4 beta: https://checkra.in/ 

Alternatives: https://unc0ver.dev/ https://taurine.app/ https://canijailbreak.com/ 

### Set up SSH

Follow instructions in Cydia. Install OpenSSH from Cydia (any author will do). Connect to your device by its IP address like 
``` sh
$ ssh root@192.168.1.100
```
The initial password is `alpine` Change the password to a more secure one
```sh
$ passwd
```

### Install Frida on the device

Open Cydia and add Frida repository to sources `https://build.frida.re`. Find Frida package in it and install it. Alternatevly, you can do this through SSH.

### Set up your Mac

You need to have `npm` and `pip3` installed.

Install applesign 
```sh
$ npm install -g applesign
```
Install insert_dylib:
```sh
$ cd ~/Documents
$ git clone https://github.com/Tyilo/insert_dylib
$ cd insert_dylib
$ xcodebuild
$ cp build/Release/insert_dylib /usr/local/bin/insert_dylib
```
Install Frida tools 
```sh
$ pip3 install frida-tools
```
Install objection 
```sh
$ pip3 install objection
```
Install ios-deploy 
```sh
$ npm install -g ios-deploy
```

## Getting an .ipa file

There are 3 approaches I suggest:
1. Get a encrypted .ipa easily through SSH. It is useful if you need an unprotected data like .plist file.
1. Do it manually using Frida. I still need to learn how to do this 😅
1. Use ready-to-go scripts and tool (that is what I do). As of right now I recommend `bagbak` https://github.com/ChiChou/bagbak
```sh
$ bagbak MyApplicationName -z
```

### Troubleshooting bagbak

Required node version: 14.x (my: 14.17.0)

Required bagbak version: 2.0

Installed Frida version: 14.2.18

If there is a ploblem with missing Frida Gadget:
Check current Frida version. Go to its Github Releases: https://github.com/frida/frida/releases and download Frida Gadget for iOS for the Frida version you have. Then, copy it to the required place.
```
frida --version
mkdir -p ~/.cache/frida
cp frida-gadget.dylib ~/.cache/frida/gadget-ios.dylib
```

## Patching and signing

You need a valid provisioning profile. You can create a test app in Xcode and run it on the device. It will create a profile for you and objection should be able to find it. To find you signing ID use:
```sh
$ security find-identity -p codesigning -v
```
Get an .ipa from the device and use objection to insert Frida's .dylib. Use an ID from the result above:
```sh
$ objection patchipa -c 42ABCDEF99 -s MyApplicationName.ipa
```
Alternatevly you can specify provisioning file manually. To get it from DerivedData: 
/MyApplicationName-lwjh.../Build/Products/Debug-iphoneos/MyApplicationName.app/embedded.mobileprovision
```sh
$ objection patchipa --source MyApplicationName.ipa --codesign-signature 42ABCDEF99 --provision-file embedded.mobileprovision
```
Unzip the patched .ipa file to see a Payload folder. Install a patched .app on the device:
```sh
$ ios-deploy --bundle ./Payload/MyApplicationName.app -W -d
```

## Troubleshooting failed application verificarion

applesign 3.7.0 is not compatible with objection 1.9.6. You will get an error when installing with ios-deploy:
```
...
[ 57%] ExtractingPackage
[ 60%] InspectingPackage
[ 60%] TakingInstallLock
[ 65%] PreflightingApplication
[ 65%] InstallingEmbeddedProfile
[ 70%] VerifyingApplication
2020-12-08 14:45:30.398 ios-deploy[30091:873131] [ !! ] Error 0xe800003a: The application could not be verified. AMDeviceSecureInstallApplication(0, device, url, options, install_callback, 0)

```
Solution:
* Downgrade applesign
or
* Sign it one more time adding `-c`
```sh
$ applesign -m embedded.mobileprovision -i 42ABCDEF99 -c -o signed.ipa MyApplicationName-frida-codesigned.ipa
```
The problen went away with the next setup:

ios-deploy: 1.11.4

applesign: 3.8.0

objection: 1.11.0

## Using objection

Run the app on the device.

Use frida to see running processes 
```sh
$ frida-ps -Uia
```
Find your app and launch objection 
```sh
$ objection --gadget "com.hello.myapp" explore
```
Enjoy!

Also, use it with fancy UI with passionfruit https://github.com/chaitin/passionfruit
