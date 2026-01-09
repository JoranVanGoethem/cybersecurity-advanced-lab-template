# LAYOUT

| Zone                                         | adres-range               |
| :---                                         | :---                      |
| DMZ                                          |`172.30.10.0 /24`          |
| server                                       |`172.30.20.0 /24`          |
| client                                       |`172.30.30.0 /24`          |

| device                                       | adres                     |
| :---                                         | :---                      |
| **INTERNAL**                                                             |
| ---------------------------------*DMZ*---------------------------------- |
| companyrouter - dmz                          |`172.30.10.1`              |
| dns                                          |`172.30.10.4`              |
| web                                          |`172.30.10.10`             |
| --------------------------------*server*-------------------------------- |
| companyrouter - server                       |`172.30.20.1`              |
| database                                     |`172.30.20.15   `          |
| SIEM                                         |`172.30.0.20 `             |
| --------------------------------*client*-------------------------------- |
| companyrouter - client                       |`172.30.30.1`              |
| employee                                     |`172.30.30.123`            |
| win10Client                                  |`172.30.0.125`             |
| **INTERNET**                                                             |
| companyrouter                                |`192.168.62.253`           |
| isprouter                                    |`192.168.62.254`           |
|                                              |`10.0.2.15`                |
| homerouter                                   |`192.168.62.42`            |
| laptop                                       |`DHCP`                     |
| RED                                          |`192.168.62.10`            |
| **HOME-LAN**                                                             |
| homerouter                                   |`172.10.10.254`            |
| remote_employee                              |`172.10.10.123`            |

---

# Lesson 1 DNS

## DNS – Queries & Analyse

### nslookup

| Taak                             | Commando                        |
| -------------------------------- | ------------------------------- |
| Standaard DNS lookup             | `nslookup www.ugent.be`         |
| Lookup via specifieke DNS server | `nslookup www.ugent.be 8.8.8.8` |
| Reverse lookup                   | `nslookup 157.193.43.50`        |

---

### dig

| Taak                      | Commando                             |
| ------------------------- | ------------------------------------ |
| Basis DNS query           | `dig ugent.be`                       |
| Alleen IP-adres tonen     | `dig +short ugent.be`                |
| Authoritative nameservers | `dig +short NS ugent.be`             |
| Reverse DNS lookup        | `dig +short -x 157.193.43.50`        |
| Zone transfer testen      | `dig axfr ugent.be @<dns-server-ip>` |

---

### host

| Taak              | Commando             |
| ----------------- | -------------------- |
| DNS lookup (kort) | `host www.ugent.be`  |
| Reverse lookup    | `host 157.193.43.50` |

---

## Wireshark (GUI)

*(geen CLI-commando’s, maar handig om te onthouden)*

| Actie                 | Locatie                           |
| --------------------- | --------------------------------- |
| OSI-lagen bekijken    | Packet Details pane               |
| Conversaties          | Statistics → Conversations        |
| Protocolhiërarchie    | Statistics → Protocol Hierarchy   |
| Bestanden exporteren  | File → Export Objects → HTTP      |
| SSH sessies vinden    | Filter: `ssh` of `tcp.port == 22` |
| HTTP verkeer filteren | `http`                            |

---

## Netwerkconfiguratie & Inspectie

| Taak                  | Commando               |               |
| --------------------- | ---------------------- | ------------- |
| IP-configuratie       | `ip a`                 |               |
| Routing tabel         | `ip route`             |               |
| Default gateway tonen | `ip route              | grep default` |
| DNS configuratie      | `cat /etc/resolv.conf` |               |
| Interface status      | `ip link show`         |               |

---

## Basis netwerk testen

| Taak             | Commando             |
| ---------------- | -------------------- |
| Ping testen      | `ping 8.8.8.8`       |
| Ping op hostname | `ping www.ugent.be`  |
| Traceroute       | `traceroute 8.8.8.8` |
| ARP tabel        | `ip neigh`           |

---

## SSH

| Taak                 | Commando                |
| -------------------- | ----------------------- |
| SSH verbinden        | `ssh user@host`         |
| SSH met andere poort | `ssh -p 2222 user@host` |
| Verbinding testen    | `ssh -v user@host`      |

---

## tcpdump – Traffic capturen (CLI)

### Installatie

| Taak                            | Commando                   |
| ------------------------------- | -------------------------- |
| tcpdump installeren (RHEL/Alma) | `sudo dnf install tcpdump` |
| tcpdump installeren (Debian)    | `sudo apt install tcpdump` |

---

### Basis captures

| Taak                        | Commando                            |
| --------------------------- | ----------------------------------- |
| Alle traffic op interface   | `tcpdump -i eth0`                   |
| ICMP (ping) capturen        | `tcpdump -i eth0 icmp`              |
| Traffic van specifieke host | `tcpdump -i eth0 host 192.168.1.10` |
| Alleen inkomend verkeer     | `tcpdump -i eth0 src 192.168.1.10`  |
| Alleen uitgaand verkeer     | `tcpdump -i eth0 dst 192.168.1.10`  |

---

### Protocol-specifiek

| Taak           | Commando                      |
| -------------- | ----------------------------- |
| SSH verkeer    | `tcpdump -i eth0 tcp port 22` |
| SSH uitsluiten | `tcpdump -i eth0 not port 22` |
| HTTP verkeer   | `tcpdump -i eth0 tcp port 80` |
| DNS verkeer    | `tcpdump -i eth0 port 53`     |

---

### Capture naar bestand

| Taak             | Commando                               |
| ---------------- | -------------------------------------- |
| Capture opslaan  | `tcpdump -i eth0 -w capture.pcap`      |
| Capture + filter | `tcpdump -i eth0 port 80 -w http.pcap` |
| Capture lezen    | `tcpdump -r capture.pcap`              |

---

### Handige flags

| Flag       | Betekenis              |
| ---------- | ---------------------- |
| `-i`       | Interface              |
| `-n`       | Geen DNS-resolving     |
| `-v / -vv` | Meer detail            |
| `-w`       | Schrijven naar bestand |
| `-r`       | Lezen uit bestand      |

---

## HTTP testen

| Taak             | Commando                               |
| ---------------- | -------------------------------------- |
| HTTP request     | `curl http://www.cybersec.internal`    |
| Headers bekijken | `curl -I http://www.cybersec.internal` |
| Verbose output   | `curl -v http://www.cybersec.internal` |

---

## Bestanden kopiëren (pcap naar host)

| Taak                     | Commando                              |
| ------------------------ | ------------------------------------- |
| Bestand kopiëren via SCP | `scp user@router:/tmp/capture.pcap .` |

---

## DNS Zone Transfer (attack & test)

| Taak                           | Commando                              |
| ------------------------------ | ------------------------------------- |
| Zone transfer testen (Linux)   | `dig axfr domain.local @dns-ip`       |
| Zone transfer testen (Windows) | `nslookup` → `ls domain.local`        |
| Kwetsbaarheid fixen            | Zone transfers beperken in DNS config |

---

##  Algemene troubleshooting

| Taak             | Commando                              |
| ---------------- | ------------------------------------- |
| Services checken | `systemctl status named`              |
| Firewall status  | `iptables -L -n` / `nft list ruleset` |
| Logbestanden     | `journalctl -xe`                      |

---

# Lesson 2 – FIREWALL & NETWORK SEGMENTATION CHEAT SHEET

| Task                                         | Command / Notes                                                                                                                                                                     |
| :------------------------------------------- | :---------------------------------------------------------------- |
| **Flush alle nftables regels**               | `nft flush ruleset`                                                                                                                                                                 |
| **Laad nftables config**                     | `nft -f /etc/nftables.conf`                                                                                                                                                         |
| **Start / enable nftables service**          | `systemctl enable --now nftables`                                                                                                                                                   |
| **Bekijk actieve regels**                    | `nft list ruleset`                                                                                                                                                                  |
| **Maak een set aan (voorbeeld)**             | `nft add set inet firewall dmz { type ipv4_addr\; flags constant\; }`                                                                                                               |
| **Toon network interfaces en IP’s**          | `ip addr show` / `ip a`                                                                                                                                                             |
| **IP forwarding inschakelen**                | `sysctl -w net.ipv4.ip_forward=1`                                                                                                                                                   |
| **IP forwarding persistent**                 | `echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf`                                                                                                                                |
| **Voeg IP toe aan interface (alias)**        | `ip addr add 172.30.10.1/24 dev eth0`                                                                                                                                               |
| **Bekijk routes**                            | `ip route show` / `route -n`                                                                                                                                                        |
| **Ping een host**                            | `ping <IP>`                                                                                                                                                                         |
| **Controleer open/filtered ports (nmap)**    | `nmap -p 22,80,666 <host>`                                                                                                                                                          |
| **VirtualBox – NIC toevoegen aan VM**        | `VBoxManage modifyvm <VM_NAME> --nic1 intnet --intnet1 "<NETWORK_NAME>"`                                                                                                            |
| **VirtualBox – Host-only adapter toevoegen** | `VBoxManage modifyvm <VM_NAME> --nic2 hostonly --hostonlyadapter2 "<HOST_NET_NAME>"`                                                                                                |
| **VirtualBox – NAT adapter toevoegen**       | `VBoxManage modifyvm <VM_NAME> --nic3 nat`                                                                                                                                          |
| **VirtualBox – IP als guest property**       | `VBoxManage guestproperty set "<VM_NAME>" "/VirtualBox/GuestInfo/Net/0/V4/IP" "<IP>"`                                                                                               |
| **Start VM**                                 | `VBoxManage startvm <VM_NAME> --type headless`                                                                                                                                      |
| **Stop VM zacht**                            | `VBoxManage controlvm <VM_NAME> poweroff soft`                                                                                                                                      |
| **List host-only networks**                  | `VBoxManage list hostonlyifs`                                                                                                                                                       |
| **Verwijder host-only network**              | `VBoxManage hostonlyif remove <NAME>`                                                                                                                                               |
| **nmcli – NIC toevoegen / configureren**     | `nmcli connection add type ethernet con-name eth0 ifname eth0 autoconnect yes`                                                                                                      |
| **nmcli – Stel IP statisch in**              | `nmcli connection modify eth0 ipv4.method manual` <br> `nmcli connection modify eth0 ipv4.addresses "172.30.10.1/24 172.30.20.1/24 172.30.30.1/24"` <br> `nmcli connection up eth0` |
| **nmcli – DHCP gebruiken**                   | `nmcli connection modify eth2 ipv4.method auto`                                                                                                                                     |
---

# Lesson 3 – SSH Cheat Sheet

## Basic SSH

| Task | Command |
| :--- | :--- |
| Check SSH version (Windows) | `ssh -V` |
| Generate SSH key (Ed25519) | `ssh-keygen -t ed25519 -f ~/.ssh/id_company` |
| Show public key | `type ~/.ssh/id_company.pub` |
| Basic SSH login | `ssh user@host` |
| SSH login on custom port | `ssh -p 2222 user@host` |
| Exit SSH session | `exit` |


## SSH Configuration

| Task | Command |
| :--- | :--- |
| SSH config file (Windows) | `C:\Users\<user>\.ssh\config` |
| Connect using SSH config | `ssh web` |
| Verbose SSH (debugging) | `ssh -vvv web` |
| Test config parsing | `ssh -G web` |


## Bastion / Jump Host

| Task | Command |
| :--- | :--- |
| SSH via jump host (manual) | `ssh -J user@bastion user@target` |
| SSH via jump host (config) | `ProxyJump bastion` |
| Double jump (manual) | `ssh -J bastion1,bastion2 user@target` |


## VirtualBox / Port 2222

| Task | Command |
| :--- | :--- |
| SSH to ISP router (port forwarding) | `ssh -p 2222 vagrant@192.168.62.254` |
| SSH using config (port 2222) | `ssh isprouter` |

---

## SSH Key Installation (Windows → Linux)

| Task | Command |
| :--- | :--- |
| Create .ssh directory | `mkdir -p ~/.ssh` |
| Edit authorized_keys | `nano ~/.ssh/authorized_keys` |
| Correct permissions (.ssh) | `chmod 700 ~/.ssh` |
| Correct permissions (authorized_keys) | `chmod 600 ~/.ssh/authorized_keys` |


## SSH Hardening (Server Side)

| Task | Command |
| :--- | :--- |
| Edit SSH config | `sudo nano /etc/ssh/sshd_config` |
| Disable password auth | `PasswordAuthentication no` |
| Enable key auth | `PubkeyAuthentication yes` |
| Restart SSH | `sudo systemctl restart sshd` |
| Check SSH status | `sudo systemctl status sshd` |


## Local Port Forwarding (-L)

| Task | Command |
| :--- | :--- |
| Forward local port | `ssh -L local:target:port user@host` |
| Webserver → localhost:8080 | `ssh -L 8080:172.30.0.10:80 companyrouter` |
| Database → localhost:3306 | `ssh -L 3306:172.30.0.15:3306 companyrouter` |
| Multiple forwards | `ssh -L 8080:172.30.0.10:80 -L 3306:172.30.0.15:3306 companyrouter` |


## Remote Port Forwarding (-R)

| Task | Command |
| :--- | :--- |
| Remote port forwarding | `ssh -R remote:target:port user@host` |
| Expose internal DB remotely | `ssh -R 3306:172.30.0.15:3306 companyrouter` |

⚠️ Use with caution — higher security risk.


## SSH Tunneling Use Cases

| Scenario | Method |
| :--- | :--- |
| Access internal web app | Local forwarding (`-L`) |
| Access internal database | Local forwarding (`-L`) |
| Expose internal service | Remote forwarding (`-R`) |
| Replace simple VPN | SSH tunneling |

---

## Firewall Checks (Linux)

| Task | Command |
| :--- | :--- |
| List firewall services | `sudo firewall-cmd --list-services` |
| Allow SSH | `sudo firewall-cmd --add-service=ssh --permanent` |
| Reload firewall | `sudo firewall-cmd --reload` |

---

## Lesson 4 – HONEYPOTS (Cowrie)

| Task                                | Command                                                |
| :---------------------------------- | :----------------------------------------------------- |
| Check actieve containers            | `docker ps`                                            |
| Check alle containers (ook gestopt) | `docker ps -a`                                         |
| Pull Cowrie image                   | `docker pull cowrie/cowrie`                            |
| Start Cowrie honeypot (poort 22)    | `docker run -d --name cowrie -p 22:2222 cowrie/cowrie` |
| Stop Cowrie container               | `docker stop cowrie`                                   |
| Start bestaande Cowrie container    | `docker start cowrie`                                  |
| Restart Cowrie container            | `docker restart cowrie`                                |
| Verwijder Cowrie container          | `docker rm cowrie`                                     |
| Bekijk Cowrie container logs        | `docker logs cowrie`                                   |
| Live logs volgen                    | `docker logs -f cowrie`                                |
| Ga in Cowrie container              | `docker exec -it cowrie /bin/bash`                     |
| Check welke poorten luisteren       | `ss -tlnp`                                             |
| Controleer SSH daemon config        | `sudo vi /etc/ssh/sshd_config`                         |
| Restart SSH daemon                  | `sudo systemctl restart sshd`                          |
| SSH naar echte router               | `ssh -p 2222 user@companyrouter`                       |
| SSH naar honeypot (attacker)        | `ssh user@companyrouter`                               |
| Simuleer brute-force login          | `ssh root@companyrouter`                               |
| Toon Cowrie log directory           | `ls /cowrie/cowrie-git/var/log/cowrie/`                |
| Bekijk cowrie.log                   | `cat /cowrie/cowrie-git/var/log/cowrie/cowrie.log`     |
| Bekijk JSON logs                    | `cat /cowrie/cowrie-git/var/log/cowrie/cowrie.json`    |
| Bekijk TTY sessies                  | `ls /cowrie/cowrie-git/var/log/cowrie/tty/`            |
| Copy default Cowrie config          | `cp etc/cowrie.cfg.dist etc/cowrie.cfg`                |
| Edit Cowrie config                  | `vi etc/cowrie.cfg`                                    |
| Enable fake shell auth              | `auth_class = cowrie.auth_class.UserDB`                |
| Check SSH service status            | `systemctl status sshd`                                |
| lokaal laten draaien                | `make docker-build`                                    |

---

### Extra

| Task                        | Command                                  |             |
| :-------------------------- | :--------------------------------------- | ----------- |
| Toon Docker info            | `docker info`                            |             |
| Toon container netwerk info | `docker inspect cowrie`                  |             |
| Check open poorten          | `nmap -p 22,2222 companyrouter`          |             |
| Bekijk IP van attacker      | `docker logs cowrie \| grep login`       |             |
| Cleanup alles               | `docker stop cowrie && docker rm cowrie` |             |

---

# Lesson 5 – BorgBACKUPS

| Task                                        | Command / Example                                                                                                                    |
| :------------------------------------------ | :------------------------------------------------------------- |
| **Initialize a repository**                 | `borg init --encryption=repokey vagrant@<db-ip>:/home/vagrant/backups`                                                               |
| **Generate SSH key for passwordless login** | `ssh-keygen -t ed25519`<br>`ssh-copy-id vagrant@<db-ip>`                                                                             |
| **Check repository size (webserver)**       | `du -h --si /var/www`                                                                                                                |
| **Check repository size (remote/backups)**  | `du -h --si /home/vagrant/backups`                                                                                                   |
| **Create first backup**                     | `borg create vagrant@<db-ip>:/home/vagrant/backups::first /var/www`                                                                  |
| **Create second backup**                    | `borg create vagrant@<db-ip>:/home/vagrant/backups::second /var/www`                                                                 |
| **List archives in repo**                   | `borg list vagrant@<db-ip>:/home/vagrant/backups`                                                                                    |
| **Export Borg keyfile**                     | `borg key export vagrant@<db-ip>:/home/vagrant/backups borg-keyfile.txt`                                                             |
| **Restore files from backup**               | `borg extract --verbose --strip-components 2 vagrant@<db-ip>:/home/vagrant/backups::first var/www`                                   |
| **Check repository integrity**              | `borg check --verbose vagrant@<db-ip>:/home/vagrant/backups`                                                                         |
| **Verify all data chunks**                  | `borg check --verify-data --verbose vagrant@<db-ip>:/home/vagrant/backups`                                                           |
| **Automate backup (script)**                | `/usr/local/bin/borg-backup.sh` (see full script above)                                                                              |
| **Prune old backups (retention)**           | `borg prune --keep-minute=12 --keep-hourly=24 --keep-daily=7 --keep-weekly=4 --keep-monthly=6 vagrant@<db-ip>:/home/vagrant/backups` |
| **Compact repository after prune**          | `borg compact vagrant@<db-ip>:/home/vagrant/backups`                                                                                 |
| **Check contents of an archive**            | `borg list vagrant@<db-ip>:/home/vagrant/backups::second`                                                                            |
| **Compare two backups**                     | `borg diff vagrant@<db-ip>:/home/vagrant/backups::first vagrant@<db-ip>:/home/vagrant/backups::second`                               |

---

# Lesson 6 - CA-HTTPS Cheat Sheet

## Section 1: Certificate Authority (CA) - isprouter

| Task | Command / Action |
| :--- | :--- |
| Generate CA private key | `openssl genrsa -out ca.key 4096` |
| Create CA self-signed certificate | `openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt` |
| View CA certificate details | `openssl x509 -in ca.crt -text -noout` |

---

## Section 2: Webserver Key and CSR - webserver (172.30.0.10)

| Task | Command / Action |
| :--- | :--- |
| Generate webserver private key | `openssl genrsa -out webserver.key 2048` |
| Create OpenSSL config for CSR (`webserver.cnf`) | Create file with content:<br>````ini<br>[ req ]<br>default_bits = 2048<br>prompt = no<br>default_md = sha256<br>req_extensions = req_ext<br>distinguished_name = dn<br><br>[ dn ]<br>CN = cybersec.internal<br><br>[ req_ext ]<br>subjectAltName = @alt_names<br><br>[ alt_names ]<br>DNS.1 = cybersec.internal<br>DNS.2 = www.cybersec.internal<br>IP.1 = 172.30.0.10<br>```` |
| Generate CSR using config | `openssl req -new -key webserver.key -out webserver.csr -config webserver.cnf` |
| View CSR details | `openssl req -in webserver.csr -text -noout` |
| Copy CSR to CA for signing | `scp webserver.csr user@192.168.62.254:/root/` |

---

## Section 3: Sign Webserver Certificate - CA (isprouter)

| Task | Command / Action |
| :--- | :--- |
| Sign CSR with CA to create server certificate | `openssl x509 -req -in webserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out webserver.crt -days 825 -sha256 -extensions req_ext -extfile webserver.cnf` |
| View signed certificate details | `openssl x509 -in webserver.crt -text -noout` |
| Copy signed certificate back to webserver | `scp webserver.crt user@172.30.0.10:/etc/ssl/` |
| Copy CA certificate to webserver | `scp ca.crt user@172.30.0.10:/etc/ssl/` |

---

## Section 4: Webserver HTTPS Configuration


TLS 1.2 configuration example (Apache)
```
SSLProtocol TLSv1.2
SSLCipherSuite RSA+AES256-SHA
SSLHonorCipherOrder on
```

| TLS 1.3 configuration example (Apache) 
```
SSLProtocol TLSv1.3
SSLCipherSuite TLS_AES_256_GCM_SHA384
```

| Enable HTTPS virtual host | Configure Apache `<VirtualHost *:443>` with `SSLEngine on`, certificate files, and DocumentRoot |

---

## Section 5: Client Browser / Wireshark Setup

| Task | Command / Action |
| :--- | :--- |
| Import CA certificate into browser | Use browser settings → Trusted Root Authorities → import `ca.crt` |
| Capture HTTPS traffic with Wireshark | Open Wireshark → select interface → apply filter `tcp port 443` |
| Decrypt TLS 1.2 using server private key | Preferences → Protocols → TLS → RSA Keys List → add server IP, port 443, protocol `http`, and key file `webserver.key` |
| Decrypt TLS 1.3 using SSLKEYLOGFILE | Preferences → Protocols → TLS → (Pre)-Master-Secret log filename → load `sslkeys.log` |

**Enable SSLKEYLOGFILE for TLS 1.3 decryption**
```
export SSLKEYLOGFILE=/home/user/sslkeys.log
firefox
```

---

## Section 6: Notes / Tips

| Topic | Notes |
| :--- | :--- |
| CN vs SAN | CN is the old hostname field; modern browsers use SAN. Always include SANs. |
| Wildcard certificates | Example: `*.example.internal`. Easier management, but risk if one server is compromised. |
| TLS 1.2 vs TLS 1.3 | TLS 1.2 can be decrypted with server private key; TLS 1.3 uses PFS, requiring SSLKEYLOGFILE for decryption. |
| File locations | Keep `ca.key` **secret**; `webserver.key` should remain on webserver unless for lab decryption only. |
| Flow summary | CSR is generated on webserver → signed by CA on isprouter → signed cert returned to webserver → client imports CA certificate. |

---

# Lesson 7 - SIEM

## Wazuh Server (SIEM)

| Taak                      | Commando                                                      |
| ------------------------- | ------------------------------------------------------------- |
| Status Wazuh manager      | `systemctl status wazuh-manager`                              |
| Status Wazuh indexer      | `systemctl status wazuh-indexer`                              |
| Status Wazuh dashboard    | `systemctl status wazuh-dashboard`                            |
| Start alle Wazuh services | `systemctl start wazuh-manager wazuh-indexer wazuh-dashboard` |
| Stop alle Wazuh services  | `systemctl stop wazuh-manager wazuh-indexer wazuh-dashboard`  |
| Herstart Wazuh manager    | `systemctl restart wazuh-manager`                             |
| Agent management tool     | `/var/ossec/bin/manage_agents`                                |
| Bekijk Wazuh logs         | `tail -f /var/ossec/logs/ossec.log`                           |

---

## Wazuh Agent – Linux (AlmaLinux)

| Taak                         | Commando                                   |
| ---------------------------- | ------------------------------------------ |
| Install Wazuh agent          | `dnf install wazuh-agent`                  |
| Enable & start agent         | `systemctl enable wazuh-agent --now`       |
| Stop agent                   | `systemctl stop wazuh-agent`               |
| Restart agent                | `systemctl restart wazuh-agent`            |
| Agent status                 | `systemctl status wazuh-agent`             |
| Configuratie aanpassen       | `vim /var/ossec/etc/ossec.conf`            |
| Test FIM (bestand aanpassen) | `touch test.txt` / `echo test >> test.txt` |

---

## File Integrity Monitoring (FIM)

| Taak                | Actie / Commando                        |
| ------------------- | --------------------------------------- |
| FIM configureren    | `<syscheck>` sectie in `ossec.conf`     |
| Monitor directory   | `<directories>/home/user</directories>` |
| Agent herstarten    | `systemctl restart wazuh-agent`         |
| FIM events bekijken | Wazuh Dashboard → Integrity Monitoring  |

---

## Windows – Wazuh Agent

| Taak                    | Actie / Commando                               |
| ----------------------- | ---------------------------------------------- |
| Wazuh agent installeren | `.msi installer`                               |
| Agent starten           | `Start-Service WazuhSvc`                       |
| Agent stoppen           | `Stop-Service WazuhSvc`                        |
| Agent status            | `Get-Service WazuhSvc`                         |
| Agent logs              | `C:\Program Files (x86)\ossec-agent\ossec.log` |

---

## Windows – Sysmon & PowerShell Logging

| Taak                                  | Commando                                                       |
| ------------------------------------- | -------------------------------------------------------------- |
| Sysmon installeren                    | `sysmon -i sysmonconfig.xml`                                   |
| Sysmon herconfigureren                | `sysmon -c sysmonconfig.xml`                                   |
| Sysmon verwijderen                    | `sysmon -u`                                                    |
| Sysmon events bekijken                | `Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"` |
| PowerShell history                    | `Get-History`                                                  |
| PowerShell transcript (indien actief) | `C:\Users\*\Documents\PowerShell_transcripts\`                 |

---

## Threat Hunting

| Taak                     | Locatie                           |
| ------------------------ | --------------------------------- |
| Linux command execution  | Wazuh Dashboard → Security Events |
| Root / sudo commands     | Linux audit logs                  |
| Windows process creation | Sysmon Event ID 1                 |
| PowerShell cmdlets       | PowerShell Operational log        |
| cmd.exe executies        | Sysmon + Windows Security logs    |

---

## Tcpdump (Network Capture)

| Taak                | Commando                                      |
| ------------------- | --------------------------------------------- |
| Capture verkeer     | `tcpdump -i eth0 -w capture.pcap`             |
| Capture met rotatie | `tcpdump -i eth0 -w capture_%H%M.pcap -G 300` |
| Lees pcap           | `tcpdump -r capture.pcap`                     |
| Filter ICMP         | `tcpdump icmp`                                |
| Filter DNS          | `tcpdump port 53`                             |

---

## Suricata – Offline IDS

| Taak                     | Commando                                        |
| ------------------------ | ----------------------------------------------- |
| Install Suricata         | `dnf install suricata`                          |
| Test config              | `suricata -T -c /etc/suricata/suricata.yaml`    |
| Analyseer pcap           | `suricata -r capture.pcap -l /var/log/suricata` |
| Analyseer map met pcaps  | `suricata -r /pcaps -l /var/log/suricata`       |
| Bekijk alerts (leesbaar) | `cat /var/log/suricata/fast.log`                |
| JSON alerts (Wazuh)      | `/var/log/suricata/eve.json`                    |

---

## Custom Suricata Rules

| Doel          | Regel                                                                                |
| ------------- | ------------------------------------------------------------------------------------ |
| Ping detectie | `alert icmp any any -> any any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)`      |
| DNS detectie  | `alert dns any any -> any any (msg:"DNS Query detected"; sid:1000002; rev:1;)`       |
| Hydra attack  | `alert tcp any any -> any 22 (msg:"Possible Hydra SSH attack"; sid:1000003; rev:1;)` |

---

## Integratie Suricata → Wazuh

| Taak               | Actie                                |
| ------------------ | ------------------------------------ |
| Eve.json volgen    | `tail -f /var/log/suricata/eve.json` |
| Wazuh agent config | `<localfile>` met JSON decoder       |
| Agent herstarten   | `systemctl restart wazuh-agent`      |
| Alerts bekijken    | Wazuh Dashboard → Security Events    |

---

# Lesson 8 – IPsec (Manual)

## 1. Basis netwerk & routing

| Task                               | Command                                         |
| :--------------------------------- | :---------------------------------------------- |
| Toon IP-configuratie               | `ip a`                                          |
| Toon routing tabel                 | `ip r`                                          |
| Activeer IP forwarding (tijdelijk) | `echo 1 > /proc/sys/net/ipv4/ip_forward`        |
| Controleer IP forwarding           | `sysctl net.ipv4.ip_forward`                    |
| Voeg route toe (home → company)    | `ip route add 172.30.0.0/16 via 192.168.62.253` |
| Voeg route toe (company → home)    | `ip route add 172.10.10.0/24 via 192.168.62.42` |

---

## 2. Connectiviteit testen

| Task                   | Command                   |
| :--------------------- | :------------------------ |
| Ping company webserver | `ping 172.30.0.10`        |
| Ping companyrouter LAN | `ping 172.30.255.254`     |
| Ping remote employee   | `ping 172.10.10.123`      |
| HTTP-test              | `curl http://172.30.0.10` |

---

## 3. Man-in-the-Middle (Ettercap)

| Task               | Command                                                                      |
| :----------------- | :--------------------------------------------------------------------------- |
| Start ARP spoofing | `sudo ettercap -Tq -i eth0 -M arp:remote /192.168.62.42// /192.168.62.253//` |

Wireshark filters:

* `icmp`
* `http`
* `esp`

---

## 4. IPsec opschonen

| Task                          | Command                |
| :---------------------------- | :--------------------- |
| Verwijder alle IPsec policies | `ip xfrm policy flush` |
| Verwijder alle IPsec states   | `ip xfrm state flush`  |

---

## 5. IPsec tunnel: homerouter → companyrouter

### homerouter (uitgaand)

| Task                  | Command                                                                                                                                     |
| :-------------------- | ------------------------------------------------------------------------------------- |
| Voeg ESP SA toe       | `ip xfrm state add src 192.168.62.42 dst 192.168.62.253 proto esp spi 0x007 mode tunnel enc aes <KEY1>`                                     |
| Voeg IPsec policy toe | `ip xfrm policy add src 172.10.10.0/24 dst 172.30.0.0/16 dir out tmpl src 192.168.62.42 dst 192.168.62.253 proto esp spi 0x007 mode tunnel` |

### companyrouter (inkomend)

| Task                  | Command                                                                                                                                    |
| :-------------------- | :-------------------------------------------------------------------------------- |
| Voeg ESP SA toe       | `ip xfrm state add src 192.168.62.42 dst 192.168.62.253 proto esp spi 0x007 mode tunnel enc aes <KEY1>`                                    |
| Voeg IPsec policy toe | `ip xfrm policy add src 172.10.10.0/24 dst 172.30.0.0/16 dir in tmpl src 192.168.62.42 dst 192.168.62.253 proto esp spi 0x007 mode tunnel` |

---

## 6. IPsec tunnel: companyrouter → homerouter

### Sleutel genereren

| Task                    | Command                          |          |
| :---------------------- | :------------------------------- | -------- |
| Genereer random sleutel | `dd if=/dev/random count=24 bs=1 | xxd -ps` |

---

### companyrouter (uitgaand)

| Task                  | Command                                                                                                                                     |
| :-------------------- | :------------------------------------------------ |
| Voeg ESP SA toe       | `ip xfrm state add src 192.168.62.253 dst 192.168.62.42 proto esp spi 0x008 mode tunnel enc aes <KEY2>`                                     |
| Voeg IPsec policy toe | `ip xfrm policy add src 172.30.0.0/16 dst 172.10.10.0/24 dir out tmpl src 192.168.62.253 dst 192.168.62.42 proto esp spi 0x008 mode tunnel` |

---

### homerouter (forwarded verkeer)

| Task                        | Command                                                                                                                                     |
| :-------------------------- | :------------------------------------------------------------------- |
| Voeg ESP SA toe             | `ip xfrm state add src 192.168.62.253 dst 192.168.62.42 proto esp spi 0x008 mode tunnel enc aes <KEY2>`                                     |
| Voeg IPsec policy toe (fwd) | `ip xfrm policy add src 172.30.0.0/16 dst 172.10.10.0/24 dir fwd tmpl src 192.168.62.253 dst 192.168.62.42 proto esp spi 0x008 mode tunnel` |

---

## 7. IPsec status controleren

| Task                | Command          |
| :------------------ | :--------------- |
| Toon IPsec states   | `ip xfrm state`  |
| Toon IPsec policies | `ip xfrm policy` |

---

## 8. Firewall (companyrouter)

| Task                     | Command                                       |
| :----------------------- | :-------------------------------------------- |
| Firewalld stoppen (test) | `systemctl stop firewalld`                    |
| ESP toestaan             | `firewall-cmd --permanent --add-protocol=esp` |
| Firewall herladen        | `firewall-cmd --reload`                       |

---

## 9. Wireshark – ESP decryptie

| Task                    | Tool                                 |
| :---------------------- | :----------------------------------- |
| ESP-decryptie           | Edit → Preferences → Protocols → ESP |
| SPI + sleutel instellen | Wireshark ESP settings               |

---

# Lesson 9 - VPN

| Task                                          | Command                                                               |
| :-------------------------------------------- | :-------------------------------------------------------------------- |
| **Server software installeren**               | `sudo dnf install --assumeyes openvpn easy-rsa`                       |
| **Check OpenVPN versie**                      | `openvpn --version`                                                   |
| **Check EasyRSA versie**                      | `sudo /usr/share/easy-rsa/3.2.1/easyrsa --version`                    |
| **PKI initialiseren**                         | `sudo /usr/share/easy-rsa/3.2.1/easyrsa init-pki`                     |
| **CA genereren**                              | `sudo /usr/share/easy-rsa/3.2.1/easyrsa build-ca`                     |
| **Server certificate request genereren**      | `sudo /usr/share/easy-rsa/3.2.1/easyrsa gen-req server nopass`        |
| **Server certificate signen**                 | `sudo /usr/share/easy-rsa/3.2.1/easyrsa sign-req server server`       |
| **Client certificate request genereren**      | `sudo /usr/share/easy-rsa/3.2.1/easyrsa gen-req client nopass`        |
| **Client certificate signen**                 | `sudo /usr/share/easy-rsa/3.2.1/easyrsa sign-req client client`       |
| **Diffie-Hellman parameters genereren**       | `sudo /usr/share/easy-rsa/3.2.1/easyrsa gen-dh`                       |
| **Server configuratie openen**                | `sudo vi /home/vagrant/openvpn/server.conf`              |
| **Client configuratie openen**                | `sudo vi /home/vagrant/openvpn/client.conf` *               |
| **Server starten**                            | `sudo openvpn server.conf`                                            |
| **Client starten**                            | `sudo openvpn client.conf`                                            |
| **IP forwarding inschakelen (tijdelijk)**     | `echo 1 > /proc/sys/net/ipv4/ip_forward`                              |
| **IP forwarding permanent**                   | `sysctl -w net.ipv4.ip_forward=1`                                     |
| **NAT instellen**                             | `iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE` |
| **Tunnelinterface controleren**               | `ip a show tun0`                                                      |
| **Ping interne server via VPN**               | `ping 172.30.0.10`                                                    |
| **Certificaat verifiëren (server of client)** | `openssl verify -CAfile ca.crt server.crt`                            |

---
