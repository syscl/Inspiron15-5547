OS X on DELL Inspiron15-5547
============================


This project targets at giving the relatively complete functional OS X for DELL Inspiron15-5547. Before you start, there's a brief introduction of how to finish powering up OS X on your laptop:

1. Create a vanilla installation disk(removable disk).
2. Install Clover with UEFI only and UEFI64Drivers to the installation disk just created. 
3. Replace the origin Clover folder with the one under github.com/syscl/Inspiron15-5547

NOTE: Once you modify your settings in BIOS(especially Graphics Configuration in SA), you have to remove previous ACPI tables first, redump ACPI tables by press Fn+F4/F4 under Clover, and run deploy.sh again to patch your ACPI tables again.

4. Install OS X.
5. Once you finish installation of OS X, you can do the following steps to finish the post installation of OS X.

How to use SSDT-HDMI-HD4400.dsl under github.com/syscl/Inspiron15-5547/ACPI ?
----------------

Download the latest version installation package/directory by entering the following command in a terminal window:

```sh
git clone https://github.com/syscl/Inspiron15-5547
```
This will download the whole installation directory to your current directory(./) and the next step is to change the permissions of the file (add +x) so that it can be run.

```sh
cd Inspiron15-5547/tools
chmod +x *
```
Compile the SSDT-HDMI-HD4400.dsl so that it can be loaded by Clover.

```sh
./iasl -vr -w1 -ve -p ~/Inspiron15-5547/ACPI/SSDT-HDMI-HD4400.aml ~/Inspiron15-5547/ACPI/SSDT-HDMI-HD4400.dsl
```

Place ~/Inspiron15-5547/ACPI/SSDT-HDMI-HD4400.aml to CLOVER/ACPI/patched. 

Use [ssdtPRGen.sh] (https://github.com/Piker-Alpha/ssdtPRGen.sh) to generate CpuPM SSDT for your Inspiron15-5547, and place the ssdt.aml to CLOVER/ACPI/patched/, and rename ssdt.aml to SSDT-pr.aml

Replace CLOVER with your new one, and reboot to see change.

Change Log
----------------
2017-8-13

- Updated SSDT-HDMI-HD4400.dsl: layout = ```3``` -> layout = ```27```
- Use native AppleHDA instead of VoodooHDA: Headphone and Speaker auto switch
- ACPI hot patch: FixHEPT, IPIC, TIMER, ...
- Updated for 10.12+ supported
- Optimized config.plist: reduce code size
- Use country code ```#a``` instead of ```US``` for 5Ghz Wi-Fi(universal solution cited from: XPS9350-issues)
- Updated Clover to r4152
- Updated RTL8100 to v2.0.0
- Added iTunes DRM support
- Added Hibernation support
- Added FileValut2 support

2016-5-21

- Updated SSDT-HDMI-HD4400.dsl:
- Added MCHC.
- Added IMEI.
- Added IRQ Fix.
- Added HPET.

