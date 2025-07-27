# Oracle XE 21c on Oracle Linux 8 with Vagrant

This guide provides a complete setup for installing and configuring Oracle Database 21c Express Edition (XE) on Oracle Linux 8 using Vagrant. It includes database installation, verification, listener configuration, remote access setup, and troubleshooting steps.

> [!NOTE]
> If you have questions, issues, or suggestions related to this setup, feel free to start a [discussion](https://github.com/nmdra/Oracle-Database-XE-Vagrant-Setup/discussions) or open an [issue](https://github.com/nmdra/Oracle-Database-XE-Vagrant-Setup/issues) in this repository.

## Prerequisites

1. **Download the required RPMs** and place them in the same folder as your `Vagrantfile`:

   - [oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm](https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm)
   - [oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm](https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm)

## Vagrant Setup

Launch the VM:

```bash
vagrant up
vagrant ssh
````
## Post-Installation

### Oracle XE Default Credentials

* **Username:** `system`
* **Password:** `Oracle123`

## Verify Database Connection

1. SSH into the VM and switch to the `oracle` user:

   ```bash
   vagrant ssh
   sudo su - oracle
   ```

2. Start SQL\*Plus:

   ```bash
   sqlplus
   ```

3. Login:

   ```
   Enter user-name: system
   Enter password: Oracle123
   ```

4. Run a test query:

   ```sql
   SELECT 'Hello, Oracle!' AS test_message FROM dual;
   ```

   Expected output:

   ```
   TEST_MESSAGE
   --------------
   Hello, Oracle!
   ```
## Troubleshooting: ORA-12514

### Error

```
ORA-12514: TNS:listener does not currently know of service requested in connect descriptor
```

This error indicates that the service (e.g., `XE`) is not registered with the Oracle listener.

### Step-by-Step Fix

1. **Switch to the Oracle user:**

   ```bash
   vagrant ssh
   sudo su - oracle
   ```

2. **Login as SYSDBA:**

   ```bash
   sqlplus / as sysdba
   ```

3. **Check database status:**

   ```sql
   SELECT status FROM v$instance;
   ```

   If the result is not `OPEN`, start the database:

   ```sql
   STARTUP;
   ```

4. **Register the service:**

   ```sql
   ALTER SYSTEM REGISTER;
   ```

5. **Verify listener status:**

   Exit SQL\*Plus:

   ```bash
   exit
   ```

   Then run:

   ```bash
   lsnrctl status
   ```

   Look for:

   ```
   Service "XE" has 1 instance(s).
   Instance "XE", status READY, has 1 handler(s) for this service...
   ```
## Remote Access Configuration (Advanced)

> [!CAUTION]
> This section is intended for advanced users. Modifying Oracle listener and network configurations without understanding the implications can result in service unavailability or connectivity issues. Only proceed if you understand what you're doing.

### File Locations

| File           | Purpose         | Location                                                      |
| -------------- | --------------- | ------------------------------------------------------------- |
| `listener.ora` | Listener config | `/opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora` |
| `tnsnames.ora` | Client config   | `~/.oracle/network/admin/tnsnames.ora` or `/etc/tnsnames.ora` |

### Server Configuration: `listener.ora`

Edit the file:

```bash
sudo vi /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora
```

Update contents to:

```ini
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    )
  )

DEFAULT_SERVICE_LISTENER = XE
```

Restart the listener:

```bash
lsnrctl stop
lsnrctl start
lsnrctl status
```

Ensure `XE` service appears in the output.

---

### Client Configuration: `tnsnames.ora`

On the client machine (or host system), create or edit `tnsnames.ora`:

```ini
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.56.38)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XE)
    )
  )
```

Replace `192.168.56.38` with the actual IP address of the Oracle VM.

---

## Test Remote Connection

From a system with Oracle tools installed:

```bash
sqlplus system/Oracle123@XE
```
Or connect directly using the full descriptor:

```bash
sqlplus system/Oracle123@//192.168.56.38:1521/XE
```
## Resources

- Vagrant Documentation:
   - https://developer.hashicorp.com/vagrant/docs
- Oracle XE 21c Documentation:
   - https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/
 
---
<div align="center">
  <a href="https://blog.nimendra.xyz"> 🌎 nmdra.xyz</a> |
  <a href="https://github.com/nmdra"> 👨‍💻 Github</a> |
  <a href="https://twitter.com/nimendra_"> 🐦 Twitter</a>
</div>

