#!/bin/bash

# Literally just updates Firefox, because it's a PitA otherwise.
# Open terminal in this directory, type "sudo bash ./firefox.sh", and go get coffee."

# Running this script is the ONLY way to update Firefox now!

iam="${1:-$(logname)}"
profilePath=$(find /home/$iam/snap/firefox/common/.mozilla/firefox -type d -name *.default 2>/dev/null)

# Ordering matters a lot here.

# If apparmor is frozen, we are literally prevented from updating.
chattr -i "/var/lib/snapd/apparmor/profiles/snap.firefox.firefox"
chattr -i "$profilePath/user.js"

bash ./firefox/firefox-policies.sh "$iam"

# ff-update requires ff-policies be complete.
bash ./firefox/firefox-update.sh "$iam"

# ff-prefs requires ff-update be complete.
bash ./firefox/firefox-prefs.sh "$iam"

echo "Please wait while we install addons."
if [ "$iam" != "$admin" ]; then
	runuser -l $iam -c "DISPLAY=${DISPLAY} /snap/bin/firefox" > /dev/null 2>&1 &
else
	firefox
fi
sleep 3
pkill -r firefox
sleep 0.5
if pgrep -x "firefox" > /dev/null; then
	pkill firefox
fi

# ff-apparmor prevents any of the above from working.
bash ./firefox/firefox-apparmor.sh "$iam"

pkill -r firefox
sleep 0.5
if pgrep -x "firefox" > /dev/null; then
	pkill firefox
fi

clear
echo "Firefox is installed, hardened, and initialized."
