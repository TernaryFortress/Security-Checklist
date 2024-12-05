#!/bin/bash

# You can automatically configure your system's firewall with a single command!
# In terminal, run `sudo bash /path/to/this/file.sh`. Drag the file into terminal if you don't want to type the full path.

# We need to enable the service or it won't function.
systemctl enable nftables
systemctl start nftables

# Uncomplicated Firewall is the older variant of NF Tables
systemctl mask --now ufw

# Deletes the old firewall if it exists, or we'll add redundant policies.
nft add table inet firewall && nft delete table inet firewall
# Add the new firewall & removes the default one.
nft add table inet firewall && nft delete table inet filter

# We'll create some sets to make managing the requisite services easier.
nft add set inet firewall tcp_net {type inet_service\; elements={53, 80, 443} \;}  # DNS, HTTP, HTTPS
nft add set inet firewall udp_net {type inet_service\; elements={53, 123, 2408, 51820} \;}  # DNS, NTP, Cloudflare Warp, Wireguard
nft add set inet firewall loopback_blacklist {type inet_service\; elements={631, 5353} \;}  # Printer, Network Sharing

# ----- input chain -----
nft add chain inet firewall input { type filter hook input priority -10 \; policy drop \; }
nft add rule inet firewall input ct state invalid drop
nft add rule inet firewall input ip protocol igmp drop                # Pings & other recon commands
nft add rule inet firewall input ct state established,related accept	# 3-way handshake
nft add rule inet firewall input tcp dport @tcp_net accept
nft add rule inet firewall input udp dport @udp_net accept
nft add rule inet firewall input udp dport 68 accept			# DHCP (Your router's Ip Address server)

# Loopback (127.0.0.1) is how your computer talks to itself. The desktop needs it, but certain protocols abuse their trust.
nft add rule inet firewall input iif "lo" meta l4proto { tcp, udp } dport @loopback_blacklist drop
nft add rule inet firewall input iif "lo" accept

# ----- output chain -----
nft add chain inet firewall output { type filter hook output priority -10 \; policy drop \; }
nft add rule inet firewall output tcp dport @tcp_net accept
nft add rule inet firewall output udp dport @udp_net accept
nft add rule inet firewall output udp dport 67 accept			# DHCP (Your router's Ip Address server)

# Loopback (127.0.0.1) is how your computer talks to itself. The desktop needs it, but certain protocols abuse their trust.
nft add rule inet firewall output oif "lo" meta l4proto { tcp, udp } dport @loopback_blacklist drop
nft add rule inet firewall output oif "lo" accept

# ---- forward chain -----
nft add chain inet firewall forward { type filter hook forward priority -10 \; policy drop \; }

# ------- complete --------
nft list ruleset > /etc/nftables.conf
nft list ruleset
