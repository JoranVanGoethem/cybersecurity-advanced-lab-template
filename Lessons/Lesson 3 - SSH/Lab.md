Perfect 👍
Below is the **same lab report**, but **adapted specifically for a Windows client**.
It is still **exam-proof**, **critical**, and **ready to paste** into your lab report.

I assume:

* Windows 10/11
* **Built-in OpenSSH client** (via PowerShell)
* No GUI usage on servers (only SSH)

---

# Lab – SSH Client Configuration & SSH Port Forwarding (Windows Client)

## 1. Objective

The goal of this lab is to:

* Configure SSH access from a **Windows client** to all machines in the network
* Use the **company router as an SSH bastion (jump host)**
* Authenticate using **SSH key-based authentication**
* Perform **SSH port forwarding** to access internal services
* Critically evaluate the **security implications**

---

## 2. Network Overview

* **Client**: Windows 10/11 (fake internet)
* **Company router**: SSH bastion
  IP: `192.168.62.254`
* **Webserver**: `172.30.0.10`
* **Database server**: Internal, firewall protected
* **Firewall**: Enabled, blocks direct access to internal machines

---

## 3. SSH Client Configuration on Windows

### 3.1 OpenSSH on Windows

Windows 10/11 includes OpenSSH by default.

Verification in **PowerShell**:

```powershell
ssh -V
```

---

### 3.2 SSH Key Generation (Windows)

Keys are stored in:

```
C:\Users\<username>\.ssh\
```

Generate a key pair:

```powershell
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_company
```

Resulting files:

* `id_company` → **private key (Windows client only)**
* `id_company.pub` → public key

---

### 3.3 Public Key Distribution

Public key copied to each Linux VM:

```powershell
ssh-copy-id -i $env:USERPROFILE\.ssh\id_company.pub vagrant@192.168.62.254
```

For internal machines (via bastion):

```powershell
ssh -J vagrant@192.168.62.254 vagrant@172.30.0.10
ssh-copy-id vagrant@172.30.0.10
```

**Files transferred:**

| File             | From           | To                                         |
| ---------------- | -------------- | ------------------------------------------ |
| `id_company.pub` | Windows client | `~/.ssh/authorized_keys` on Linux machines |

---

### 3.4 SSH Client Config (Windows)

File location:

```
C:\Users\<username>\.ssh\config
```

Contents:

```ini
Host companyrouter
    HostName 192.168.62.253
    Port 2222
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity

Host isprouter
    HostName 192.168.62.254
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity

Host homerouter
    HostName 192.168.62.42
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity

Host web
    HostName 172.30.0.10
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity
    ProxyJump companyrouter

Host database
    HostName 172.30.0.15
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity
    ProxyJump companyrouter

Host dns
    HostName 172.30.0.4
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity
    ProxyJump companyrouter

Host employee
    HostName 172.30.0.123
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity
    ProxyJump companyrouter

Host siem
    HostName 172.30.0.20
    User vagrant
    IdentityFile ~/.ssh/id_Cybersecurity
    ProxyJump router

Host remote_employee
    HostName 172.10.10.123
    User vagrant
    IdentityFile ~/.ssh/id_company
    ProxyJump companyrouter,homerouter
```

Usage from PowerShell:

```powershell
ssh router
ssh web
ssh db
```

---

## 4. Firewall Requirements

To keep the firewall **enabled** while allowing SSH access:

* Allow **TCP/22** to the **company router**
* Allow SSH from **router → internal network**
* Block all direct inbound SSH to internal servers

This enforces a **single controlled entry point**.

---

## 5. Security Evaluation (Critical Reflection)

### Is this secure?

**Advantages**

* No password authentication
* Centralized access via bastion
* Reduced attack surface
* Easy logging and monitoring

**Disadvantages**

* Bastion is a single point of failure
* Key compromise grants wide access
* Requires strict router hardening

Conclusion:
This method is secure **only when the bastion host is properly hardened** (updates, logging, limited users).

---

## 6. SSH Port Forwarding (Windows)

### 6.1 Why SSH Port Forwarding Matters

* Encrypted access to internal services
* No firewall changes needed
* Common in red, blue and purple teaming

---

## 7. Local vs Remote Port Forwarding

### Local Port Forwarding (`-L`)

Used when **the Windows client needs access** to a remote service.

```powershell
ssh -L local_port:target:target_port user@host
```

### Remote Port Forwarding (`-R`)

Used when **external users need access** to internal services.

```powershell
ssh -R remote_port:target:target_port user@host
```

➡️ **Local forwarding is more common and safer**

---

## 8. Practical Examples (Windows)

### Example 1 – View Webserver from Windows Browser

```powershell
ssh -L 8080:172.30.0.10:80 router
```

Open browser:

```
http://localhost:8080
```

---

### Example 2 – Access Database from Windows

```powershell
ssh -L 3306:172.30.0.20:3306 router
```

Then:

```powershell
mysql -h 127.0.0.1 -P 3306 -u dbuser -p
```

---

### Example 3 – Web + Database in One Command

```powershell
ssh -L 8080:172.30.0.10:80 -L 3306:172.30.0.20:3306 router
```

---

## 9. Using `-J` (ProxyJump) from Windows

```powershell
ssh -J router vagrant@172.30.0.10
```

No routes required on the Windows client.

---

## 10. Poor Man’s VPN

SSH tunneling:

* Encrypts traffic
* Bypasses routing and firewall limits
* No VPN infrastructure needed

Limitations:

* Manual setup
* No automatic routing
* No split tunneling

---
