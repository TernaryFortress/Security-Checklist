#!/bin/bash

# You can automatically disable all these services with a single command!
# In terminal, run `sudo bash /path/to/this/file.sh`. Drag the file into terminal if you don't want to type the full path.


# We don't want to retype the startup file every time, so we'll define a variable for it.
startup_file_name="startup_security.sh"

# We'll define our services in an array to make it easier to add new ones later.
services_blacklist=(
	xdg-desktop-portal
	pipewire
	apport
	avahi-daemon.socket
	avahi-daemon
	bolt
	colord
	bluetooth
	cups.path
	cups.socket
	cups
	cups-browsed
	geoclue
	gsd-print-notification
	gnome-remote-desktop
	ModemManager
	openvpn
	iio-sensor-proxy
	Remmina
	speech-dispatcher
	saned
	spice-vdagent
	spice-vdagentd
	wpa_supplicant
	xrdp
	xbrlapi
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
)

binaries_blacklist=(
	apport				# crash reporter
	avahi-browse			# avahi is local network-sharing.
	avahi-daemon
	avahi-resolve
	bluetoothctl
	bluetooth-sendto
	bluetoothd
	cc-remote-login-helper
	colord-sane
	colord-session
	cups				# cups is printer software
	cupsaccept			# The printer port (631) is a common attack vector.
	cupsd
	cupsctl
	cups-browse
	geoclue
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
	mtp-probe
	rsync
	rsync-ssl
	sane-find-scanner
	sane				# Scanner
	speech-dispatcher		# Speech synth
	spice-vdagent
	telnet				# A commonly abused protocol
	xbrlapi				# Speech tool
	ubuntu-report
	xrdp				# Remote desktop binary
	xdg-desktop-portal		# Wayland's screen-sharing utility
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

# Now we'll define some functions to make it easier to understand what the code does.

# touchScript creates the target file if it doesn't already exist, and then makes it executable for the system.
# Called like so: (touchScript "/full/path")
touchScript() {
	if [ ! -f "$1" ];  then
		echo "#!/bin/sh" > $1
		chmod +x $1
	fi
}

# uniqueLine adds a text line to a file if-and-only-if that line doesn't already exist verbatim.
# Called like so: (uniqueLine "line" "file")
uniqueLine() {
	line=$1 && file=$2
	grep -qsxF -- $line $file || echo "${line}" >> $file
}

# muteBinary handles all the logic for disabling binaries (basically Linux's equivalent to a .exe file)
# Called like so: (muteBinary 'location' 'name')
muteBinary() {
	# First, we symlink the script to /dev/null so that all future calls to it will fail.
	ln -fs /dev/null "${1}${2}"
	
	# Next, we make the file immutable so that the symlink is permanent.
	chattr +i ${1}${2}
	
	# Next we'll make sure that these files can't be updated either.
	echo "$(apt-mark hold $2)" > /dev/null
	# Many services have a daemon variant that's identical, but ends with an extra "d".
	echo "$(apt-mark hold "${2}d")" > /dev/null

	# Let's make sure these commands run at startup too.
	(uniqueLine "ln -fs /dev/null ${1}${2}" "/etc/init.d/${startup_file_name}")
	(uniqueLine "chattr +i ${1}${2}" "/etc/init.d/${startup_file_name}")
}

# muteService handles all the logic for disabling services (basically Linux's equivalent to a .exe file)
# Called like so: (muteService 'name')
muteService() {
	# mask --now redirects the service to /dev/null so that all future calls to it will fail.
	systemctl mask --now $1
	
	# Some services run in the user space, so we want to address that, too.
	systemlctl mask --now --user $1
	
	# Now we add these commands to our startup file, too.
	uniqueLine "systemctl mask --now ${1}" "/etc/init.d/${startup_file_name}"
	uniqueLine "systemctl mask --now --user ${1}" "/etc/init.d/${startup_file_name}"
}

# We're going to tell these commands to run at startup too, so we'll make sure that the file exists.
touchScript "/etc/init.d/startup_security.sh"

# The file shouldn't be immutable yet, but if you've run this script multiple times it might be.
chattr -i "/etc/init.d/${startup_file_name}"

# Next, we're going to iterate through our arrays in order to disable everything.
for service in "${service_blacklist[@]}"; do
	(muteService "${service}")
done

# For this one, we iterate through both the binaries list AND the locations list, in order to check every location for every binary.
for bin in "${binaries_blacklist[@]}"; do
	for loc in "${bin_locations[@]}"; do
 		# Check if file actually exists first before banning it
		if [ -f "${loc}${bin}" ]; then
			(muteBinary "$loc" "$bin")
		fi
	done
done

# Finally, we'll make the startup script immutable, so that bad actors can't edit it without admin privs.
chattr +i "/etc/init.d/${startup_file_name}"

echo "Aaaaand we're done!"
