#!/bin/bash

# There's code here to run this for multiple users, which you don't need to worry about.

# This is literally a) the first parameter passed to the function and/or b) the name of the account running the script.
# You can user 'echo $(logname)' to print this to console if you'd like to verify. We use it to handle installations with multiple users.
iam="${1:-$(logname)}"
admin=$(logname)

# We don't want to retype the startup file every time, so we'll define a variable for it.
path="$(realpath ./)"
blacklistPath="/etc/modprobe.d/blacklist.conf"
startupService="/etc/init.d/${iam}sec.sh"

# We'll define our services in an array to make it easier to add new ones later.
servicesBlacklist=(
	apport				# Reporting software. Some applications might use this for logging.
	apport-core-dump-handler
	avahi-browse		# File share
	avahi-daemon.socket
	avahi-daemon
	avahi-resolve
	bolt				# Thunderbolt port (external GPU's and other high-transit serial port hardware)
	bluetooth			# We disable Bluetooth by default
	bluetoothctl
	bluetooth-sendto
	bluetoothd
	cc-remote-login-helper
	color				# Color profile manager.
	colord-sane
	colord-session
	cups.path
	cups.socket
	cups				# cups is printer software, but it's also a Man-on-the-Side target (port 631) 
	cups-browsed		# Browser for printers
	cupsaccept
	cupsctl
	cups-browse
	cloud-config		# These are startup profiles for apps. Personally, I prefer to use shell-scripts.
	cloud-final
	cloud-init-hotplugd.socket
	cloud-init-hotplugd
	cloud-init-local	# Startup profiles (first launch configuration)
	configure-printer
	geoclue				# Physical location
	gsd-print-notification
	gnome-remote-desktop			# RDP bad!
	gnome-remote-desktop-daemon
	gvfsd-ftp			# The Gnome desktop's network File Transfer Protocol
	gvdsd-metadata			# We don't want to store metadata.
	gvfsd-sftp
	gvfsd-smb			# We don't like local network stuff.
	gvfsd-smb-browse
	#gvfsd-trash		# This causes latency problems on some systems. Uncomment if you experience slowdowns.
	gsd-printer
	gsd-print-notifications
	gsd-sharing
	inetutils-telnet
	install-printerdriver
	iio-sensor-proxy
	ModemManager
	mtp-probe
	openvpn
	PrintNotifications
	pipewire					# This physically disables the speaker and microphone. Recommended to comment out for civillian systems.
	Remmina						# Remote Desktop Protocol. RDP's are very common exploit vehicles.
	rsync
	rsync-ssl
	sane-find-scanner			# Scanners are often used for Man-on-the-Side vulnerabilities.
	sane						# scanner
	spice-vdagent				# RDP/Desktop Sharing
	speech-dispatcher			# Speech synth
	samba						# RDP (no longer installed by default, but some apps will try to reinstall it).
	telnet						# A commonly abused protocol.
	ubuntu-report				# Telemetry
	#wpa_supplicant				# This disables the wifi broadcasting. If you don't need wifi, comment this out increases security.
	xrdp						# Remote desktop binary
	xbrlapi						# Speech tool
	xdg-desktop-portal			# Desktop environment, but often slows down high-end PC's, and has an RDP protocol embedded inside too.
	xdg-desktop-portal-gnome	# Same thing
	hp-*
	#sshd				# Optional stuff starts here.		
)

# Binaries don't actually live in one centralized location. Here's a short list of where we can search for them
bin_locations=(
	"/usr/bin/"
	"/usr/sbin/"
	"/usr/libexec/"
	"/usr/lib/udev/"
	"/etc/init/"
	"/etc/init.d/"
	"/etc/rc0.d/"
	"/etc/rc1.d/"
	"/etc/rc2.d/"
	"/etc/rc3.d/"
	"/etc/rc4.d/"
	"/etc/rc5.d/"
	"/etc/rc6.d/"
)

# If the file doesn't exist, make it and add the shebang at the top.
touchScript() {			# touchScript "/full/path
	if [ ! -f "$1" ];  then # Creates a script file if it doesn't exist.
		echo "#!/bin/sh" > $1
		chmod +x $1
	fi
}

# Description: Adds a line to a file only if it doesn't already exist (verbatim)
# Usage: uniqueLine "line" "file"
uniqueLine() {
	line=$1 && file=$2	# uniqueLine "line" "file"
	grep -qsxF -- "$line" "$file" || echo "$line" >> "$file"
}

# Executes a command, and then adds it to our startup script if it succeeded.
lineAndExecute() {
	command="$1"
	# We can switch back to using eval if the subshell stuff doesn't work out.
	bash -c "$command > /dev/null 2>&1" > /dev/null 2>&1

	# Check if the command was successful (exit status 0)
	if [ $? -eq 0 ]; then
        	touchScript "$startupService"
        	uniqueLine "$command" "$startupService"
 	fi
}

# Literally just checks if the service has a bin file or not, to cut down on the size of our startup service.
serviceExists() {
    systemctl show "${1}" > /dev/null 2>&1
    return $?
}

# This runs the logic for blacklisting both services AND binaries, because why take chances.
muteService() {
	service="$1"
	
	# Services have a ".service", ".socket", ".path" appended to the end of their physical file.
	if [[ ! "${service}" =~ \..+$ ]]; then
    		fullService="${service}.service"
    	else
    		fullService=$service
	fi
	
	# Checks to cut down on the number of lines in our startup file. We can't use execution status, since sysctl always completes.
	if find /etc/systemd/system /lib/systemd/system /usr/lib/systemd/system ~/.config/systemd/user/ -name "$fullService" -print -quit > /dev/null 2>&1; then
		lineAndExecute "systemctl mask --now $service"
	fi

	# Some things have a daemon but no service, and those still "complete". There's not much helping it.
	if find /etc/systemd/system /lib/systemd/system /usr/lib/systemd/system ~/.config/systemd/user/ -name "${fullService}d" -print -quit > /dev/null 2>&1; then
		lineAndExecute "systemctl mask --now ${service}d"
	fi

	lineAndExecute "apt-mark hold $service"
	lineAndExecute "apt-mark hold ${service}d"
	lineAndExecute "runuser -l \$(logname) -c \"XDG_RUNTIME_DIR=/run/user/\$(id -u \$(logname)) systemctl mask --now --user ${service}\""
	lineAndExecute "runuser -l \$(logname) -c \"XDG_RUNTIME_DIR=/run/user/\$(id -u \$(logname)) systemctl mask --now --user ${service}d\""
	
	if ! grep -qFx "blacklist $service" "$blacklistPath"; then
    		lineAndExecute "echo \"blacklist $service\" | sudo tee -a $blacklistPath > /dev/null"
	fi

	for loc in "${bin_locations[@]}"; do
		# Combine the location and service into the full file path
    		file_path="${loc}${service}"
    
    		if [ -e "$file_path" ]; then  # Check if the file exists
        		lineAndExecute "ln -fs /dev/null \"$file_path\""
        		lineAndExecute "chattr +i \"$file_path\""
    		fi
	done
}

# If there's an existing service file, it's probably immutable. Let's fix that.
if [ -e "$startupService" ]; then 
	chattr -i "$startupService"
fi

for service in "${servicesBlacklist[@]}"; do
	muteService "$service"
done

uniqueLine "export DO_NOT_TRACK=1" "/home/$iam/.bashrc" # Universal 'Do Not Track' environment variable. Not all developers check, respect, or care about this.
uniqueLine "export GIO_NO_TRACKER=1" "/home/$iam/.profile" # An alternative to disabling TrackerMiner indexing services that should aid window times.
uniqueLine "ADW_DEBUG_COLOR_SCHEME=prefer-dark" "/etc/environment" # standalone terminal command: echo "ADW_DEBUG_COLOR_SCHEME=prefer-dark" >> /etc/environment
# If you use dark mode and it's not working for files and window explorers (usually due to Nvidia drivers), uncomment or run the above line to fix that.

# Ubuntu's Indexing service (Tracker-Miner) can cause high and low-end CPU's to hang.
# This lowers its execution priority in the background. The patch is not required to function, and does not meaningfully increase security.
sed -si '/Exec=\/usr\/libexec\/tracker-miner-fs-3/s/^Exec=/&\/usr\/bin\/nice -n 13 /' \
	/etc/xdg/autostart/tracker-miner-fs-3.desktop \
	/usr/lib/systemd/user/tracker-miner-fs-3.service

# Patch for the xdg-desktop-portal mute not always triggering on restart.
# Pipewire *always* self-disables, so this is not the code itself that's the problem.
uniqueLine "systemctl --user mask --now xdg-desktop-portal" "$startupService"
uniqueLine "systemctl --user mask --now xdg-desktop-portal-gnome" "$startupService"

chattr +i "$startupService"

# Developers do not always respect The 'Do Not Track" environment variable, but we add it anyways.
# This script does not set up multple users at once, but if it did - here is how you'd do it.
if [ "$iam" != "$admin" ]; then
	uniqueLine "export DO_NOT_TRACK=1" "/home/$iam/.bashrc"
fi
uniqueLine "export DO_NOT_TRACK=1" "/home/$admin/.bashrc"

# Add a new systemctl service for our security script, so that our filters re-run at startup.
cat <<EOF_FF > "/etc/systemd/system/${iam}sec.service"
[Unit]
Description=Security Controller
After=graphical.target

[Service]
ExecStart=/etc/init.d/${iam}sec.sh

[Install]
WantedBy=multi-user.target
EOF_FF

# Enable our service.
systemctl enable --now "${iam}sec"
