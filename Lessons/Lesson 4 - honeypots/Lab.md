# Lab – Honeypots with Cowrie

## Introduction

In this lab, a SSH honeypot was deployed using **Cowrie** on the `companyrouter`. A honeypot is a deliberately exposed system designed to attract attackers in order to observe their behavior, techniques, and tools. By logging all interactions, defenders can gain insight into attack patterns without exposing real services.

---

## 1. Why configure a SSH honeypot on the companyrouter?

### Why it is interesting

The **companyrouter** is an attractive target because:

* It is **internet-facing** and acts as a gateway between networks.
* Routers are commonly targeted for:

  * Credential brute-forcing
  * Pivoting into internal networks
* Attackers expect routers to expose SSH on **port 22**, making it an ideal decoy.

This makes the router a high-value observation point for detecting early-stage attacks.

### Argument against using a honeypot on a router

A strong argument **against** deploying a honeypot on a router:

* A router is **critical infrastructure**
* Running extra services:

  * Increases attack surface
  * Consumes system resources
  * Can introduce stability or security risks
* If the honeypot is misconfigured, it could potentially be abused as a pivot point

In production environments, honeypots are often better isolated on separate systems or VLANs.

---

## 2. Changing the SSH daemon port

To prevent attackers from reaching the real SSH service, the SSH daemon was moved from port **22** to **2222**.

### Steps

1. Edit the SSH daemon configuration:

```bash
sudo vi /etc/ssh/sshd_config
```

2. Change:

```text
Port 22
```

to:

```text
Port 2222
```

3. Restart SSH:

```bash
sudo systemctl restart sshd
```

4. Verify:

```bash
ss -tulpn | grep ssh
```

The real SSH service now listens on port **2222**.

---

## 3. Installing and running Cowrie (SSH honeypot)

To deploy the SSH honeypot, **Cowrie** was installed on the `companyrouter` using **Docker**. Docker was chosen because it allows fast deployment, isolation from the host system, and easy cleanup after the lab.

### Prerequisites

Before installing Cowrie, the real SSH service was moved from port **22** to **2222** to prevent interference between the honeypot and the actual SSH daemon.

---

### Step 1 – Install Docker

Docker was installed using the system package manager:

```bash
sudo dnf install -y docker
```

The Docker service was enabled and started:

```bash
sudo systemctl enable --now docker
```

The installation was verified:

```bash
docker --version
```

---

### Step 2 – Download the Cowrie Docker image

The official Cowrie image was pulled from Docker Hub:

```bash
docker pull cowrie/cowrie
```

---

### Step 3 – Create persistent storage directories

Directories were created on the host system to store Cowrie configuration files and logs:

```bash
mkdir -p /opt/cowrie/{etc,var}
```

This ensures logs are preserved even if the container is restarted or removed.

---

### Step 4 – Run Cowrie on port 22

Cowrie was started as a Docker container and bound to port **22**, the default SSH port:

```bash
docker run -p 2222:22 cowrie/cowrie:latest
```

This configuration redirects incoming SSH connections on port 22 to the Cowrie honeypot inside the container.

---

### Step 5 – Verify Cowrie is running

The container status was checked:

```bash
docker ps
```

Container logs were inspected to confirm successful startup:

```bash
docker logs cowrie
```

---

### Step 6 – Verify SSH access

* Legitimate SSH access was tested using:

```bash
ssh -p 2222 user@companyrouter
```

* Attacker behavior was simulated by connecting normally:

```bash
ssh user@companyrouter
```

Connections on port 22 were handled by Cowrie, while port 2222 provided access to the real system.

---

### Step 7 – Log files

Cowrie logs were stored in:

```bash
/opt/cowrie/var/log/cowrie/
```

Important files include:

* `cowrie.log` – readable event logs
* `cowrie.json` – structured logs for SIEM usage
* `tty/` – full session replays of attacker activity


Cowrie was installed and configured to listen on **port 22**, impersonating a real SSH service.

Cowrie simulates:

* SSH login prompts
* A fake filesystem
* A fake shell environment

This ensures attackers interact with the honeypot instead of the real system.

---

## 4. Verifying legitimate SSH access

SSH access to the router was tested using:

```bash
ssh -p 2222 vagrant@companyrouter

```

Result:

* Login works as expected
* The real system remains accessible only on port 2222

---

## 5. Attacking the router (port 22)

When attempting to SSH normally:

```bash
ssh root@companyrouter
password: admin
```

### Observations

* The SSH banner appears legitimate
* Login attempts are accepted by Cowrie
* The attacker is **not** connected to the real router

---

## 6. Credentials and shell behavior

### Credentials

* Cowrie accepts **many credentials**, even weak ones (e.g. `root:root`)
* Some credentials are rejected depending on configuration
* This behavior is intentional to observe brute-force attempts

### Shell access

* A shell is provided, but:

  * It is **fake**
  * Commands do not affect the real system
  * Output is simulated

---

## 7. Logging and monitoring

### Are commands logged?

Yes

Cowrie logs:

* Source IP address
* Username and password attempts
* All executed commands
* Session timing

### Log file locations

Common log files:

```text
cowrie/log/cowrie.log
cowrie/log/cowrie.json
cowrie/log/tty/
```

* `cowrie.log` → human-readable logs
* `cowrie.json` → structured logs (useful for SIEM)
* `tty/` → full session replays

---

## 8. Can an attacker perform malicious actions?

No real damage is possible.

Attackers:

* Cannot modify the real filesystem
* Cannot install malware
* Cannot pivot to other systems

All actions are **sandboxed and simulated**.

---

## 9. Detecting the honeypot (attacker perspective)

An experienced attacker might notice:

* Commands behave slightly differently
* System information is unrealistic or static
* Network tools do not work properly
* No persistence after logout
* Identical filesystem across sessions

These are common honeypot indicators.

---

# Critical Thinking – Docker as a Service

## Advantages of running services in Docker

1. **Isolation**

   * Services run separately from the host OS
2. **Easy deployment**

   * Fast setup, reproducible environments
3. **Portability**

   * Same container runs everywhere

## Disadvantage

* If Docker daemon is compromised, the **host system is at risk**
* Containers share the host kernel

---

## Docker client-server architecture

Docker uses:

* A **client** (`docker` command)
* A **server/daemon** (`dockerd`)

The client sends API requests to the daemon, which:

* Builds images
* Runs containers
* Manages volumes and networks

---

## Docker daemon user

By default, the Docker daemon runs as:

```text
root
```

This is why access to Docker equals **root-level access**.

---

## VM vs Container for honeypots

### Advantage of a VM

* Stronger isolation
* Separate kernel
* Harder to escape
* More realistic environment for attackers

For honeypots, **VMs are generally safer**.

---

# Docker Deepdive – Portainer and docker.sock

## Why is docker.sock mounted?

Portainer needs access to:

```text
/var/run/docker.sock
```

to manage Docker:

* Start/stop containers
* View logs
* Create networks and volumes

---

## What is docker.sock?

* A Unix socket
* Provides direct access to the Docker API
* Acts as a control interface for the Docker daemon

---

## Security implications

Mounting `docker.sock` allows:

* Full control over Docker
* Container breakout
* Root access to the host

⚠️ If compromised, an attacker can fully control the system.

---

# Other Honeypots

## Honeyup

* **Low-interaction honeypot**
* Emulates vulnerable services (FTP, HTTP, etc.)

---

## OpenCanary

* **Multi-service honeypot**
* Simulates:

  * SSH
  * HTTP
  * SMB
  * DNS
* Designed for easy deployment and alerting

---

## Is a HTTP(S) honeypot a good idea?

✅ Yes, because:

* Web services are frequently attacked
* Can capture:

  * SQL injection
  * Command injection
  * XSS payloads

❌ Downside:

* Needs good logging
* Risk of exposing real backend logic if misconfigured

---

## /cmd endpoint as a honeypot

### How to retrieve commands?

* Log form input to:

  * Application logs
  * Database
  * SIEM
* Add timestamps and IP addresses

### Is this feasible?

✅ Yes

* Very easy to implement
* Low risk
* Valuable insight into attacker behavior

---

## Conclusion

This lab demonstrated how a SSH honeypot can be used to safely observe attacker behavior. By relocating the real SSH service and deploying Cowrie on port 22, attackers are deceived while defenders gain valuable intelligence. Honeypots are powerful defensive tools when properly isolated and monitored.
