#!/bin/bash
# Task 06 - LAMP Stack Setup Commands

# ==============================================================================
# PŘÍPRAVA PROSTŘEDÍ
# ==============================================================================

# Nastavení DNS resolver na všech strojích
nano /etc/resolv.conf
# nameserver 192.168.56.105

# Nastavení statické IP pro LAMP server
nano /etc/network/interfaces
# allow-hotplug enp0s8
# iface enp0s8 inet static
#         address 192.168.56.80
#         netmask 255.255.255.0

ifup enp0s8
hostnamectl set-hostname lamp

# ==============================================================================
# INSTALACE APACHE A PHP
# ==============================================================================

apt update
apt install apache2
apt install libapache2-mod-php
service apache2 restart

# Test PHP - přejmenování a úprava index souboru
cd /var/www/html
mv index.html index.php
# Přidat na začátek: <?php phpinfo(); ?>

# ==============================================================================
# KONFIGURACE DNS NA DNS1 SERVERU
# ==============================================================================

# Na DNS1 serveru editovat zonový soubor
nano /etc/bind/db.sli0124.cz
# Změnit seriové číslo a přidat:
# lamp           IN      A       192.168.56.80
# www            IN      CNAME   lamp.sli0124.cz.
# wiki           IN      CNAME   lamp.sli0124.cz.
# test           IN      CNAME   lamp.sli0124.cz.

service bind9 restart
nslookup www.sli0124.cz

# Na LAMP serveru test DNS
apt install dnsutils
nslookup www.sli0124.cz

# ==============================================================================
# PŘÍPRAVA VIRTUÁLNÍCH HOSTŮ
# ==============================================================================

cd /var/www
mkdir www.sli0124.cz wiki.sli0124.cz test.sli0124.cz

# WWW stránka
cd /var/www/www.sli0124.cz
echo "Hello from sli0124!" > index.html

cd /etc/apache2/sites-available
cp 000-default.conf www.sli0124.cz.conf
# Upravit: ServerName www.sli0124.cz, DocumentRoot /var/www/www.sli0124.cz

a2dissite 000-default
a2ensite www.sli0124.cz
systemctl reload apache2

# Wiki stránka (dočasná)
cd /var/www/wiki.sli0124.cz
echo "Hello from wiki!" > index.html

cd /etc/apache2/sites-available
cp www.sli0124.cz.conf wiki.sli0124.cz.conf
# Upravit: ServerName wiki.sli0124.cz, DocumentRoot /var/www/wiki.sli0124.cz

a2ensite wiki.sli0124.cz
systemctl reload apache2

# ==============================================================================
# MARIADB A MEDIAWIKI
# ==============================================================================

apt install default-mysql-server
mysql -u root -p
# CREATE DATABASE wiki;
# CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'wiki';
# GRANT ALL ON wiki.* TO wiki@localhost;
# \q

cd /root/
apt install unzip wget
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.2.zip
unzip mediawiki-1.44.2.zip
cp -r mediawiki-1.44.2/* /var/www/wiki.sli0124.cz/
cd /var/www/wiki.sli0124.cz/
rm index.html

apt install php-mbstring php-xml php-mysql php-intl
systemctl restart apache2

# Webová konfigurace na wiki.sli0124.cz
# Po dokončení:
# scp LocalSettings.php sli0124@192.168.56.80:
# cp /home/sli0124/LocalSettings.php /var/www/wiki.sli0124.cz/

# ==============================================================================
# TEST STRÁNKA
# ==============================================================================

cd /var/www/test.sli0124.cz
# Vytvořit index.php s PHP kódem

cd /etc/apache2/sites-available
cp www.sli0124.cz.conf test.sli0124.cz.conf
# Upravit: ServerName test.sli0124.cz, DocumentRoot /var/www/test.sli0124.cz

a2ensite test.sli0124.cz
systemctl reload apache2

# ==============================================================================
# TESTOVÁNÍ
# ==============================================================================

# Na testovacím stroji nastavit IP 192.168.56.110 a DNS 192.168.56.105
apt install elinks
elinks www.sli0124.cz
elinks wiki.sli0124.cz
elinks test.sli0124.cz