#!/bin/bash
set -e

################################################################################
# Oracle XE 21c Automated Installation Script
# Author: NIMENDRA
################################################################################

echo "================================================================================"
echo " Starting Oracle XE 21c installation..."
echo " This process may take several minutes, especially during the first run."
echo "================================================================================"

# Step 1: Update YUM cache and system packages
echo "[Step 1] Updating YUM cache and upgrading system packages..."
yum makecache -y
yum update -y

# Step 2: Install Oracle preinstall package
echo "[Step 2] Installing Oracle preinstallation RPM..."

PREINSTALL_RPM="/vagrant/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm"
if [[ -f "$PREINSTALL_RPM" ]]; then
  echo "Found preinstall RPM: $PREINSTALL_RPM"
  yum localinstall -y "$PREINSTALL_RPM"
else
  echo "Preinstall RPM not found in /vagrant. Installing via dnf instead..."
  dnf install -y oracle-database-preinstall-21c
fi

# Step 3: Install Oracle XE 21c RPM
echo "[Step 3] Installing Oracle XE 21c RPM..."

ORACLE_XE_RPM="/vagrant/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
if [[ -f "$ORACLE_XE_RPM" ]]; then
  echo "Found Oracle XE RPM: $ORACLE_XE_RPM"
  yum localinstall -y "$ORACLE_XE_RPM"
else
  echo "ERROR: Oracle XE RPM not found at $ORACLE_XE_RPM"
  echo "Please download it manually from:"
  echo "  https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
  echo "and place it in the /vagrant directory."
  exit 1
fi

# Step 4: Configure Oracle Database
echo "[Step 4] Configuring Oracle XE..."
ORACLE_PASSWORD=Oracle123 \
  ORACLE_CONFIRM_PASSWORD=Oracle123 \
  ORACLE_CHARACTERSET=AL32UTF8 \
  /etc/init.d/oracle-xe-21c configure

# Step 5: Add Oracle environment variables to vagrant user's .bashrc
echo "[Step 5] Setting Oracle environment variables for vagrant user..."
cat <<EOF >>/home/vagrant/.bashrc

# Oracle XE environment setup
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=\$PATH:/opt/oracle/product/21c/dbhomeXE/bin/
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/oracle/product/21c/dbhomeXE/lib/
EOF

# Step 7: Run a test SQL query to verify connection
echo "[Step 7] Verifying Oracle XE connection with a test query..."

echo "SELECT 'Hello, Oracle!' AS test_message FROM dual;" |
  sqlplus -s system/Oracle123@//localhost:1521/XE

# Done
echo "================================================================================"
echo " Oracle XE 21c installation and verification complete!"
echo
echo " Default connection details:"
echo "   - Username : SYSTEM"
echo "   - Password : Oracle123"
echo "   - Connect  : sqlplus system/Oracle123@//localhost:1521/XE"
echo "================================================================================"
