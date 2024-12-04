## The most important settings to disable are the following

Autoplay: This can automatically run malware on USB devices if it's left enabled.

Diagnostics: All telemetry should be disabled as standard practice.

File History: Anything that caches data on the system might result in having a false sense-of-security after deleting important files.

Apps: Browsers should have their file access locked down to the bare minimum. More details to come in the "browser.md".

Microphones: The system can turn this back on, and this should therefore be disabled at the service level if able (services.md), but you can check here too. 

Secure Shell (SSH): This should be disabled unless you're actively using it.

Remote Desktop: RDP should be hard-disabled as a general principle.

## Accounts:

You should have an admin account with a highly secure admin password, and a normal user account with a unique password.

If your user account gets compromised through normal use, this enables you to correct the issue without reinstlling the entire desktop.

This also forces an attacker to prompt you for admin credentials if they want to try and change system settings stealthily.
