#!/bin/bash

# Literally just updates Firefox, because it's a PitA otherwise.
# Open terminal in this directory, type "sudo bash ./firefox.sh", and go get coffee."

# Running this script is the ONLY way to update Firefox now!

iam="${1:-$(logname)}"

# Ordering matters a lot here.

# If apparmor is frozen, we are literally prevented from updating.
chattr -i "/var/lib/snapd/apparmor/profiles/snap.firefox.firefox"
#chattr -i "/etc/apparmor.d/local/snap.firefox.firefox"

bash ./firefox/firefox-policies.sh "$iam"

# ff-update requires ff-policies be complete.
bash ./firefox/firefox-update.sh "$iam"

# ff-prefs requires ff-update be complete.
bash ./firefox/firefox-prefs.sh "$iam"

# ff-apparmor prevents any of the above from working.
bash ./firefox/firefox-apparmor.sh "$iam"
