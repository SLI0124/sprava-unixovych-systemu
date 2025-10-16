# Task 04 - Network Services (DHCP, NAT, TFTP, NFS, Network Boot)

# Backup a konfigurace síťových rozhraní
cp /etc/network/interfaces /etc/network/interfaces.backup
nano /etc/network/interfaces
# soubor bude obsahovat:
# source /etc/network/interfaces.d/*
# auto lo
# iface lo inet loopback
# allow-hotplug enp0s3
# iface enp0s3 inet dhcp
# iface enp0s3 inet6 auto
# allow-hotplug enp0s8
# iface enp0s8 inet static
#         address 192.168.57.2/24

# Aktivace druhé síťovky
ifup enp0s8

# Instalace DHCP serveru
apt update
apt install isc-dhcp-server

# Konfigurace DHCP rozhraní
nano /etc/default/isc-dhcp-server
# soubor bude obsahovat:
# INTERFACESv4="enp0s8"
# INTERFACESv6=""

# Konfigurace DHCP serveru
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
nano /etc/dhcp/dhcpd.conf
# soubor bude obsahovat:
# option domain-name "vsb.cz";
# option domain-name-servers 158.196.0.53;
# subnet 192.168.57.0 netmask 255.255.255.0 {
#   range 192.168.57.10 192.168.57.20;
#   option routers 192.168.57.2;
# }

# Test a spuštění DHCP serveru
dhcpd -t
systemctl enable isc-dhcp-server
systemctl start isc-dhcp-server
systemctl status isc-dhcp-server

# Povolení IP forwarding pro NAT
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/ip_forward.conf
sysctl -p /etc/sysctl.d/ip_forward.conf

# Konfigurace NAT pomocí nftables
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting masquerade
nft list ruleset >> /etc/nftables.conf
systemctl enable nftables
systemctl start nftables

# Instalace TFTP serveru
apt install tftpd-hpa
cd /srv/tftp
echo "Hello from TFTP" > test_file.txt

# Stažení a rozbalení netboot souborů
apt install wget
wget http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz
gzip -d netboot.tar.gz
tar xf netboot.tar

# Rozšíření DHCP konfigurace pro PXE boot
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.pxe_backup
nano /etc/dhcp/dhcpd.conf
# soubor bude obsahovat:
# option domain-name "vsb.cz";
# option domain-name-servers 158.196.0.53;
# subnet 192.168.57.0 netmask 255.255.255.0 {
#   range 192.168.57.100 192.168.57.200;
#   option broadcast-address 192.168.57.255;
#   option routers 192.168.57.2;
#   next-server 192.168.57.2;
#   filename "pxelinux.0";
# }

# Restart DHCP po změně
dhcpd -t
systemctl restart isc-dhcp-server

# Instalace NFS serveru
apt install nfs-kernel-server
mkdir -p /srv/tftp/rootfs

# Konfigurace NFS exportů
nano /etc/exports
# soubor bude obsahovat:
# /srv/tftp/rootfs        192.168.57.0/24(rw,async,no_root_squash)
systemctl restart nfs-kernel-server
systemctl enable nfs-kernel-server
exportfs -v

# Uspořádání boot souborů
cd /srv/tftp
mkdir backup
mv debian-installer backup/
cp -arv backup/debian-installer/amd64/pxelinux.cfg/ .
cp -arv backup/debian-installer/amd64/pxelinux.0 .
cp -arv backup/debian-installer/amd64/boot-screens/ldlinux.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/libcom32.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/libutil.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/vesamenu.c32 .

# Konfigurace boot menu
rm pxelinux.cfg/default
cp -arv backup/debian-installer/amd64/boot-screens/syslinux.cfg pxelinux.cfg/
mv pxelinux.cfg/syslinux.cfg pxelinux.cfg/default

# Kopírování kernel souborů (zkontroluj dostupné verze)
mkdir Debian
ls /boot/vmlinuz-*
ls /boot/initrd.img-*
cp -arv /boot/vmlinuz-6.12.43+deb13-amd64 Debian/
cp -arv /boot/initrd.img-6.12.43+deb13-amd64 Debian/

# Konfigurace PXE boot menu
nano pxelinux.cfg/default
# soubor bude obsahovat:
# DEFAULT vesamenu.c32
# PROMPT 0
# MENU TITLE  Boot Menu
# LABEL Debian - NetBoot
# KERNEL /Debian/vmlinuz-6.12.43+deb13-amd64
# APPEND initrd=/Debian/initrd.img-6.12.43+deb13-amd64 root=/dev/nfs nfsroot=192.168.57.2:/srv/tftp/rootfs/ ip=dhcp rw

# Příprava root filesystému
cd /srv/tftp/rootfs
cp -arv /bin /boot /etc /home /lib /lib64 /opt /root /sbin /tmp /usr /var .
mkdir {dev,media,mnt,proc,lost+found,run,srv,sys}
chmod 777 tmp/
chmod o+t tmp/

# Konfigurace sítě pro bezdiskový boot
cp etc/network/interfaces etc/network/interfaces.original
nano etc/network/interfaces
# soubor bude obsahovat:
# source /etc/network/interfaces.d/*
# auto lo
# iface lo inet loopback

# Zakomentování filesystem záznamů v fstab
cp etc/fstab etc/fstab.original
nano etc/fstab
# soubor bude obsahovat (všechny řádky zakomentované):
# # LABEL=root / ext4 errors=remount-ro 0 1
# # UUID=... /boot ext2 defaults 0 2
# # /dev/sr0 /media/cdrom0 udf,iso9660 user,noauto 0 0

# Kontrola služeb
systemctl status isc-dhcp-server
systemctl status nfs-kernel-server
systemctl status tftpd-hpa
systemctl status nftables

# Sledování DHCP leasů
tail -f /var/lib/dhcp/dhcpd.leases

# Monitorování NFS
mount | grep nfs