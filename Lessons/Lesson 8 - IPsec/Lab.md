## Stap 1 – Netwerkopstelling en initiële configuratie

Voor dit labo werden twee routers en één client gebruikt om een externe thuislocatie te simuleren die verbinding maakt met het bedrijfsnetwerk via IPsec.

De **homerouter** heeft twee netwerkinterfaces:

* Een interface op het fake internet (`192.168.62.42`)
* Een interface op het interne thuisnetwerk `employee_home_lan` (`172.10.10.254`)

De **remote_employee** VM is verbonden met `employee_home_lan` en kreeg IP-adres `172.10.10.123` met als default gateway `172.10.10.254`.

Op de **companyrouter** bevindt zich het bedrijfsnetwerk `172.30.0.0/16`.

IP-forwarding werd geactiveerd op de homerouter zodat verkeer tussen beide netwerken kon worden doorgestuurd.

---

## Stap 2 – Routing configureren tussen beide netwerken

Om ervoor te zorgen dat verkeer tussen het thuisnetwerk en het bedrijfsnetwerk rechtstreeks tussen beide routers loopt (en niet via de ISP-router), werden statische routes toegevoegd.

Op de **homerouter**:

```bash
ip route add 172.30.0.0/16 via 192.168.62.253
```

Op de **companyrouter**:

```bash
ip route add 172.10.10.0/24 via 192.168.62.42
```

Na deze configuratie was volledige bidirectionele connectiviteit mogelijk zonder IPsec.

---

## Stap 3 – Verifiëren van basisconnectiviteit

Vooraleer IPsec werd geconfigureerd, werd getest of alle systemen elkaar konden bereiken:

* homerouter → companyrouter
* homerouter → remote_employee
* companyrouter → remote_employee

Alle pings waren succesvol, wat bevestigt dat routing en forwarding correct functioneerden.

---

## Stap 4 – Man-in-the-Middle aanval op het fake internet

Op de VM **red** werd een ARP-spoofing aanval uitgevoerd met `ettercap` om verkeer tussen de homerouter en companyrouter te onderscheppen.

```bash
sudo ettercap -Tq -i eth0 -M arp:remote /192.168.62.42// /192.168.62.253//
```

Met Wireshark werd bevestigd dat ICMP- en HTTP-verkeer in **plaintext** zichtbaar was op het fake internet.

---

## Stap 5 – IPsec tunnel van homerouter naar companyrouter

Eerst werd een **éénrichtings IPsec tunnel** opgezet van de homerouter naar de companyrouter.

Op **beide routers** werden bestaande IPsec configuraties verwijderd:

```bash
ip xfrm policy flush
ip xfrm state flush
```

Op de **homerouter** werd een Security Association en Security Policy aangemaakt met `dir out`, zodat uitgaand verkeer van `172.10.10.0/24` naar `172.30.0.0/16` werd versleuteld.

Op de **companyrouter** werd een overeenkomstige policy aangemaakt met `dir in` om dit verkeer correct te kunnen ontvangen en ontsleutelen.

Na deze stap waren **echo requests versleuteld**, maar **echo replies nog in plaintext**, wat zichtbaar was in Wireshark.

---

## Stap 6 – Probleemanalyse: geen verkeer van remote_employee

Hoewel de homerouter beide netwerken kon bereiken, lukte communicatie vanuit de remote_employee niet. Dit ondanks correcte routing en firewallinstellingen.

Tests toonden aan dat:

* companyrouter → remote_employee werkte
* homerouter → remote_employee werkte
* remote_employee → companynetwerk faalde

Hieruit werd geconcludeerd dat het probleem **niet bij routing**, maar bij **IPsec policy matching** lag.

---

## Stap 7 – Tweede IPsec tunnel (companyrouter → homerouter)

Omdat IPsec **directioneel** werkt, werd een tweede tunnel opgezet voor verkeer van het bedrijfsnetwerk naar het thuisnetwerk.

Op de **companyrouter**:

* Een nieuwe Security Association werd aangemaakt
* Een Security Policy met `dir out` voor verkeer van `172.30.0.0/16` naar `172.10.10.0/24`

Op de **homerouter**:

* Dezelfde SA werd toegevoegd
* De Security Policy werd ingesteld met **`dir fwd`**

Dit is noodzakelijk omdat het verkeer **niet voor de homerouter zelf bestemd is**, maar wordt doorgestuurd naar de remote_employee.

---

## Stap 8 – Eindresultaat en verificatie

Na het toevoegen van de tweede tunnel:

* Kon de remote_employee succesvol pingen naar systemen in het bedrijfsnetwerk
* Kon HTTP-verkeer worden opgezet naar de webserver
* Was alle verkeer op het fake internet enkel zichtbaar als **ESP-pakketten**

Wireshark toonde geen leesbare ICMP- of HTTP-data meer, wat bevestigt dat de IPsec tunnel in beide richtingen correct werkte.

---

## Stap 9 – Conclusie

Dit labo toont aan dat IPsec manueel kan worden opgezet zonder IKE, maar dat correcte **policy-richtingen (`out`, `in`, `fwd`) cruciaal zijn**.
Hoewel routing volledig correct was, zorgde een foutieve policy-richting ervoor dat verkeer werd gedropt.

Na het configureren van twee afzonderlijke, directionele IPsec tunnels werd veilige, versleutelde communicatie tussen het thuisnetwerk en het bedrijfsnetwerk gerealiseerd.
