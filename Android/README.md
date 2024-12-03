# Android Security Checklist

Google spies on you, and everyone knows this. The only way to be 100% immune to this, is to completely de-Google (After you've installed all your applications, disable Google Services), however this severely breaks several applications.

Additionally, Android has a few vulnerabilities that malicious applications can exploit. Ideally, these steps would be performed on a fresh install of an android phone, prior to having a sim card inserted into it for the first time.

## Vendors

Apple is more respectful of both your security and privacy, however this comes with an increased cost.

Be aware that certain brands of cheap overseas phones often have backdoors around even these fixes, and can be presumed insecure indefinitely - be careful who you trust, be skeptical of what people say online.

## 0: Samsung Only: Auto-Blocker

If you are ever browsing the Google Play Store, Auto-Blocker needs to be on. If you need to turn Auto-Blocker off for some reason (to use ADB, for example), temporarily disable Google Play Store and Google Play Services first, before doing so. Re-enable Auto-Blocker immediately after you're finished, and before re-enabling the Google Services Framework apps again.


## 1: Disable Microphone & Camera

Android 14 allows you to hardware disable your Camera and Microphone. When you hang up a call, you will need to re-disable your microphone. You can add shortcut icons for this to the pull-down menu for ease-of-access.

## 2: Disable sensors and system-tracing

Sensors can be used to gather data too and, worse, Google often doesn't provide a way to revoke this permission on applications. Fortunately, developer mode does.

2a). Find your build number in settings. This is usually nested somewhere in Settings > About Phone, however a quick search can give you the full path for your manufacturer.

2b). Tap "Build number" seven times.

2c). In "Quick settings developer tiles", enable "Sensors Off". You can now toggle off sensors just like you could the Camera and Microphone. Some cameras won't work unless you temporarily enable sensors for unnecessary reasons.

System-tracing is a debug tool that can enable certain apps to spy on your activities.

2d). Still in developer settings, scroll down to "System Tracing", and revoke all permissions.

Other fixes:
Wi-Fi non-persisent MAC randomization: Turning this on makes it harder to fingerprint your phone when connected to wi-fi.
Don't keep activities: This will decrease your QOL by preventing any apps from running in the background, but it's more secure.

## 3: ADB (Android Debugging Bridge)

This one is more advanced and, if your computer is compromised there is a risk of damage or interference with your phone's hardware. If you feel you need to take this step, but you're uncertain of your capabilities, reach out to someone with the proper knowledge and experience.

Android phones have shell terminal enabled by default, which can be leveraged to run arbitrary code. In order to disable it, we need Android Debugging Bridge.

3a). Download Android Debugging Bridge if your operating system doesn't come with it (adb).

3b). Ensure that you have all the necessary next steps saved locally on your computer.

3c). Close all browsers that are open in your computer, and disconnect your computer from the internet.

3d). On your mobile device, turn on Airplane Mode.

3e). In developer options, enable USB Debugging

3f). Connect your mobile device to your computer.

Note: This folder (will soon) contain bash scripts to run the required steps automatically in powershell or linux.
You can simply execute that file in terminal, if you wish to skip the following steps.

3g). Open adb in terminal, and type "adb devices". You may need to allow the connection on your phone first. If your device shows up in the terminal output, you are ready to proceed:

3h). In terminal, type the following lines:
adb shell pm disable com.android.shell
adb shell pm disable-user --user 0 com.android.shell
adb shell pm disable-user --user 10 com.android.shell

If any of the user commands have failed, you can ignore that user for the remaining steps. --user 10 will generally fail if you don't have an Android Enterprise profile, for example.

3i). Continue the above with the following services:
com.google.android.overlay.gmsconfig.asi
com.facebook.appmanager
com.facebook.services
com.facebook.system
com.google.android.adservices.api
com.google.android.partnersetup
com.google.mainline.adservices
com.google.mainline.telemetry

This is simply the bare minimum required to mute the most egregious services and protect yourself.
See the terminal scripts for a full updated version.

The following are Samsung specific:
com.samsung.klmsagent

KLMS has an always-on debug tool that system-traces by default. It may break some pay-by-phone applications.

## 4: Carrier Telemetry

You'll want to opt-out of any and all carrier telemetry. You may need to call your carrier.

T-mobile: This carrier has an app for opting out of telemetry called "Magenta", you can find it in the Google Play store. This is unnecessary for Apple phones on the T-mobile network, as they don't collect telemetry on those devices.

## 5: VPN (Virtual Private/Proxy Network)

Proton has a free VPN that you can use. Ensure that you go into your VPN settings and toggle "Always On", and "Block traffic not using VPN" after setup.

## 6: Private DNS

In the VPN settings section, there's also a section for "Private DNS". This uses DNS-Over-TLS to encrypt your domain-name lookups. Ternary Fortress has a zero-log Cloudflare account set up that you can choose to use.

Simply enter: v9gab9k06l.cloudflare-gateway.com

In the private DNS section.

By default, Cloudflare collects telemetry on people using their services, even people who have registered an account with them. If you want your own pihole-like service, then after setting up your own account be sure to email "sar@cloudflare.com" asking to opt-out of the sale and distribution of your telemetry data.

Be aware that Cloudflare enables the person hosting and managing the list to unilaterally and privately enable logging. Be sure that you trust us enough to manage the DNS blacklist and keep the logging disabled, or create your own account and manage your own lists.

-------------------------------

This will be updated as more information becomes available.
