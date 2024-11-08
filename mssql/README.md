# MAS Local on MS SQL
 A few scripts to bring up a MAS Manage on OCP Local with an external MS SQL
 
## Summary
These instructions will allow you to have a fully functional MAS Core + Manage, that has the Suite License Server (SLS) on board, while UDS is either slim or remote and Manage uses a MS SQL Server outside of the OpenShift cluster, but resident on the same PC.

## What you would need to run MS SQL Server
For this type of deployment you will need a laptop able to handle OCP Local with 12 vCPU and 20 GiB of memory + a running MS SQL Server. (Hopefully a Lenovo ThinkPad P15 with 32 GiB of memory is enough).
You can download and install the MS SQL Server Developer's version from the Microsoft site at this link : https://www.microsoft.com/en-us/sql-server/sql-server-downloads
During the install, don't forget to add the current user as the administrator and make sure the full text search option is selected for the engine. All other defaults are good (e.g. Instance ID = MSSQLSERVER). Install also the SQL Server Management Studio (SSMS).
Open the SQL Server Configuration Manager and make sure the services are running (SQL Full-text Filter Daemon Launcher, SQL Server). Moreover, in *SQL Server Network Configuration*, *Protocols for MSSQLSERVER*, *TCP/IP* has to be enabled. Double click on it, switch to the *IP Addresses* tab, and make sure the IP Address 127.0.0.1 is Active and Enabled (both should be *Yes*).
Run the Microsoft SQL Server Management Studio and log in (the current user should be the administrator).
Create a new database called **maxdb80**. Configure it as described at this link: https://www.ibm.com/docs/en/maximo-manage/continuous-delivery?topic=deployment-configuring-microsoft-sql-server. Use `maximopassword` as the password for the `MAXIMO` userid. If you want to use a different password, you will have to modify the `mssql-secret.yaml` fiule in this directory and change the `data.password` field, to match the password you have used. That field is a base64 encoding of the password.
At this point you should install OpenShift Local, if you have not done that already. The next section will provide a few info.

## What you would need to run OpenShift Local
To get OpenShift Local and install it, the instructions are the same of those described in the main README. The configuration is different and these is the set of commands to configure it correctly and start it
```
crc config set consent-telemetry no
crc config set host-network-access true
crc config set cpus 12
crc config set memory 25600
crc config set disk-size 200
crc start
```
At this point you should have an OpenShift running and ready to host MAS Core + Manage. From the last ourput of `crc start` you may want to record the password to log into the cluster.

## What you would need to run MAS Manage and you would install MAS Core and MAS Manage
The instructions are exactly those written in the main README, but instead of customizing the file `masocpl.yml` in the `mas-local` directory, you'll need to customize the one in this directory (i.e. `mas-local\mssql`). Moreover there is a difference in the way you will invoke the batch file to run the installation for an external MS SQL. The command is `masinst mssql`.
When the installation is completed, follow the instructions at the end of the main README, to retrieve the MAS superuser credentials, accept the self-signed certificates, log as the MAS superuser, reset the password of the user `wilson`, and then log as him to access Manage.