# Oracle XE 21c on Oracle Linux 8 with Vagrant

This guide provides a complete setup for installing and configuring Oracle Database 21c Express Edition (XE) on Oracle Linux 8 using Vagrant. It includes database verification, listener configuration, remote access setup, and troubleshooting steps.


## Vagrant Setup

Download the [`oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm`](https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm) and `oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm` from Oracle’s official site and place it in the same folder.

```bash
vagrant up 

vagrant ssh
```
```
```

## Post-Installation

### Oracle XE Credentials

* **Username:** `system`
* **Password:** `Oracle123`


## Verify Database Connection

SSH into the VM and switch to the `oracle` user:

```bash
vagrant ssh
sudo su - oracle
```

Start SQL\*Plus:

```bash
sqlplus
```

Login:

```
Enter user-name: system
Enter password: Oracle123
```

Test the connection:

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

This error means the service (e.g., `XE`) is not registered with the Oracle listener.

### Step-by-Step Fix

1. **Switch to Oracle User**

   ```bash
   vagrant ssh
   sudo su - oracle
   ```

2. **Login to SQL\*Plus as SYSDBA**

   ```bash
   sqlplus / as sysdba
   ```

3. **Check Database Status**

   ```sql
   SELECT status FROM v$instance;
   ```

   If the result is not `OPEN`, then:

   ```sql
   STARTUP;
   ```

4. **Register the Service**

   ```sql
   ALTER SYSTEM REGISTER;
   ```

5. **Verify Listener Status**

   Exit SQL\*Plus:

   ```bash
   exit
   ```

   Then run:

   ```bash
   lsnrctl status
   ```

   Expected output should include:

   ```
   Service "XE" has 1 instance(s).
   Instance "XE", status READY, has 1 handler(s) for this service...
   ```


## Configuration for Remote Access

### File Locations

| File           | Purpose         | Location                                                      |
| -------------- | --------------- | ------------------------------------------------------------- |
| `listener.ora` | Listener config | `/opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora` |
| `tnsnames.ora` | Client config   | `~/.oracle/network/admin/tnsnames.ora` or `/etc/tnsnames.ora` |


### listener.ora (on Server)

Edit the file `/opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora`:

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

Make sure the `XE` service appears in the output.


### tnsnames.ora (on Client)

On the remote machine (or host), create or edit `tnsnames.ora`:

```ini
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.56.38)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XE)
    )
  )
```

Replace `192.168.56.38` with the actual IP of your Oracle VM.


## Test Remote Connection

From a client system with Oracle tools installed:

```bash
sqlplus system/Oracle123@XE
```

Or directly with a full descriptor:

```bash
sqlplus system/Oracle123@//192.168.56.38:1521/XE
```


