# Cvičení 4 -  Bootování ze sítě

## Co budeme dělat

V tomto úkolu si nastavíme kompletní síťovou infrastrukturu - DHCP server, NAT, TFTP server, NFS server a síťové bootování. Cílem je, aby se počítače mohly bootovat ze sítě bez vlastního disku.

## Co potřebujeme

**Důležité:** Budeme potřebovat **více síťových rozhraní** pro různé funkce!

- VirtualBox s Host-only network adaptérem (vboxnet1) **BEZ DHCP**
- **3 virtuální počítače:**
  - **SERVER:** Debian se dvěma síťovkami (NAT + Host-only)
  - **TEST:** Klientský počítač s jednou síťovkou (Host-only) pro testování DHCP/NAT
  - **NETBOOT:** Bezdiskový počítač s jednou síťovkou (Host-only) jen pro network boot

## Příprava sítě

### Nastavení serveru

Nejdřív si musíme nastavit síťovky na serveru. Editujeme `/etc/network/interfaces`:

```bash
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface (NAT - pro přístup na internet)
allow-hotplug enp0s3
iface enp0s3 inet dhcp
# This is an autoconfigured IPv6 interface
iface enp0s3 inet6 auto

# Host-only network interface (pro naši vnitřní síť)
allow-hotplug enp0s8
iface enp0s8 inet static
        address 192.168.57.2/24
```

Potom aktivujeme tu druhou síťovku:

```bash
ifup enp0s8
```

## Část 1: DHCP Server

### Instalace DHCP serveru

Nejdřív si nainstalujeme DHCP server. Pozor, hledáme `isc-dhcp-server` (to je daemon), ne klienta:

```bash
apt install isc-dhcp-server
```

Po instalaci bude služba červená, to je normální - musíme ji nejdřív nakonfigurovat.

### Konfigurace DHCP

Musíme upravit dva soubory:

**Soubor `/etc/default/isc-dhcp-server`** - zde říkáme, na které síťovce má DHCP běžet:

```bash
INTERFACESv4="enp0s8"
```

**Soubor `/etc/dhcp/dhcpd.conf`** - hlavní konfigurace:

```bash
# Globální nastavení pro všechny sítě
option domain-name "vsb.cz";
# DNS servery - POZOR na rozdíl mezi školou a domovem!
option domain-name-servers 158.196.0.53;  # školní DNS (pouze na školní síti!)
# Pokud konfigurujete doma, použijte: 8.8.8.8, 8.8.4.4 (Google DNS)

# Konfigurace naší podsítě
subnet 192.168.57.0 netmask 255.255.255.0 {
  range 192.168.57.10 192.168.57.20;  # rozsah IP adres pro klienty
  option routers 192.168.57.2;        # náš server jako gateway
}
```

### Testování DHCP

```bash
# Kontrola konfigurace (super věc, jinak by všechno spadlo)
dhcpd -t

# Spuštění služby
service isc-dhcp-server start
service isc-dhcp-server status  # pokud je zelená, jedeme dál

# Sledování přidělených adres
tail -f /var/lib/dhcp/dhcpd.leases
```

**Důležité:** To, že služba běží, neznamená, že funguje! Musíme to vyzkoušet na testovacím počítači.

**Test:** Vytvoříme nový počítač s jednou síťovkou (Host-only na vboxnet1). Pokud dostane IP adresu, DHCP funguje!

## Část 2: NAT (maskaráda)

Problém: klienti mají IP adresu, ale nemůžou na internet. Potřebujeme NAT.

### Povolení IP forwarding

Nejdřív musíme povolit přeposílání paketů mezi síťovkami:

```bash
# Zkontrolujeme aktuální stav
cat /proc/sys/net/ipv4/ip_forward  # mělo by být 0
```

Vytvoříme soubor `/etc/sysctl.d/ip_forward.conf`:

```bash
net.ipv4.ip_forward = 1
```

Aplikujeme to:

```bash
sysctl -p /etc/sysctl.d/ip_forward.conf
cat /proc/sys/net/ipv4/ip_forward  # teď by mělo být 1
```

### Nastavení NAT pomocí nftables

Teď nastavíme maskarádu (NAT):

```bash
# Přidáme NAT tabulku a pravidla
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting masquerade

# Uložíme konfiguraci (aby přežila restart)
nft list ruleset >> /etc/nftables.conf

# Povolíme nftables service
systemctl enable nftables
systemctl status nftables  # mělo by být zelené
```

**Test:** Teď by klienti měli být schopni pingnout seznam.cz!

## Část 3: TFTP Server

TFTP používáme pro přenos jednotlivých souborů (hlavně pro network boot).

### Instalace TFTP serveru

```bash
apt install tftpd-hpa
```

Konfigurace je v `/etc/default/tftpd-hpa`, ale defaultní nastavení většinou stačí.
TFTP soubory se ukládají do `/srv/tftp/`.

### Test TFTP

**Na serveru:**

```bash
cd /srv/tftp
echo "Hello from TFTP" > file.txt
```

**Na klientovi:**

```bash
apt install tftp-hpa  # pozor, jiný balíček než na serveru!
tftp 192.168.57.2
> binary
> get file.txt
> Ctrl+D
cat file.txt  # měl by obsahovat text ze serveru
```

## Část 4: Network Boot

Teď to začne být zajímavé! Vytvoříme počítač, který se bootuje ze sítě.

### Příprava netboot souborů

```bash
cd /srv/tftp
apt install wget
wget http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz
gzip -d netboot.tar.gz
tar xf netboot.tar
```

### Rozšíření DHCP konfigurace

Do `/etc/dhcp/dhcpd.conf` přidáme informace o PXE boot:

```bash
subnet 192.168.57.0 netmask 255.255.255.0 {
  range 192.168.57.10 192.168.57.20; 
  option broadcast-address 192.168.57.255;
  option routers 192.168.57.2;
  next-server 192.168.57.2;    # TFTP server
  filename "pxelinux.0";       # soubor pro PXE boot
}
```

```bash
dhcpd -t
service isc-dhcp-server restart
```

**Test:** Vytvoříme nový PC (NETBOOT) bez disku, jen s network boot. Mělo by se objevit install menu!

## Část 5: NFS Server

NFS je pro filesystém (na rozdíl od TFTP, který je jen pro jednotlivé soubory).

### Instalace NFS serveru

```bash
apt install nfs-kernel-server
```

### Příprava root filesystému

```bash
mkdir /srv/tftp/rootfs
cd /srv/tftp/rootfs
```

### Konfigurace NFS exportů

Přidáme do `/etc/exports`:

```bash
/srv/tftp/rootfs        192.168.57.0/24(rw,async,no_root_squash)
```

**Význam parametrů:**

- `rw`: read-write přístup (pro network boot je to OK, protože píšeme do paměti)
  - **Poznámka:** Pro běžné PC s diskem bychom použili `ro` (read-only), aby se zabránilo nechtěnému přepsání během bootu
  - Pro network boot můžeme použít `rw`, protože vše běží v paměti počítače
- `async`: více procesů pro zápis (rychlejší)
- `no_root_squash`:
  - Normálně NFS "squashuje" (mění) root uživatele na nobody kvůli bezpečnosti
  - `no_root_squash` povoluje, aby se root na klientovi choval jako root na serveru

```bash
service nfs-kernel-server restart
exportfs  # zobrazí exportované adresáře
```

### Test NFS

**Na klientovi:**

```bash
apt install nfs-common
mount 192.168.57.2:/srv/tftp/rootfs /mnt/
cd /mnt/
```

**Na serveru:**

```bash
watch -n 1 ls  # sleduje změny v adresáři
```

**Na klientovi:**

```bash
touch pokus.txt  # mělo by se objevit na serveru
```

## Část 6: Kompletní Network Boot

Teď to všechno spojíme dohromady!

### Uspořádání boot souborů

```bash
cd /srv/tftp

# Přesuneme netboot soubory do zálohy
mkdir backup
mv debian-installer backup/

# Zkopírujeme potřebné PXE soubory
# -arv, a -zachovává práva, r - rekurzivně, v - verbose (ukazuje co dělá)
cp -arv backup/debian-installer/amd64/pxelinux.cfg/ .
cp -arv backup/debian-installer/amd64/pxelinux.0 .
cp -arv backup/debian-installer/amd64/boot-screens/ldlinux.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/libcom32.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/libutil.c32 .
cp -arv backup/debian-installer/amd64/boot-screens/vesamenu.c32 .
```

### Konfigurace boot menu

```bash
rm pxelinux.cfg/default
cp -arv backup/debian-installer/amd64/boot-screens/syslinux.cfg pxelinux.cfg/
mv pxelinux.cfg/syslinux.cfg pxelinux.cfg/default
```

### Kopírování kernel souborů

```bash
mkdir Debian
cp -arv /boot/vmlinuz-* Debian/
cp -arv /boot/initrd.img-* Debian/
```

Poznámka: zkopírujeme si kernel a initrd z našeho serveru, aby se mohl bezdiskový počítač vůbec nastartovat. Já jsem tam měl dvě verze kernelu, tak si zkopírujte jen jednu, nebo proveďte příkaz nad a smažte tu druhou.

### Konfigurace PXE boot menu

Upravíme soubor `pxelinux.cfg/default`:

```bash
DEFAULT vesamenu.c32
PROMPT 0

MENU TITLE  Boot Menu

LABEL Debian - NetBoot
KERNEL /Debian/vmlinuz-6.12.43+deb13-amd64
APPEND initrd=/Debian/initrd.img-6.12.43+deb13-amd64 root=/dev/nfs nfsroot=192.168.57.2:/srv/tftp/rootfs/ ip=dhcp rw
```

Důležité vysvětlení:

- `nfsroot` říká, kde má kernel hledat root filesystem
- `ip=dhcp` říká, že IP adresu má získat přes DHCP
- `rw` povoluje zápis (na rozdíl od `ro` při boot z disku)

### Příprava root filesystému (rootfs)

Zkopírujeme systémové soubory do rootfs:

```bash
# Zkopírujeme systémové adresáře
cp -arv /bin /boot /etc /home /lib /lib64 /opt /root /sbin /tmp /usr /var rootfs/

# Vytvoříme prázdné adresáře
mkdir rootfs/{dev,media,mnt,proc,lost+found,run,srv,sys}

# Nastavení speciálních práv pro tmp
chmod 777 rootfs/tmp/
chmod o+t rootfs/tmp/
```

### Konfigurace sítě pro bezdiskový boot

**Upravíme `rootfs/etc/network/interfaces`:**

```bash
# Zakomentujeme všechno kromě:
source /etc/network/interfaces.d/*
```

**Upravíme `rootfs/etc/fstab`:**

```bash
# Zakomentujeme všechny filesystem záznamy (UUID disků nemáme)
```

## Hodina pravdy - Test network boot

1. Vytvoříme nový VM s:
   - **Žádný disk!**
   - Jen network adapter (Host-only na vboxnet1)
   - Boot order: jen Network

2. Spustíme VM - mělo by se zobrazit boot menu s "Debian - NetBoot"

3. Po nabootování ověříme NFS:

```bash
mount | grep nfs  # mělo by ukázat připojený NFS
```

Gratulace! Máme funkční bezdiskový počítač!

## Důležité poznámky a problémy

### Co se může pokazit v produkci

**Logy:** Všichni klienti sdílí stejné log adresáře. Řešení:

- Remote logging (logování na jiný server)
- Každý klient má své log adresáře
- Logy v paměti počítače

**TMP adresář (/tmp):**

Při více klientech všichni používají stejný `/tmp`. **Praktický příklad:**

- První klient spustí Firefox → vytvoří lock soubor v `/tmp/.mozilla-lock`
- Druhý klient chce spustit Firefox → vidí lock soubor a odmítne se spustit
- Stejný problém s dalšími aplikacemi!

**NFS protokol:** V produkci zvažte UDP místo TCP (lepší při výpadcích sítě).

### Úklid

Smažeme si některé balíčky, pokud už je nebudeme potřebovat. Totiž konfigurace zůstala ze setrveeru, takže pár služeb se nespustí a mohou dělat problémy:

```bash
apt remove isc-dhcp-server
apt remove nfs-kernel-server
apt remove tftpd-hpa
```

## Řešení problémů

### Časté problémy

1. **DHCP nefunguje**: Zkontroluj konfiguraci síťovky a stav služby
2. **NAT nefunguje**: Zkontroluj IP forwarding a nftables pravidla
3. **TFTP timeout**: Zkontroluj firewall a práva souborů
4. **NFS se nepřipojí**: Zkontroluj exporty a síťové připojení
5. **Boot se zasekne**: Zkontroluj kernel parametry a NFS konfiguraci

### Užitečné příkazy pro kontrolu

```bash
# Kontrola služeb
systemctl status isc-dhcp-server
systemctl status nfs-kernel-server
systemctl status tftpd-hpa

# Kontrola sítě
ip route
ip addr
nft list ruleset

# Kontrola NFS
exportfs -v
showmount -e localhost
```

## Závěr

Pokud všechno funguje, máš kompletní síťovou infrastrukturu pro bezdiskové pracovní stanice!

**Pozor:** Pokud necháme více klientů běžet delší dobu, můžou se začít sekat kvůli DHCP renewal a TCP problémům na NFS. To je normální - v produkci by se to řešilo jinými konfiguracemi. Údajně to už je vyřešené v novějších verzích služeb a kernelu, ale v kdysi to byl problém, tak to stojí za zmínku.
