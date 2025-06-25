#!/bin/bash
set -e

echo "🔁 Updating YUM cache and system packages..."
yum makecache -y
yum update -y

echo "🔧 Installing Oracle preinstall RPM..."

# Use preinstall package (Oracle officially supports this on Oracle Linux 8)
yum localinstall -y /vagrant/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm

echo "📦 Installing Oracle XE 21c RPM..."
yum localinstall -y /vagrant/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm

echo "⚙️ Configuring Oracle XE..."

ORACLE_PASSWORD=Oracle123 \
  ORACLE_CONFIRM_PASSWORD=Oracle123 \
  ORACLE_CHARACTERSET=AL32UTF8 \
  /etc/init.d/oracle-xe-21c configure

echo "✅ Setting Oracle environment for vagrant user..."
cat <<EOF >>/home/vagrant/.bashrc

# Oracle XE environment
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=$PATH:/opt/oracle/product/21c/dbhomeXE/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/product/21c/dbhomeXE/lib/
EOF

echo "✅ Oracle XE 21c is installed and ready to use!"
echo "🔐 Default credentials:"
echo "    - Username: SYSTEM"
echo "    - Password: Oracle123"
echo "    - Connect with: sqlplus system/Oracle123@//localhost:1521/XE"
