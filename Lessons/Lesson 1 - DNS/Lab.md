# Wireshark

## - What layers of the OSI model are captured in this capturefile?
the network layer and the data link layer.

## - Take a look at the conversations. What do you notice?
its mostly ssh requests

## - Take a look at the protocol hierarchy. What are the most "interesting" protocols listed here?
ipv4, ssh, tcp 

## - Can you spot an SSH session that got established between 2 machines? List the 2 machines. Who was the SSH server and who was the client? What ports were used? Are these ports TCP or UDP?
172.30.42.2	
172.30.128.10, they are tcp

## - Some cleartext data was transferred between two machines. Can you spot the data? Can you deduce what happened here?


## - Someone used a specific way to transfer a png on the wire. Is it possible to export this png easily? Is it possible to export other HTTP related stuff?
172.30.42.2	 asked for a png from this link: http://www.insecure.cyb/icons/poweredby.png

# Capture traffic using the CLI

`sudo dnf install tcpdump`

## - Have a look at the ip configurations of the dns machine, the employee client and the companyrouter.

## - Which interface on the companyrouter will you use to capture traffic from the dns to the internet?

eth1, connected to the fake internet

## - Which interface on the companyrouter would you use to capture traffic from dns to employee?

eth2, connected to the internal network

## - Test this out by pinging from employee to the companyrouter and from employee to the dns. Are you able to see all pings in tcpdump on the companyrouter?

```console
[vagrant@companyrouter ~]$ sudo tcpdump -i eth2 host 172.30.0.123
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:46:29.670285 IP 172.30.0.123 > companyrouter: ICMP echo request, id 8, seq 14, length 64
16:46:29.670304 IP companyrouter > 172.30.0.123: ICMP echo reply, id 8, seq 14, length 64
16:46:29.670736 IP 172.30.0.123.ssh > companyrouter.50710: Flags [P.], seq 2407173661:2407173725, ack 338335083, win 2003, options [nop,nop,TS val 559203397 ecr 3807291413], length 64

```

## - Figure out a way to capture the data in a file. Copy this file from the companyrouter to your host and verify you can analyze this file with wireshark (on your host).

<!-- help needed -->

## - SSH from employee to the companyrouter. When scanning with tcpdump you will now see a lot of SSH traffic passing by. How can you start tcpdump and filter out this ssh traffic?

`sudo tcpdump -i eth2 tcp port 22 and host 172.30.0.123`

## - Start the web VM. Find a way to capture only HTTP traffic and only from and to the webserver-machine. Test this out by browsing to http://www.cybersec.internal from the isprouter machine using curl. This is a website that should be available in the lab environment. Are you able to see this HTTP traffic? Browse on the employee client, are you able to see the same HTTP traffic in tcpdump, why is this the case?

`weizig host file zodat 172.30.0.10 verwijst naar www.cybersec.internal`

## - Did you notice the website is using HTTP? In a future lab you will be tasked with configuring HTTPS.

# Understanding the network

## - What did you have to configure on your red machine to have internet and to properly ping the web machine (is the ping working on IP only or also on hostname)?

1. host adapter een ip adres geven:
```console
sudo ip addr add 192.168.62.10/24 dev eth1
sudo ip route add default via 192.168.62.1
```
2. default route naar 172.30.0.0/16 netwerk insteken via companyrouter
`sudo ip route add 172.30.0.0/16 via 192.168.62.253`

2. default route naar 172.10.0.0/24 netwerk insteken via homerouter
`sudo ip route add 172.10.0.0/24 via 192.168.62.42`

## - What is the default gateway of each machine?

## - What is the DNS server of each machine?

## - Which machines have a static IP and which use DHCP?

## - If you visualise all machines for this course, how many actual networks are there?

1. company network
2. home network
3. red network

## - What (static) routes should be configured and where, how do you make it persistent?

## - What is the purpose (which processes or packages for example are essential) of each machine?

## - Investigate whether the DNS server of the company network is vulnerable to a DNS zone transfer "attack" as discussed above. What exactly does this attack involve? If possible, try to change the configuration multiple times in such a way that you know and understand when the server will allow or prevent this "attack". Document this update: How can you execute this attack or check if the DNS server is vulnerable and how can you fix it? Can you perform this "attack" both on Windows and Linux? Document your findings properly.