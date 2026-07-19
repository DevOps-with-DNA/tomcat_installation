# tomcat_installation
# Universal Apache Tomcat 11 Installer

A Bash script that automatically updates the operating system, installs Java, downloads Apache Tomcat 11, configures a systemd service, enables the Manager and Host Manager applications, and opens the required firewall port.

---

## Features

- Supports Ubuntu
- Supports RHEL
- Supports Rocky Linux
- Supports AlmaLinux
- Supports Amazon Linux
- Automatic system update
- Automatic system upgrade
- Installs Java
- Downloads Tomcat
- Creates systemd service
- Enables Manager & Host Manager
- Opens firewall
- Configures admin user

---

## Supported Operating Systems

- Ubuntu 22.04+
- Ubuntu 24.04+
- RHEL 8+
- RHEL 9+
- Rocky Linux 8+
- Rocky Linux 9+
- AlmaLinux 8+
- AlmaLinux 9+
- Amazon Linux 2023

---

## Prerequisites

- Internet connection
- Root or sudo access

---

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/tomcat-installer.git
```

Move into the project:

```bash
cd tomcat-installer
```

Make the script executable:

```bash
chmod +x install.sh
```

Run the installer:

```bash
sudo ./install.sh
```

or

```bash
sudo bash install.sh
```

---

## Access Tomcat

Application

```
http://<server-ip>:8080
```

Manager

```
http://<server-ip>:8080/manager/html
```

Host Manager

```
http://<server-ip>:8080/host-manager/html
```

---

## Default Credentials

Username

```
admin
```

Password

```
admin@123
```

---

## Uninstall

```bash
sudo ./install.sh --uninstall
```
