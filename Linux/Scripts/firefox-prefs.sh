#!/usr/bin/env bash
set -e

# Your profile name
iam="$(logname)"

# The prefs.js file lives in a hidden folder with a random name. This finds that folder for us.
userProfile=$(ls -d /home/$iam/snap/firefox/common/.mozilla/firefox/*.default 2>/dev/null | head -n 1)

cat <<EOF_FF > "${userProfile}/user.js"
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.lastUpdateTime.addon-background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.blocklist-background-update-timer", 1182010203);
user_pref("app.update.lastUpdateTime.microsummary-generator-update-timer", 1222586145);
user_pref("app.update.lastUpdateTime.search-engine-update-timer", 1182010203);
user_pref("security.sandbox.warn_unprivileged_namespaces", false);
user_pref("general.useragent.override", "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36");
EOF_FF
