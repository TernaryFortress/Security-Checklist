# So you're sick of having your digital footprint monetized

Linux can seem a bit daunting to deal with, if you've not used it before. We'll provide a brief rundown of what you need to know.

For newbies, we want to select an Enterprise (not Community) distro that is both free, and which closely resembles Windows in order to ensure that as many people have access from a financial, technical, and secure position as possible.

To that end, we have chosen to recommend Ubuntu: https://releases.ubuntu.com/

Most users will want the latest Long-Term Support (LTS) version, which usually lasts for ~5 years. Ubuntu Pro is free for the first 5 devices.

You don't need to understand the entirety of the domain knowledge list initially, but it's a useful cheat-sheet when you run into the vocabulary later and are trying to figure out what everything actually means.

## Domain Knowledge

Terminal: The terminal window (also known as shell) is how you run most commands in Linux. You can manually type stuff, or you can create a file and run things via `bash /path/to/file`, either by typing out a path to the file, or dragging the file into the window to auto-populate the path.

Bashrc: Bashrc is a configuration file that runs when you open your terminal. Most of your configuration will go here. You can add things to your path by typing `open ~/.bashrc`. We suggest adding `export DO_NOT_TRACK=1` at the end of this, which is the universal environment variable for disabling telemetry. Of note, the `~` is a shortcut to your user directory, and the leading `.` before the file indicates that the file is hidden from the directory browser.

Path: This is how your system figures out where files and programs are when you open terminal. In bashrc, you can add things to your path like so: `export PATH="</path/to/more/executables>:$PATH"`. For example, if I add `export PATH="/home/username/bin:$PATH"` to my bashrc, then I can run files located in that directory by simply typing "filename" in my terminal.

NF Tables: Nft is the newer Linux firewall. For the most part, you'll just be blacklisting everything except ports 53 (dns), 67-68 (dhcp), 80 (http), 123 (ntp, date-time servers), 443 (https), 2408 (Cloudfare Warp, if you use it), and 51820 (Wireguard, if you use it).

Snap: This is Ubuntu's walled garden. Be aware that submitting applications to the snap store has fewer safeguards than for something like the Apple store. Make sure that you trust the uploader.

Apparmor: This is how Ubuntu decides what an installed application actually has access to. You can use it as an additional layer of defense on top of existing security features if you need to defend certain areas of your computer from being accessed by applications like your browser.

## Useful terminal commands

Change Directory: `cd /path/to/directory` is a way to change the absolute position of where your terminal session lives. You can also perform `cd ..` to go up a directory, and `cd directory-name` (note the lack of a leading `/` forward slash) or `cd ./directory-name` (note the leading `.` before the directory) to change the relative position and traverse via the current directory.

Copy: `cp /path/to/original.txt /where/to/copy/to.txt` creates a copy of a file.

List Files: `ls -a` lists all the files in the current directory.

Bash: `bash ./file-name.sh` runs a text file as if it were in terminal. This is useful for running many shell commands at once from a single file.

Sudo: Short for "Super User DO", this effectively runs the command as administrator. ex: `sudo bash ./some-script-requiring-admin-privs.sh`

Log in to terminal as admin: `su <admin-username>` allows you to switch terminal users to an admin account without logging out.

List Network Interfaces: `ip a` will show you how your computer connects to the internet.
