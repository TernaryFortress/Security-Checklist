# A basic, open-source security suite for Linux.

Linux can seem a bit daunting to deal with, if you've not used it before. We provide two easy scripts.

Open terminal in this directory, and run:

```
sudo bash ./firefox.sh
sudo bash ./startup.sh
```

The first installs and hardens Snap's Firefox. It's so hard in fact, that the only way to update Firefox after running this script is to run the script again.

The second configures a firewall and blacklists a bunch of services that have been known for RDP exploits and other state actor backdoors.

## Quirks

Firefox is only supposed to be able to access & upload generic files from the Documents folder.

DNS over HTTPS is disabled by default, because it overrides your computer's VPN. You should be using a VPN. If you are not, you should turn this feature on in firefox-policies. It will override your VPN's DNS blocklist. We will include a free VPN installation script shortly.

## Known Issues

- [ ] - When using Firefox, attempting to upload files via the browser's File Explorer often does not work. Drag files into the browser to upload for now.

- [x] - Latency on file-manager actions: This *should* have been fixed automatically by the script, but if the script didn't connect or if an update broke something, run "systemctl --user mask --now xdg-desktop-portal" and, if that still fails, "systemctl --user mask --now xdg-desktop-portal-gnome"
