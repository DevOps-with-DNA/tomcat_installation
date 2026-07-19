#!/bin/bash
# Universal Tomcat 11 Installer (Starter)
# Supports: Ubuntu, RHEL, Rocky, AlmaLinux, CentOS, Amazon Linux

set -e

VERSION="11.0.22"
TOMCAT_USER="tomcat"
DEFAULT_PORT=8080

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root:"
    echo "sudo bash $0"
    exit 1
fi

DISTRO=$(source /etc/os-release && echo "$ID")

is_port_free() {
    ! ss -tuln | grep -q ":$1 "
}

echo "Updating system..."

case "$DISTRO" in
    ubuntu)
        apt update -y
        DEBIAN_FRONTEND=noninteractive apt upgrade -y
        apt install -y openjdk-21-jdk wget curl tar
        ;;
    rhel|rocky|almalinux|centos|amzn)
        if command -v dnf >/dev/null 2>&1; then
            dnf upgrade -y
            dnf install -y java-21-openjdk-devel wget curl tar
        else
            yum update -y
            yum install -y java-21-openjdk-devel wget curl tar
        fi
        ;;
    *)
        echo "Unsupported OS: $DISTRO"
        exit 1
        ;;
esac
echo "======================================"
read -p "Enter Tomcat Port [8080]: " PORT
PORT=${PORT:-$DEFAULT_PORT}

while ! is_port_free "$PORT"; do
    echo "Port $PORT is busy."
    echo "================================="
    read -p "Enter another port: " PORT
done

systemctl stop tomcat 2>/dev/null || true
systemctl disable tomcat 2>/dev/null || true
rm -rf /opt/tomcat
rm -f /etc/systemd/system/tomcat.service
id $TOMCAT_USER &>/dev/null && userdel -r $TOMCAT_USER || true

groupadd -f tomcat
useradd -r -g tomcat -d /opt/tomcat -s /sbin/nologin tomcat 2>/dev/null || \
useradd -r -g tomcat -d /opt/tomcat -s /bin/false tomcat 2>/dev/null || true

cd /tmp
wget -q -O apache-tomcat.tar.gz https://archive.apache.org/dist/tomcat/tomcat-11/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz

mkdir -p /opt/tomcat
tar -xzf apache-tomcat.tar.gz -C /opt/tomcat --strip-components=1
rm -f apache-tomcat.tar.gz

chown -R tomcat:tomcat /opt/tomcat
chmod +x /opt/tomcat/bin/*.sh

cat >/opt/tomcat/conf/tomcat-users.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users version="1.0">
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="manager-status"/>
<role rolename="admin-gui"/>
<user username="admin" password="admin@123" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui"/>
</tomcat-users>
EOF

cat >/opt/tomcat/webapps/manager/META-INF/context.xml <<EOF
<Context privileged="true"></Context>
EOF

cat >/opt/tomcat/webapps/host-manager/META-INF/context.xml <<EOF
<Context privileged="true"></Context>
EOF

sed -i "s/port=\"8080\"/port=\"$PORT\"/" /opt/tomcat/conf/server.xml

JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(which java)")")")

cat >/etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=$JAVA_HOME
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now tomcat

if command -v ufw >/dev/null 2>&1; then
    ufw allow ${PORT}/tcp || true
fi

if systemctl is-active firewalld >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port=${PORT}/tcp || true
    firewall-cmd --reload || true
fi

IP=$(curl -4 -s ifconfig.me || hostname -I | awk '{print $1}')

echo
echo "Tomcat Installed Successfully"
echo "Application : http://$IP:$PORT"
echo "Manager     : http://$IP:$PORT/manager/html"
echo "HostManager : http://$IP:$PORT/host-manager/html"
echo "==================================================="
echo "Username    : admin"
echo "Password    : admin@123"
echo "==================================================="
