# HTTPS Configuration Using OpenSSL

## TLS 1.2 and TLS 1.3 – Manual PKI Setup

---

## 1. Introduction

In this lab, HTTPS is configured manually using OpenSSL without any automation tools such as Certbot or Let’s Encrypt. A custom **Certificate Authority (CA)** is created on the **isprouter**, which is assumed to be a trusted entity within the internal network.
The CA issues a certificate for the **webserver**, allowing clients to browse the website over HTTPS without browser warnings once the CA certificate is trusted.

Two HTTPS configurations are demonstrated:

* **TLS 1.2 with RSA (insecure, decryptable)**
* **TLS 1.3 with Perfect Forward Secrecy (secure)**

Traffic is captured and analyzed using **Wireshark**.

---

## 2. Theory Overview

### 2.1 Certificates and PKI

A certificate binds a **public key** to an identity (hostname or IP) and is digitally signed by a **Certificate Authority**. Clients trust the CA certificate and therefore trust certificates signed by it.

### 2.2 Asymmetric Encryption in TLS

* The server owns a **private key**
* The public key is distributed via the certificate
* Asymmetric cryptography is used during the TLS handshake
* Symmetric keys are used for actual data transfer

---

## 3. Lab Topology and Roles

| Role                  | Machine    | IP Address          |
| --------------------- | ---------- | ------------------- |
| Certificate Authority | isprouter  | 192.168.62.254      |
| Webserver             | webserver  | 172.30.0.10         |
| Client                | Browser VM | (client network IP) |

---

## 4. Certificate Authority Setup

📍 **Executed on: isprouter (192.168.62.254)**

### 4.1 Generate CA private key

```bash
openssl genrsa -out ca.key 4096
```

**Explanation:**
Creates the private key of the Certificate Authority. This key is used to sign certificates and must remain secret.

---

### 4.2 Create CA certificate (self‑signed)

```bash
openssl req -x509 -new -nodes \
  -key ca.key \
  -sha256 \
  -days 3650 \
  -out ca.crt
```

**Explanation:**
Creates the CA certificate. This certificate will be imported into client browsers to establish trust.

---

## 5. Webserver Certificate Creation

📍 **Executed on: webserver (172.30.0.10)**

### 5.1 Generate webserver private key

```bash
openssl genrsa -out webserver.key 2048
```

**Explanation:**
Creates the private key of the webserver, used during TLS handshakes.

---

### 5.2 Create OpenSSL config with SAN (`webserver.cnf`)

```ini
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[ dn ]
CN = cybersec.internal

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = cybersec.internal
DNS.2 = www.cybersec.internal
IP.1  = 172.30.0.10
```

**Explanation:**
Defines the identity of the webserver and the Subject Alternative Names (SAN), which modern browsers require.

---

### 5.3 Create Certificate Signing Request (CSR)

```bash
openssl req -new \
  -key webserver.key \
  -out webserver.csr \
  -config webserver.cnf
```

**Explanation:**
Creates a CSR containing the webserver’s public key and identity. The CSR is sent to the CA for signing.

---

### 5.4 Copy CSR to CA

```bash
scp webserver.csr user@192.168.62.254:/root/
```

---

## 6. Certificate Signing by CA

📍 **Executed on: isprouter**

```bash
openssl x509 -req \
  -in webserver.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out webserver.crt \
  -days 825 \
  -sha256 \
  -extensions req_ext \
  -extfile webserver.cnf
```

**Explanation:**
The CA signs the CSR, producing a valid server certificate.

---

### 6.1 Copy certificate back to webserver

```bash
scp webserver.crt user@172.30.0.10:/etc/ssl/
scp ca.crt user@172.30.0.10:/etc/ssl/
```

---

## 7. HTTPS Configuration on Webserver

### 7.1 Enable HTTPS

📍 **Executed on: webserver**

Apache example:

```apache
<VirtualHost *:443>
  ServerName cybersec.internal

  SSLEngine on
  SSLCertificateFile /etc/ssl/webserver.crt
  SSLCertificateKeyFile /etc/ssl/webserver.key
  SSLCACertificateFile /etc/ssl/ca.crt

  DocumentRoot /var/www/html
</VirtualHost>
```

---

## 8. Client Trust Configuration

📍 **Executed on: Client machine**

### 8.1 Import CA certificate

* Import `ca.crt` into:

  * Browser **Trusted Root Authorities**
  * or OS trust store

**Result:**
The website opens over HTTPS **without warnings**.

---

## 9. TLS 1.2 Configuration (Insecure Demo)

📍 **Executed on: webserver**

```apache
SSLProtocol TLSv1.2
SSLCipherSuite RSA+AES256-SHA
SSLHonorCipherOrder on
```

**Explanation:**

* Forces TLS 1.2
* Uses RSA key exchange
* Disables Perfect Forward Secrecy

---

## 10. TLS 1.2 Wireshark Decryption

📍 **Executed on: Client**

### Required file:

* `webserver.key`

### Wireshark setup:

1. Preferences → TLS
2. RSA Keys List:

   * IP: `172.30.0.10`
   * Port: `443`
   * Protocol: `http`
   * Key file: `webserver.key`
3. Reload capture

**Result:**
HTTP traffic is visible after decryption.

---

## 11. TLS 1.3 Configuration (Secure)

📍 **Executed on: webserver**

```apache
SSLProtocol TLSv1.3
SSLCipherSuite TLS_AES_256_GCM_SHA384
```

**Explanation:**
TLS 1.3 enforces Perfect Forward Secrecy using Diffie‑Hellman key exchange.

---

## 12. Why TLS 1.3 Cannot Be Decrypted

* Session keys are ephemeral
* Server private key cannot decrypt traffic
* Passive capture is useless

---

## 13. SSLKEYLOGFILE Decryption Method

📍 **Executed on: Client**

```bash
export SSLKEYLOGFILE=/home/user/sslkeys.log
firefox
```

1. Browse HTTPS website
2. Capture traffic
3. Close browser
4. Copy `sslkeys.log`
5. Load it in Wireshark:

   * Preferences → TLS → (Pre)-Master‑Secret log file

**Result:**
TLS 1.3 traffic is decrypted.

---

## 14. Security Considerations

* TLS 1.2 without PFS is insecure
* TLS 1.3 protects past sessions
* SSLKEYLOGFILE requires endpoint access
* CA private key must never be exposed

## Optional extra: Create https://services.cybersec.internal¶
Change the DNS settings of the DNS server to support services.cybersec.internal being redirected to the webserver. Change the configuration of the webserver in such a way that https://services.cybersec.internal (note the "s" of HTTPS!) is fully operational. This means you see the same as browsing to https://www.cybersec.internal/services.