#!/bin/bash

iam="${1:-$(logname)}"
userProfile=$(ls -d /home/$iam/snap/firefox/common/.mozilla/firefox/*.default 2>/dev/null | head -n 1)
apparmorPath="/var/lib/snapd/apparmor/profiles/snap.firefox.firefox"
policiesProfile="/etc/firefox/policies/policies.json"

# The final "production" configuration set.
firefoxSnapControl() {
	plugs=(
		alsa
		audio-record
		avahi-observe
		camera
		cups-control
		dbus-daemon
		#gsettings
		system-packages-doc
		login-session-observe
		hardware-observe
		network-bind
		network-observe
		removable-media
		joystick
		screen-inhibit-control
		hardware-monitor
		upower-observe
	)

	for slot in "${plugs[@]}"; do
		snap disconnect firefox:$slot :$slot
	done

	snap disconnect firefox:alsa :alsa
	snap disconnect firefox:avahi-observe :avahi-observe
	snap disconnect firefox:camera :camera
	snap disconnect firefox:cups-control :cups-control
	#snap disconnect firefox:dbus-daemon :dbus-daemon
	snap disconnect firefox:system-packages-doc :system-packages-doc
	snap disconnect firefox:hardware-observe :hardware-observe
	snap disconnect firefox:network-bind :network-bind
	snap disconnect firefox:network-observe :network-observe
	snap disconnect firefox:etc-firefox :removable-media
	snap disconnect firefox:host-hunspell :mount-control
	snap connect firefox:firefox:dot-mozilla-firefox :personal-files
	snap connect firefox:firefox:etc-firefox :system-files
	snap connect firefox:firefox:home :home
	
	gsettings set org.mozilla.firefox.desktop allow-background false
}

# Disables risky connections before initializing Firefox.
# Locks the browser down while addons are loading to prevent data leaks.
firefoxInitialization() {
	echo "Initializing Firefox"
	# We want to kill access to home, for the most part.
	# system-files is needed to load policies.json.
	snap connect firefox:etc-firefox :system-files
	snap disconnect firefox:home :home
	snap disconnect firefox:opengl :opengl
	snap disconnect firefox:dot-mozilla-firefox :personal-files
	sleep 5

	echo "Please wait while we install addons."
	runuser -l $iam -c "DISPLAY=${DISPLAY} /snap/bin/firefox" > /dev/null 2>&1 &
	sleep 10

	echo "Initializing done, killing process"
	pkill firefox
	sleep 2

	snap connect firefox:home :home
	snap connect firefox:opengl :opengl
	snap connect firefox:dot-mozilla-firefox :personal-files
}

pkill firefox
chattr -i "$apparmorPath"
chattr -i "$userProfile/user.js"
chmod +wr "$apparmorPath"
chmod +wr "$userProfile/user.js"

gsettings set org.mozilla.firefox.desktop allow-background false

snap remove --purge firefox
sleep 5
rm -rf /var/lib/snapd/snaps/firefox_*.snap
snap refresh --list
snap install firefox
sleep 1
(firefoxSnapControl)
(firefoxInitialization)

echo "Updating preferences."
profilePath=$(find /home/$iam/snap/firefox/common/.mozilla/firefox -type d -name *.default 2>/dev/null)
if [[ -z "$profilePath" ]]; then
    echo "*.default profile not found."
    exit 1
fi
