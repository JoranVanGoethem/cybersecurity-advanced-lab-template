```
Your passphrase (between double-quotes): "vagrant"
Make sure the passphrase displayed above is exactly what you wanted.

By default repositories initialized with this version will produce security
errors if written to with an older version (up to and including Borg 1.0.8).

If you want to use these older versions, you can disable the check by running:
borg upgrade --disable-tam ssh://vagrant@172.30.0.15/home/vagrant/backups

See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
If you used a repokey mode, the key is stored in the repo, but you should back it up separately.
Use "borg key export" to export the key, optionally in printable format.
Write down the passphrase. Store both at safe place(s).
```

```
borg create \
  vagrant@172.30.0.15:/home/vagrant/backups::first \
  /home/vagrant/important-files
```

## 8. 

With which bash command can you see the size of the folder with the files on the webserver? How big is that folder? Tip: try with and without the --si option. Which corresponds with the output of borg? Where do you find this in the BorgBackup documentation?

```
[vagrant@web important-files]$ du -h
1.7M    .
[vagrant@web important-files]$ du -h --si
1.8M    .
```

Difference between -h and --si
Option	Unit system	Example
-h	Binary (base 2)	KiB, MiB
--si	Decimal (base 10)	kB, MB


Now check the size of the backups folder on the database server.
```

database:~/backups/data$ du -h  /home/vagrant/backups
1.7M    /home/vagrant/backups/data/0
1.7M    /home/vagrant/backups/data
1.8M    /home/vagrant/backups
```

What is the difference between Original size, Compressed size and Deduplicated size? Can you link this with the sizes you found of the folders on the web and db VM's? Make sure you comprehend this!

Original size
- Size of files before any compression or deduplication

Roughly equals:

`du -h --si`
- Represents “what the data logically is”

Compressed size
- Size after compression

Borg compresses chunks (e.g. LZ4, ZSTD)
- Smaller than original size
- Still counts duplicate data

Deduplicated size
- Size of new data actually stored
- Already-existing chunks are not stored again
- This is the size that really matters for disk usage on db

What are chunks?

Chunks are the foundation of BorgBackup.

Definition

A chunk is:
- A small, variable-sized block of data created from your files.

Borg:
- Splits files into chunks
- Hashes each chunk
- Stores each chunk only once

Why chunks matter

If a file changes slightly:
- Only some chunks change
- The rest are reused

Enables:
- Deduplication
- Incremental backups
- Efficient storage

Example:
```
File v1 → chunks A B C D
File v2 → chunks A B X D
```
- Only chunk X is stored again.

## 9. To periodically check the **integrity of a Borg repository**, you use the **`borg check`** command.

---

## Command to check repository integrity

Basic integrity check (recommended regularly):

```bash
borg check vagrant@172.30.0.15:/home/vagrant/backups
```

What this does:

* Checks repository structure
* Verifies indexes and metadata
* Detects corruption in the repo layout
* **Fast and safe** for regular use

---

## Using `--verbose` for more information

```bash
borg check --verbose vagrant@172.30.0.15:/home/vagrant/backups

Remote: Starting repository check
Remote: finished segment check at segment 9
Remote: Starting repository index check
Starting archive consistency check...
Remote: Index object count match.
Remote: Finished full repository check, no problems found.
Enter passphrase for key ssh://vagrant@172.30.0.15/home/vagrant/backups:
Analyzing archive first (1/2)
Analyzing archive second (2/2)
Archive consistency check complete, no problems found.
```

This shows:

* Which checks are being performed
* Progress information
* Repository and archive consistency steps

---

## When to use `--verify-data`

```bash
borg check --verify-data --verbose vagrant@172.30.0.15:/home/vagrant/backups

Remote: Starting repository check
Remote: finished segment check at segment 9
Remote: Starting repository index check
Remote: Index object count match.
Remote: Finished full repository check, no problems found.
Starting archive consistency check...
Enter passphrase for key ssh://vagrant@172.30.0.15/home/vagrant/backups:
Starting cryptographic data integrity verification...
Finished cryptographic data integrity verification, verified 10 chunks with 0 integrity errors.
Analyzing archive first (1/2)
Analyzing archive second (2/2)
Archive consistency check complete, no problems found.

```

### What `--verify-data` does

* Reads **all stored data chunks**
* Verifies cryptographic hashes
* Detects **silent data corruption** (bit rot)

### Important characteristics

| Aspect    | Normal `borg check` | `--verify-data` |
| --------- | ------------------- | --------------- |
| Speed     | Fast                | Very slow       |
| Disk I/O  | Low                 | Very high       |
| CPU usage | Moderate            | High            |
| Data read | Metadata only       | **All data**    |

---

## When should you use `--verify-data`?

Use it **only occasionally**, for example:

* After disk or filesystem errors
* After hardware issues (bad RAM, failing disk)
* After restoring a repository from another backup
* Periodically (e.g. **once every few months**)

**Do NOT run it frequently** on large repositories.

---

## 10. Delete the original files on web.

```bash
[vagrant@web ~]$ rm --recursive --verbose important-files/
removed 'important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4'
removed 'important-files/Toreador_song_cleaned.ogg'
removed 'important-files/100.txt'
removed 'important-files/996.txt'
removed 'important-files/test.txt'
removed directory 'important-files/'
```

## 11. restore the og files

Restore the original files using the first backup on the database server (without the test.txt file) to the same place on web so it seems like nothing has happened. --strip-elements may come in handy here as borg uses absolute paths inside backups. You should see a similar output after restoring the backup:

```bash
borg extract \
  --verbose \
  --strip-components 2 \
  vagrant@172.30.0.15:/home/vagrant/backups::first \
  ~/important-files
Enter passphrase for key ssh://vagrant@172.30.0.15/home/vagrant/backups:
[vagrant@web ~]$ ls
borg-keyfile.txt  important-files
```

```bash

[vagrant@web ~]$ ll important-files/
total 1708
-rw-r--r--. 1 vagrant vagrant     300 Jan  7 11:20 100.txt
-rw-r--r--. 1 vagrant vagrant     300 Jan  7 11:20 996.txt
-rw-r--r--. 1 vagrant vagrant   36196 Jan  7 11:20 bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
-rw-r--r--. 1 vagrant vagrant 1702187 Jan  7 11:20 Toreador_song_cleaned.ogg

```

## 12 retention policy

### 1. Automating Borg backups (every 5 minutes)

## Approach

* Use a **script** that:

  1. Creates a backup
  2. Applies a retention policy (`borg prune`)
  3. Frees space (`borg compact`)
* Use a **systemd service + timer** to run it every 5 minutes

This is **preferred over cron** in modern Linux systems.

---

### 2. Backup script

Create the script on the **webserver**:

```bash
sudo vi /usr/local/bin/borg-backup.sh
```

### Script contents

```bash
#!/bin/bash
set -e

export BORG_REPO="vagrant@172.30.0.15:/home/vagrant/backups"
export BORG_PASSPHRASE="vagrant"

BACKUP_SOURCE="~/important-files"

borg create \
  --stats \
  --compression lz4 \
  ::'{now:%Y-%m-%d_%H:%M}' \
  "$BACKUP_SOURCE"

borg prune \
  --verbose \
  --keep-minute=12 \
  --keep-hourly=24 \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=6

borg compact
```

Make it executable:

```bash
sudo chmod +x /usr/local/bin/borg-backup.sh
```

---

### 3. Retention policy explained (this is important)

### Retention policy used

This is a **time-based policy**, inspired by **Grandfather-Father-Son (GFS)**:

| Level       | Meaning              | Setting                               |
| ----------- | -------------------- | ------------------------------------- |
| Son         | Frequent, short-term | `--keep-minute=12` (last hour)        |
| Father      | Medium-term          | `--keep-hourly=24`, `--keep-daily=7`  |
| Grandfather | Long-term            | `--keep-weekly=4`, `--keep-monthly=6` |

### In words

* Keep **every 5-minute backup for 1 hour**
* Keep **hourly backups for 1 day**
* Keep **daily backups for 1 week**
* Keep **weekly backups for 1 month**
* Keep **monthly backups for 6 months**

This **is** a modern variant of the **GFS policy**.

---

### 4. What is the Grandfather–Father–Son policy?

Yes — this is a **classic backup strategy**.

### Concept

| Generation  | Frequency        | Retention |
| ----------- | ---------------- | --------- |
| Son         | Very frequent    | Short     |
| Father      | Daily            | Medium    |
| Grandfather | Weekly / Monthly | Long      |

### Why it’s good

* Fine-grained recent recovery
* Long-term historical recovery
* Storage-efficient

Borg implements this via **time-based pruning**, not physical tape rotation.

---

### 5. systemd service

Create the service unit:

```bash
sudo vi /etc/systemd/system/borg-backup.service
```

```ini
[Unit]
Description=Borg Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/borg-backup.sh
```

---

### 6. systemd timer (every 5 minutes)

Create the timer:

```bash
sudo vi /etc/systemd/system/borg-backup.timer
```

```ini
[Unit]
Description=Run Borg backup every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```

Enable it:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now borg-backup.timer

Created symlink /etc/systemd/system/timers.target.wants/borg-backup.timer → /etc/systemd/system/borg-backup.timer.
```

Check status:

```bash
systemctl list-timers | grep borg

Wed 2026-01-07 12:46:43 UTC 4min 51s left Wed 2026-01-07 12:41:43 UTC 8s ago       borg-backup.timer            borg-backup.service
```

---

### 7. What does `borg compact` do?

### Short answer

> `borg compact` **frees disk space** in the repository.

### Long answer

* When archives are deleted (via `borg prune`)
* Some chunks become **unreferenced**
* These chunks are not removed immediately
* `borg compact`:

  * Rewrites repository segments
  * Removes unused data
  * Reduces actual disk usage

### Analogy

* `borg prune` = deletes references
* `borg compact` = empties the trash

### When to run it

* After pruning
* Periodically
* Often combined with prune in scripts (as above)

---
Here’s a careful breakdown of all parts of your brain teaser. I’ll go **step by step** and explain the reasoning, based on the Borg documentation and best practices.

---

## 1. Can you use Borg to backup an **active database**?

**Short answer:** Not safely by default.

### Why not

From the Borg documentation:

> “Borg does not know how to deal with files that are actively changing during a backup. If files change while Borg is reading them, the backup may contain inconsistent data.”
> [BorgBackup Docs – Important note about files changing during the backup process](https://borgbackup.readthedocs.io/en/stable/quickstart.html#important-note-about-files-changing-during-the-backup-process)

Databases (like MySQL, PostgreSQL, MariaDB, etc.) are **constantly writing to their files** while running.

* If Borg reads the database files directly while they are being modified:

  * Some pages may be backed up **before a write**
  * Some pages may be backed up **after a write**
  * This can result in a **corrupt or inconsistent backup** that cannot be restored reliably.

---

### Extra measures for safe backup of active databases

1. **Database-native dump**

   * Use tools like:

     ```bash
     mysqldump
     pg_dump
     ```
   * Dump the database to a static file, then back up the dump with Borg.
     ✅ Safe and consistent.

2. **Database snapshot / freeze**

   * Some databases support filesystem snapshots or LVM snapshots.
   * Freeze writes, snapshot the data files, then back up the snapshot with Borg.

3. **Hot backup with WAL / journaling**

   * Backup data files **and** transaction logs
   * Reconstruct database during restore
   * More advanced; usually requires DBA knowledge

---

**Conclusion:**
You **should not** back up raw database files directly with Borg while the database is running, unless you use a snapshot mechanism. Instead, dump the database or take a snapshot.

---

## 2. What is **Borgmatic**?

[Borgmatic](https://torsion.org/borgmatic/) is a **wrapper around Borg**.

### What it does:

* Automates backups using **Borg**:

  * Schedule backups
  * Prune old backups (retention policies)
  * Monitor repository health
  * Send email reports on success/failure
* Provides a **configuration file** so you don’t have to write shell scripts manually

### Could it be useful?

Yes — depending on your situation:

**Pros:**

* Easier to maintain than custom scripts
* Integrates retention, logging, and health checks
* Can handle multiple repositories and backup sources

**Cons / caveats:**

* You still need to ensure **database consistency** before Borgmatic runs (dump or snapshot)
* Borgmatic **does not magically solve active database corruption**; it just automates Borg

---

## 3. What about **Restic**?

**Restic** is another modern backup tool:

* Deduplicated, encrypted backups
* Similar goals to Borg (snapshot-based)
* Supports multiple backends (local, SFTP, cloud)
* Can back up **active files**, but same problem applies: active databases may be inconsistent


