Most linux systems use systemd to manage their services.

Some of these services should be disabled for security purposes. The full list of commands is below.

You can also copy/download the disable-services.sh file (coming soon), and run it with "sudo bash disable-services.sh" in terminal.

```
systemctl mask --now --user xdg-desktop-portal
systemctl mask --now --user pipewire
sudo systemctl mask --now apport
sudo systemctl mask --now avahi-daemon.socket
sudo systemctl mask --now avahi-daemon
sudo systemctl mask --now bolt
sudo systemctl mask --now colord
sudo systemctl mask --now bluetooth
sudo systemctl mask --now bolt
sudo systemctl mask --now cups.path
sudo systemctl mask --now cups.socket
sudo systemctl mask --now cups
sudo systemctl mask --now cups-browsed
sudo systemctl mask --now geoclue
sudo systemctl mask --now gsd-print-notification
sudo systemctl mask --now gnome-remote-desktop
sudo systemctl mask --now ModemManager
sudo systemctl mask --now openvpn
sudo systemctl mask --now iio-sensor-proxy
sudo systemctl mask --now Remmina
sudo systemctl mask --now samba
sudo systemctl mask --now speech-dispatcher
sudo systemctl mask --now saned
sudo systemctl mask --now spice-vdagent
sudo systemctl mask --now spice-vdagentd
sudo systemctl mask --now wpa_supplicant
sudo systemctl mask --now xrdp

sudo systemctl mask --now tracker-miner
sudo systemctl mask --now tracker-miner-2
sudo systemctl mask --now tracker-miner-3
sudo systemctl mask --now tracker-miner-4
sudo systemctl mask --now tracker-miner-fs
sudo systemctl mask --now tracker-miner-fs-2
sudo systemctl mask --now tracker-miner-fs-3
sudo systemctl mask --now tracker-miner-fs-4
sudo systemctl mask --now tracker-extract
sudo systemctl mask --now tracker-extract-2
sudo systemctl mask --now tracker-extract-3
sudo systemctl mask --now tracker-extract-4

systemctl mask --now --user tracker-miner
systemctl mask --now --user tracker-miner-2
systemctl mask --now --user tracker-miner-3
systemctl mask --now --user tracker-miner-4
systemctl mask --now --user tracker-miner-fs
systemctl mask --now --user tracker-miner-fs-2
systemctl mask --now --user tracker-miner-fs-3
systemctl mask --now --user tracker-miner-fs-4
systemctl mask --now --user tracker-extract
systemctl mask --now --user tracker-extract-2
systemctl mask --now --user tracker-extract-3
systemctl mask --now --user tracker-extract-4
```

## Notes/explanations/exceptions:

pipewire: This forcibly disables your laptop's microphone.

bolt: Thunderbolt port, some people may still wwant this.

cups: Printer. Uses port 631 and therefore should be disabled.

gsd-print-notification: Uses port 631 as well.

bluetooth: Only disable this if you don't need it, or for high-security environments.

speech-dispatcher: If you need text-to-speech, this should stay on.

wpa_supplicant: This handles the wifi.

tracker-miner: These services cache the contents and file names for the desktop's search feature. Disabling it is safer than not. There are many variants, so we just list them all.

## Why "mask" and not "disable"? Mask causes weird messages when updating the operating system.

Mask effectively redirects all requests for that service to "/dev/null", a system-wide blackhole. This means that the service is unable to be automatically re-enabled by system updates, hence the errors.
