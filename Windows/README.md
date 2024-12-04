# At least it's something?

Truthfully, I've not been able to create a configuration of Windows yet which has not stil been vulnerable to triangulation of some form or another.

Still, here's everything I know (work in progress)

## Firewall

Windows Firewall only blocks inbound connections by default, and whitelists all outbound traffic. This is suboptimal, but difficult to change.

Of note, you'll want to block all the network sharing, presence, file sharing, local network, and Toredo.

## Group Policy

Group Policy Editor allows you to disable telemetry and other annoyances.
