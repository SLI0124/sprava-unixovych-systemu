# 1. Změna hostname
hostnamectl set-hostname smtp-imap

# 2. Konfigurace statické IP adresy
cat >> /etc/network/interfaces << 'EOF'

# Statická konfigurace pro enp0s8
#iface enp0s8 inet dhcp
allow-hotplug enp0s8
iface enp0s8 inet static
        address 192.168.56.107
        netmask 255.255.255.0
EOF

# Aktivace síťového rozhraní
ifup enp0s8

# 3. Konfigurace DNS
echo "nameserver 192.168.56.105" > /etc/resolv.conf

# 4. Instalace potřebných balíčků
apt update
apt install -y dnsutils net-tools telnet

# 5. Instalace Postfix (interaktivní - je třeba nastavit ručně)
apt install -y postfix

# 6. Konfigurace relay - povolení odesílání z lokální sítě
sed -i 's/mynetworks = .*/mynetworks = 127.0.0.0\/8 [::ffff:127.0.0.0]\/104 [::1]\/128 192.168.56.0\/24/' /etc/postfix/main.cf

# 7. Přidání nového uživatele
useradd -m sli124

# 8. Konfigurace aliasů
cat >> /etc/aliases << 'EOF'
postmaster:    root
studenti: sli0124@sli0124.cz, sli124@sli0124.cz
borec: sli0124@sli0124.cz
EOF

# Aplikace aliasů
newaliases

# 9. Konfigurace kanonických názvů
echo "sli0124 vojtech.sliva" > /etc/postfix/canonical
postmap /etc/postfix/canonical

# Přidání canonical maps do main.cf
echo "canonical_maps = hash:/etc/postfix/canonical" >> /etc/postfix/main.cf

# 10. Konfigurace Maildir
echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf

# 11. Vytvoření Maildir struktury pro existující uživatele
mkdir -p /home/sli0124/Maildir/{cur,new,tmp}
chown -R sli0124:sli0124 /home/sli0124/Maildir
chmod -R 700 /home/sli0124/Maildir

mkdir -p /home/sli124/Maildir/{cur,new,tmp}
chown -R sli124:sli124 /home/sli124/Maildir
chmod -R 700 /home/sli124/Maildir
