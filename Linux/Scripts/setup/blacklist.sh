#!/bin/bash

# There's code here to run this for multiple users, which you don't need to worry about.

# We don't want to retype the startup file every time, so we'll define a variable for it.
iam="${1:-$(logname)}"
admin=$(logname)
path="$(realpath ./)"
blacklistPath="/etc/modprobe.d/blacklist.conf"
startupService="/etc/init.d/${iam}sec.sh"

# We'll define our services in an array to make it easier to add new ones later.
servicesBlacklist=(
	apport
	apport-core-dump-handler
	avahi-browse
	avahi-daemon.socket
	avahi-daemon
	avahi-resolve
	bolt
	bluetooth
	bluetoothctl
	bluetooth-sendto
	bluetoothd
	cc-remote-login-helper
	color
	colord-sane
	colord-session
	cups.path
	cups.socket
	cups				# cups is printer software
	cups-browsed			
	cupsaccept			# The printer port (631) is a common attack vector.
	cupsd
	cupsctl
	cups-browse
	cloud-config
	cloud-final
	cloud-init-hotplugd.socket
	cloud-init-hotplugd
	cloud-init-local
	configure-printer
	geoclue
	gsd-print-notification
	gnome-remote-desktop
	gnome-remote-desktop-daemon
	gvfsd-ftp			# The Gnome desktop's network File Transfer Protocol
	gvdsd-metadata			# We don't want to store metadata.
	gvfsd-sftp
	gvfsd-smb			# We don't like local network stuff.
	gvfsd-smb-browse
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
	pipewire
	Remmina
	rsync
	rsync-ssl
	sane-find-scanner
	sane
	spice-vdagent
	speech-dispatcher		# Speech synth
	samba
	saned
	spice-vdagent
	spice-vdagentd
	telnet				# A commonly abused protocol
	tracker-miner
	tracker-miner-2
	tracker-miner-3
	tracker-miner-4
	tracker-miner-fs
	tracker-miner-fs-2
	tracker-miner-fs-3
	tracker-miner-fs-4
	tracker-extract
	tracker-extract-2
	tracker-extract-3
	tracker-extract-4
	ubuntu-report
	wpa_supplicant
	xrdp				# Remote desktop binary
	xbrlapi				# Speech tool
	xdg-desktop-portal
	hp-*
	tracker*
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

# Merge our service & binaries arrays, discarding duplicates.
touchScript() {			# touchScript "/full/path
	if [ ! -f "$1" ];  then # Creates a script file if it doesn't exist.
		echo "#!/bin/sh" > $1
		chmod +x $1
	fi
}

# Adds a line to a file only if it doesn't already exist (verbatim)
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

serviceExists() {
    systemctl show "${1}" > /dev/null 2>&1
    return $?
}

# This runs the logic for blacklisting both services AND binaries, because why take chances.
muteService() {
	service="$1"
	
	# We need the full "cups.service" for some function, but we don't want to ruin "cups.socket", so we filter for those first.
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

chattr +i "$startupService"

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
