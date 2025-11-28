# Cvičení 8: Mail server (SMTP/IMAP) a webový klient

Toto cvičení je zaměřeno na konfiguraci **mailového serveru** s protokoly SMTP (odchozí pošta) a IMAP (příchozí pošta), rozšíření DNS záznamů o mailové služby a nastavení webového emailového klienta **Roundcube**. Toto je pokračování předchozího cvičení o SMTP a IMAP serveru, ale díky technickým problémům na cvičení je rozděleno do samostatného úkolu.

## Co je mailový server

**Mailový server** je systém, který umožňuje odesílání, přijímání a ukládání emailových zpráv. Skládá se ze dvou hlavních částí:

- **SMTP server** (Simple Mail Transfer Protocol) - slouží pro odesílání emailů
- **IMAP/POP3 server** (Internet Message Access Protocol) - slouží pro přijímání a čtení emailů

V tomto cvičení budeme používat **Postfix** pro SMTP a **Dovecot** pro IMAP protokol.

### Důležité koncepty

**Maildir vs Mbox** - existují dva hlavní formáty pro ukládání emailů:

- **Mbox** - všechny emaily jsou uloženy v jednom souboru
- **Maildir** - každý email je samostatný soubor ve složce

Server pro příchozí a odchozí poštu může být na dvou různých serverech, které si musí sdílet souborový systém reprezentující emaily.

## Příprava prostředí

Budeme pokračovat s již existujícími servery z předchozích cvičení:

- **DNS server** (192.168.56.105) - pro přidání mailových DNS záznamů
- **LAMP server** (192.168.56.80) - pro webového mailového klienta
- **Mail server** (192.168.56.107) - nový server pro SMTP/IMAP služby

### Nastavení mailového serveru

Vytvořte si nový virtuální stroj nebo použijte existující server s IP adresou 192.168.56.107.

## Krok 1: Instalace a konfigurace Dovecot (IMAP server)

**Dovecot** je populární IMAP/POP3 server pro Linux systémy.

### Instalace Dovecot

```bash
apt update
apt install dovecot-imapd
```

### Konfigurace autentizace

Dovecot ve výchozím nastavení používá zabezpečené autentizační mechanismy. Pro naše testovací prostředí povolíme nezabezpečenou autentizaci.

Nejprve zkontrolujeme současné nastavení autentizace:

```bash
cat /etc/dovecot/conf.d/10-auth.conf | grep auth | grep -v "#" | grep -v "!"
```

Pokud není žádný výstup, upravíme konfigurační soubor:

```bash
nano /etc/dovecot/conf.d/10-auth.conf
```

Najdeme a odkomentujeme (odstraníme #) následující řádky:

```bash
# Povolíme základní autentizační mechanismy a nezabezpečené připojení
auth_mechanisms = plain login
auth_allow_cleartext = yes
```

### Konfigurace ukládání pošty

Změníme způsob ukládání emailů z výchozího mbox formátu na maildir:

```bash
nano /etc/dovecot/conf.d/10-mail.conf
```

Najdeme sekci s mail_location a upravíme ji takto:

```bash
# Zakomentujeme původní mbox nastavení
#mail_location = mbox:~/mail:INBOX=/var/mail/%u

# Přidáme nové maildir nastavení
mail_driver = maildir
mail_path = ~/Maildir
```

### Restart Dovecot služby

```bash
systemctl restart dovecot
systemctl enable dovecot
```

### Ověření funkčnosti

Zkontrolujeme, zda služba běží:

```bash
systemctl status dovecot
```

## Krok 2: Rozšíření DNS záznamů o mailové služby

Přejdeme na **DNS server** (192.168.56.105) a přidáme potřebné záznamy pro mailové služby.

### Přidání MX a A záznamů

```bash
nano /etc/bind/db.sli0124.cz
```

**Před úpravou souboru nezapomeňte zvýšit sériové číslo o 1!**

Do existující DNS zóny přidáme následující **nové záznamy** (ukázán celý soubor pro kontext):

```bash
$TTL 3h                            ;doba expirace všech záznamů
@       IN      SOA     ns1.sli0124.cz. spravce.sli0124.cz. (
                         2025102903 ; sériové číslo - ZVÝŠENO O 1!
                         4h         ; jak často si stahuje data sekundární server
                         2h         ; za jak dlouho se má sek.server pokusit stáhnout data při neúspěchu
                         2w         ; kdy platnost dat v sek.serveru vyprší
                         1h )       ; jak dlouho si mají data pamatovat cache servery
;
@       IN      NS      ns1.sli0124.cz.
@       IN      NS      ns2.sli0124.cz.

; NOVĚ PŘIDANÉ: MX záznamy pro emailový server
sli0124.cz.    IN      MX      10      smtp.sli0124.cz.  ; primární emailový server
sli0124.cz.    IN      MX      20      smtp2.sli0124.cz. ; sekundární emailový server

; Existující A záznamy
sli0124.cz.    IN      A       192.168.56.105
ns1            IN      A       192.168.56.105
ns2            IN      A       192.168.56.106
www            IN      CNAME   sli0124.cz.
wiki           IN      CNAME   sli0124.cz.
test           IN      CNAME   sli0124.cz.
subdomena1     IN      A       192.168.56.105
subdomena2     IN      CNAME   sli0124.cz.
www1           IN      A       192.168.56.105
www2           IN      A       192.168.56.105

; NOVĚ PŘIDANÉ: A záznamy pro mailové servery
smtp           IN      A       192.168.56.107
smtp2          IN      A       192.168.56.107
imap           IN      A       192.168.56.107

; NOVĚ PŘIDANÉ: SRV záznamy pro mailové služby
_imap._tcp     IN      SRV    1 2 143  imap.sli0124.cz.
_smtp._tcp     IN      SRV    1 2 25   smtp.sli0124.cz.

; Existující SRV záznamy
_http._tcp     IN      SRV     1 2 80  www1
               IN      SRV     5 3 80  www2

_http._tcp.www IN      SRV     1 2 80  www1.sli0124.cz.
               IN      SRV     5 3 80  www2.sli0124.cz.

*._tcp         IN      SRV     0 0 0   .  ;ostatní služby nejsou podporovány
alias          IN      CNAME   www.sli0124.cz.
```

### Ověření konfigurace DNS

```bash
named-checkzone sli0124.cz /etc/bind/db.sli0124.cz
```

Pokud je vše v pořádku, restartujeme BIND9:

```bash
systemctl reload bind9
```

## Krok 3: Testování IMAP služby

Nyní můžeme otestovat IMAP službu pomocí emailového klienta jako je **Thunderbird**.

### Nastavení v Thunderbird

1. Spusťte Thunderbird
2. Přidejte nový účet s těmito údaji:
   - **Email:** `sli124@sli0124.cz`
   - **Heslo:** sli124
   - **IMAP server:** 192.168.56.107
   - **Port:** 143
   - **Zabezpečení:** None (Žádné)
   - **Autentizace:** Normal password

### Vytvoření testovacího uživatele

Uživatelé by již měli být vytvořeni z předchozích cvičení. Pokud ne, vytvořte uživatele sli124:

```bash
useradd -m -s /bin/bash sli124
passwd sli124
# Zadejte heslo: sli124
```

### Test odesílání emailů

Pokud se úspěšně přihlásíte, můžete si poslat email sami sobě nebo mezi různými účty pro ověření funkčnosti.

## Krok 4: Příprava databáze pro Roundcube

Přejdeme na **LAMP server** (192.168.56.80) a připravíme databázi pro webový emailový klient.

### Vytvoření databáze a uživatele

```bash
mysql
```

V MySQL konzoli:

```sql
-- Vytvoření uživatele pro Roundcube
CREATE USER 'roundcube'@'localhost' IDENTIFIED BY 'roundcube';

-- Vytvoření databáze
CREATE DATABASE roundcube;

-- Přidělení práv
USE roundcube;
GRANT ALL ON roundcube.* TO roundcube@localhost;

-- Odchod z MySQL
\q
```

## Krok 5: Instalace Roundcube

### Instalace balíčku

```bash
apt update
apt install roundcube
```

Během instalace:

- Vyberte **Yes/Ano** pro automatickou konfiguraci databáze
- Zadejte heslo: **roundcube**
- Potvrďte heslo: **roundcube**

### Přidání DNS záznamu pro Roundcube

Na **DNS serveru** přidáme záznam pro roundcube:

```bash
nano /etc/binddb.sli0124.cz
```

Přidáme řádek do sekce s A záznamy (nezapomeneme zvýšit sériové číslo):

```bash
# V sekci s ostatními A a CNAME záznamy přidáme:
www2           IN      A       192.168.56.105
imap           IN      A       192.168.56.107
lamp           IN      A       192.168.56.80
roundcube      IN      CNAME   lamp.sli0124.cz.  ; <-- NOVĚ PŘIDANÝ ŘÁDEK

; SRV záznamy pro mailové služby
_imap._tcp     IN      SRV    1 2 143  imap.sli0124.cz.
```

Ověříme a restartujeme:

```bash
named-checkzone sli0124.cz /etc/bind/db.sli0124.cz
systemctl reload bind9
```

## Krok 6: Konfigurace Apache pro Roundcube

Na **LAMP serveru** vytvoříme nový virtuální host:

### Vytvoření konfigurace

```bash
cd /etc/apache2/sites-available
cp wiki.sli0124.cz.conf roundcube.sli0124.cz.conf
```

Upravíme novou konfiguraci:

```bash
nano roundcube.sli0124.cz.conf
```

Změníme následující řádky:

```apache
<VirtualHost *:80>
    ServerName roundcube.sli0124.cz
    DocumentRoot /var/www/roundcube.sli0124.cz
    
    # Zbytek konfigurace zůstává stejný...
</VirtualHost>
```

### Povolení webu

```bash
a2ensite roundcube.sli0124.cz
systemctl reload apache2
```

### Vytvoření symbolického odkazu

```bash
cd /var/www/
ln -s /usr/share/roundcube roundcube.sli0124.cz
```

## Krok 7: Konfigurace Roundcube

### Nastavení připojení k mailových serverům

```bash
nano /etc/roundcube/config.inc.php
```

Najdeme a upravíme následující řádky:

```php
// IMAP server
$config['imap_host'] = ['192.168.56.107:143'];

// SMTP server  
$config['smtp_host'] = '192.168.56.107:25';

// SMTP autentizace - vypneme pro naše testovací prostředí
$config['smtp_user'] = '';  // smtp se nebude přihlašovat
$config['smtp_pass'] = '';  // smtp se nebude přihlašovat
```

Původní řádky zakomentujeme:

```php
//$config['smtp_user'] = '%u';
//$config['smtp_pass'] = '%p';
```

## Krok 8: Testování webového rozhraní

### Přístup k Roundcube

Otevřete webový prohlížeč a přejděte na:

```plaintext
roundcube.sli0124.cz
```

### Přihlášení

Použijte tyto údaje:

- **Uživatel:** sli0124
- **Heslo:** sli0124

### Testování synchronizace

Po úspěšném přihlášení:

1. **Zkontrolujte v Thunderbird**, zda se email objevil
2. **Smažte email** z webového rozhraní
3. **Ověřte v Thunderbird**, že se smazání projevilo i tam

Posílání emailů není na webovém klientu nakonfigurováno, takže tuto funkci nebudeme testovat.
