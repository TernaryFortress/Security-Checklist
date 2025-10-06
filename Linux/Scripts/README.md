# A basic, open-source security suite for Linux.

Linux can seem a bit daunting to deal with, if you've not used it before. We provide two easy scripts.

Open terminal in this directory, and run:

```
sudo bash ./firefox.sh
sudo bash ./startup.sh
```

The first installs and hardens Snap's Firefox. It's so hard in fact, that the only way to update Firefox after running this script is to run the script again.

The second configures a firewall and blacklists a bunch of services that have been known for RDP exploits and other state actor backdoors.

## Our Apparmor profile is *extremely* thorough.

Of note, Firefox can only access files in the "Documents" folder, and some tools (mainly the File explorer) may be broken. There are plans to fix this at a later date when I have more time.
