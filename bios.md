# Securing your BIOS

Your BIOS is your computer's first step to booting up. Most people just ignore their BIOS, but recent attacks like Black Lotus have highlighted the importance of addressing this issue.

First thing's first, if you're going to be booting into the BIOS, turn off your computer and remove all USB drives. If you're in Full Paranoia mode, remove any USB mice too. Some BIOS don't disable Autoplay by default.

Turn on the computer, and press the BIOS key on your keyboard. Usually the keys to enter the BIOS are **Delete**, **F12**, **F11**, **F10**, or **F2**. Your startup screen will usually just tell you which key to press, but you may need to search for it online.

(more to come)

## Checklist

- [ ] Before doing anything else, set an admin password on the Bios. You should make sure you don't forget this because it's a nuisance to change otherwise.
- [ ] It is advised to keep the BIOS firmware as up-to-date as possible. I won't claim responsibility for vendors who don't maintain safe upgrade pathways or otherwise bricked motherboards.
- [ ] Enable Secure Boot - Unless you're using an outdated operating system (in which case, the results from following this guide are the least of your concerns), this is necessary.
- [ ] Disable CSM - Compatibility Support Module is intentionally incompatible with Secure Boot.
- [ ] Enable the TPM - This (Trusted Platform Module) is called a few different things by different vendors. Think of this like an authenticator for your machine's hardware that many sites automatically utilize to protect your logins.
- [ ] Disable Boot from LAN - You never want to boot from the network without intention.
- [ ] **Intel Only** - Ensure AMT is disabled if present. This (Active Management Technology) is a Remote Desktop Protocol that's targeted at enterprise devies.
- [ ] **Asus Only** - Disable PXE/ACC - PXE (Preboot Execution Environment) is a setting to install the operating system from the LAN network. ACC (ASUS Control Center) has basically the same functionality.
