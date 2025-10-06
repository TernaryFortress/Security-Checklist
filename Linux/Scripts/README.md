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

## Known Issues

[_] - When using Firefox, attempting to upload files via the browser's File Explorer often does not work. Drag files into the browser to upload for now.

[_] - Disabling TrackerMiner (Ubuntu's File Indexer) causes the indexer to crash when opening a directory for the first time.
