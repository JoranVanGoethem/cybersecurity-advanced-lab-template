# WAZUH indexer install

## WAZUH Indexer
```
[root@siem vagrant]# curl -k -u admin https://172.30.0.20:9200
Enter host password for user 'admin':
{
  "name" : "node-1",
  "cluster_name" : "wazuh-cluster",
  "cluster_uuid" : "5K7xW5RiS6CL3V_7WQ8l9g",
  "version" : {
    "number" : "7.10.2",
    "build_type" : "rpm",
    "build_hash" : "ac8f6e0114b657a116c4a41c3e12f8e0e181bbcd",
    "build_date" : "2025-11-08T11:55:34.225460336Z",
    "build_snapshot" : false,
    "lucene_version" : "9.12.2",
    "minimum_wire_compatibility_version" : "7.10.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```

## WAZUH Cluster
```
[root@siem vagrant]# curl -k -u admin https://172.30.0.20:9200/_cat/nodes?v
Enter host password for user 'admin':
ip          heap.percent ram.percent cpu load_1m load_5m load_15m node.role node.roles                                        cluster_manager name
172.30.0.20           39          94   3    0.12    0.12     0.10 dimr      cluster_manager,data,ingest,remote_cluster_client *               node-1
[root@siem vagrant]#
```

## WAZUH server install

```bash
 [root@localhost vagrant]# systemctl status wazuh-dashboard
● wazuh-dashboard.service - wazuh-dashboard
     Loaded: loaded (/etc/systemd/system/wazuh-dashboard.service; enabled; preset: disabled)
     Active: active (running) since Wed 2026-01-07 18:38:54 CET; 11s ago
   Main PID: 40500 (node)
      Tasks: 11 (limit: 22972)
     Memory: 146.9M (peak: 147.2M)
        CPU: 2.676s
     CGroup: /system.slice/wazuh-dashboard.service
             └─40500 /usr/share/wazuh-dashboard/node/bin/node --no-warnings --max-http-header-size=65536 --unhandled-rejections=warn /usr/share/wazuh-dashboa>

Jan 07 18:38:54 localhost.localdomain systemd[1]: Started wazuh-dashboard.

```

```bash
[root@localhost vagrant]# systemctl status wazuh-manager.service
● wazuh-manager.service - Wazuh manager
     Loaded: loaded (/usr/lib/systemd/system/wazuh-manager.service; enabled; preset: disabled)
     Active: active (running) since Wed 2026-01-07 17:54:57 CET; 38min ago
      Tasks: 224 (limit: 22972)
     Memory: 1.3G (peak: 1.3G)
        CPU: 6min 32.947s
     CGroup: /system.slice/wazuh-manager.service
             ├─37716 /var/ossec/framework/python/bin/python3 /var/ossec/api/scripts/wazuh_apid.py
             ├─37717 /var/ossec/framework/python/bin/python3 /var/ossec/api/scripts/wazuh_apid.py
             ├─37718 /var/ossec/framework/python/bin/python3 /var/ossec/api/scripts/wazuh_apid.py
             ├─37721 /var/ossec/framework/python/bin/python3 /var/ossec/api/scripts/wazuh_apid.py
             ├─37724 /var/ossec/framework/python/bin/python3 /var/ossec/api/scripts/wazuh_apid.py
             ├─37766 /var/ossec/bin/wazuh-authd
             ├─37783 /var/ossec/bin/wazuh-db
             ├─37819 /var/ossec/bin/wazuh-execd
             ├─37833 /var/ossec/bin/wazuh-analysisd
             ├─37844 /var/ossec/bin/wazuh-syscheckd
             ├─37865 /var/ossec/bin/wazuh-remoted
             ├─37876 /var/ossec/bin/wazuh-logcollector
             ├─37920 /var/ossec/bin/wazuh-monitord
             └─37970 /var/ossec/bin/wazuh-modulesd

Jan 07 17:54:52 localhost.localdomain env[37654]: Started wazuh-syscheckd...
Jan 07 17:54:52 localhost.localdomain env[37654]: Started wazuh-remoted...
Jan 07 17:54:53 localhost.localdomain env[37654]: Started wazuh-logcollector...
Jan 07 17:54:54 localhost.localdomain env[37654]: Started wazuh-monitord...
Jan 07 17:54:54 localhost.localdomain env[37968]: 2026/01/07 17:54:54 wazuh-modulesd:router: INFO: Loaded router module.
Jan 07 17:54:54 localhost.localdomain env[37968]: 2026/01/07 17:54:54 wazuh-modulesd:content_manager: INFO: Loaded content_manager module.
Jan 07 17:54:54 localhost.localdomain env[37968]: 2026/01/07 17:54:54 wazuh-modulesd:inventory-harvester: INFO: Loaded Inventory harvester module.
Jan 07 17:54:55 localhost.localdomain env[37654]: Started wazuh-modulesd...
Jan 07 17:54:57 localhost.localdomain env[37654]: Completed.
Jan 07 17:54:57 localhost.localdomain systemd[1]: Started Wazuh manager.
```

```bash
[root@localhost vagrant]# systemctl status wazuh-indexer
● wazuh-indexer.service - wazuh-indexer
     Loaded: loaded (/usr/lib/systemd/system/wazuh-indexer.service; enabled; preset: disabled)
     Active: active (running) since Wed 2026-01-07 17:27:41 CET; 1h 6min ago
       Docs: https://documentation.wazuh.com
   Main PID: 969 (java)
      Tasks: 75 (limit: 22972)
     Memory: 1.1G (peak: 1.4G)
        CPU: 1min 20.977s
     CGroup: /system.slice/wazuh-indexer.service
             └─969 /usr/share/wazuh-indexer/jdk/bin/java -Xshare:auto -Dopensearch.networkaddress.cache.ttl=60 -Dopensearch.networkaddress.cache.negative.ttl>

Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.cluster.service.ClusterApplierService.applyChanges(ClusterApplierSer>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.cluster.service.ClusterApplierService.runTask(ClusterApplierService.>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.cluster.service.ClusterApplierService$UpdateTask.run(ClusterApplierS>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.common.util.concurrent.ThreadContext$ContextPreservingRunnable.run(T>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.common.util.concurrent.PrioritizedOpenSearchThreadPoolExecutor$TieBr>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at org.opensearch.common.util.concurrent.PrioritizedOpenSearchThreadPoolExecutor$TieBr>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.jav>
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]:         at java.base/java.lang.Thread.run(Thread.java:1583)
Jan 07 17:27:43 localhost.localdomain systemd-entrypoint[969]: For complete error details, refer to the log at /var/log/wazuh-indexer/wazuh-cluster.log
 ESCOC

eset: disabled)
``` 


# TODO morgen

## Explore the options of your freshly installed and configured SIEM solution:

What is File Integrity Monitoring? Try to monitor the home directory of a user on a Almalinux machine. Create a demo to visualize this using the web interface of wazuh.
What is meant with Regulatory Compliance? Give 2 frameworks that can be explored.
Threat hunting: discover the CLI commands that were executed on your machines. For example perform an install of a package or download a file and create an overview that lists all commands that have been run on that machine. Do you see your commands on the Linux machine? Which commands: only root/sudo commands? What about the Windows host, do you notice PowerShell commands or programs ran using cmd.exe?

## EVT
### FYI: Alpine¶
Note for alpine machines, if you would want to try to install agents on your alpine hosts: it seems the current (latest) version of the wazuh-agent doesn't officialy support alpine anymore. You can however still use the 4.8 documentation: https://documentation.wazuh.com/4.8/installation-guide/wazuh-agent/wazuh-agent-package-linux.html. Compatibility between the Wazuh agent and the Wazuh manager is guaranteed when the Wazuh manager version is later/higher than or equal to that of the Wazuh agent.

## Sysmon for Windows
There is a tool available from Microsoft that enhances Windows logging, called Sysmon. This tool enables us to gain more insight in what happens (or has happened) on a Windows machine, and thus allows us to find and track anomalies or threats. A Wazuh agent on Windows can be configured to process the Sysmon logs so that these can be monitored and processed by Wazuh. Interesting to know sysmon for linux also exists!

Wazuh has a blogpost in which Sysmon is installed next to a Wazuh agent. Then, an attack is executed with Mimikatz. This attack should show up in your Wazuh server. Go through the blog post and make sure you can simulate this yourself!

Tip: The primary goal of showing a working SIEM (wazuh) setup in this lab is proving that process create events, as well as PowerShell commands executed on the Windows workstation are succesfully registered and retrievable in Wazuh.