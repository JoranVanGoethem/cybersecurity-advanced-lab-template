# **GEBRUIK NFTABLES** 

# The insecure "fake internet" host only network

## Use a web browser to browse to http://www.cybersec.internal
## Use a web browser to browse to http://www.cybersec.internal/cmd and test out this insecure application.
## Perform a default nmap scan on all machines.
## Enumerate the most interesting ports (you found in the previous step) by issuing a service enumeration scan (banner grab scan).
- What database software is running on the database machine? What version?

`nmap -sV 172.30.0.15`

on the database machine on port 3306 is mysql, mariadb running version: 10.3.23 or earlier

link: `https://nmap.org/nsedoc/scripts/mysql-databases.html`

### Try to search for a nmap script to brute-force the database. Another (even easier tool) is called hydra (https://github.com/vanhauser-thc/thc-hydra). Search online for a good wordlist. For example "rockyou" or https://github.com/danielmiessler/SecLists We suggest to try the default username of the database software and attack the database machine. Another interesting username worth a try is "toor".
- Try to SSH (using vagrant/vagrant) from red to another machine. Is this possible?

no

- What webserver software is running on web?

`nmap -sV -p 80,443 172.30.0.10`

result: service http & https

- Try the -sC option with nmap. Do you remember what this option is?

# Network Segmentation

## - What is meant here with the term "attack vector"?



## - Is there already network segmentation done on the (internal) company network?

no, should be:

**schema:**
- **DMZ:**
    - companyrouter
    - webserver
- **Client:**
    - employee
    - ...
- **servers:**
    - database
    - dns

## - Remember what a DMZ is? What machines would be in the DMZ in this environment? Are there multiple ways to configure this?
DMZ = demilitarized zone, een zone waarbij lan en het internet aan elkaar kunnen (lan kan aan internet en internet kan deels aan lan, enkel zervers in de dmz kunnen ze aan).

- Webserver

## - What could be annoying when using network segmentation? Tip in our case: take a look at client <-> server interaction.

# Firewall

