# Notes about rooting Xiaomi phone

## Devices

### Xiaomi Redme Note 9 with NFC (MerlinX)

- MIUI version: Global 12.0.10.0 Stable QJOEUXM
- Android version: 10 QP1A.190711.020
- Android security patch level: 2021-03-01

### MacBook Pro 2017

- MacOS Big Sur. version 11.4

## Rooting Scenario

### Step 0. Devices setup

On Andtoid phone enable developer mode, allow USD debugging and file transfer. Check if bootloader is locked or not.

On macOS install Android tools to be able to use ADB.

### Step 1. Unlock Bootloader

There is an official tool for Windows. The unofficial macOS tool is XiaoMiTool v2. You'll need to wait until bootloader is unlocked. I believe I had to wait for a week.

### Step 2. Install Custom Recovery

To install TWRP custom recovery that supports current device and Android version download the image https://twrp.me/xiaomi/xiaomimi10i.html

Connect the phone and enter the bootloader:
```
adb reboot bootloader
```

Flash the TWRP image:
```
fastboot flash recovery twrp.img
```

Optional step. Clear all the phone data. Warning! This will erase everything and you'll need to set up the phone from scratch:
```
fastboot format cache
fastboot format userdata
```

Reboot into recovery mode:
```
fastboot reboot recovery
```

If the previous step doesn't reboot into recovery. Then run
```
fastboot reboot
```

Right after the screen will turn off, press power and volume up buttons. When you see the Redme logo then release power button. You may need to wait secord or third time the logo appears. You can google another key combination to enter recovery mode. Pressing them is a lot about timing.

If TWRP stucks on launch screen and no buttons appear, you may need to repeat the whole thing. Flashing the image may not be nessassary for the second try. However, when restarting the phone, the custom revovery may be overriden by the default one and you'll need to flash it again.

The custom recovery was installed successfully if you see the TWRP menu buttons.

### Step 3. Install Root

Download latest Magisk version on you laptop. Rename it to `.zip` instead of `.apk`. Connect the phone and move the file:

```
adb push Magisk-v25.1.zip /sdcard
```

In TWRP install Magisk from .zip file.

Reboot your phone and let it load regularly. It may not start from the first try.

Find Magisk app icon and tap it. It will download the full magisk app. If download doesn't start, install the `.apk` used in the previous step. The app should open after that.

Download any root checker app from the Play Market to make sure everything works as expected. You can also test SafetyNet detection: the device should not pass SafetyNet validation right now.

## Toolset

### Installing Xposed

- Install Riru. Latest version didn't work, so I've used 25.4.4 https://github.com/RikkaApps/Riru/releases
- Dowload latest EdXposed (v0.5.2.2) and instal via Magisk https://github.com/ElderDrivers/EdXposed/releases
- Download EdXposed Manager (v4.6.2) and install https://github.com/ElderDrivers/EdXposedManager/releases
- Reboot
