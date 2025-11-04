# Cvičení 6: LAMP

## Co to je LAMP?

**LAMP** je akronym pro kombinaci technologií používaných pro webové servery:

- **L**inux - operační systém
- **A**pache - webový server
- **M**ySQL/MariaDB - databázový server  
- **P**HP - skriptovací jazyk pro dynamické webové stránky

Tato kombinace je základem pro většinu moderních webových aplikací a umožňuje vytváření dynamických webových stránek s databázovým backend.

## Prerekvizity

Budeme potřebovat:

- **DNS 1 a 2** z předchozího cvičení (link uděláme pouze na DNS 1, DNS 2 může být vypnutý, je to jen záloha)
- **Nový virtuální stroj LAMP**
- **Nějaký způsob zobrazení** webových stránek:
  - Skrze terminálový prohlížeč (elinks, w3m, lynx)
    - Udělat si kopii base serveru pro testování stránek
  - Na nativním hostovi (museli bychom změnit DNS na DNS 1)

### Různé možnosti testování

Máme několik možností, jak testovat naše webové stránky:

1. **Terminálový prohlížeč** - nejjednodušší, použijeme elinks
2. **Nativní host** - stačilo by nastavit DNS na Linux v `/etc/resolv.conf` (pro Windows nevím kde)
3. **Kopie base serveru** - ale spousta nemá Linux a na učebnách nejsou root práva

## Příprava prostředí

### Nastavení DNS resolver

**Důležité:** Nastavte si v `/etc/resolv.conf` DNS server DNS1 pro každý virtuální stroj, pro jistotu radši zakomentujte to, co tam je:

```bash
nano /etc/resolv.conf
```

```bash
# domain vsb.cz
# search vsb.cz.
#nameserver 158.196.0.53
#nameserver 158.196.148.166
nameserver 192.168.56.105
```

Teď by měl fungovat ping na `www.sli0124.cz`.

**Připomenutí:** Předtím jsme testovali DNS skrze nslookup a dané DNS:

- `nslookup sli0124.cz 192.168.56.105` (vzdálený test na DNS serveru)
- `nslookup sli0124.cz 127.0.0.1` (lokální test přímo na DNS serveru)

### Nastavení statické IP adresy

Je zvykem, že pokud běží služba na portu, dát tomu poslední adresu toho portu, ale nemusí to tak být. Port 80 je snadno zapamatovatelný:

```bash
nano /etc/network/interfaces
```

Obsah bude vypadat takto:

```bash
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug enp0s3
iface enp0s3 inet dhcp
# This is an autoconfigured IPv6 interface
iface enp0s3 inet6 auto

# iface enp0s8 inet dhcp

allow-hotplug enp0s8
iface enp0s8 inet static
        address 192.168.56.80
        netmask 255.255.255.0
```

Ještě pro jistotu si můžeme přejmenovat počítač na LAMP:

```bash
hostnamectl set-hostname lamp
# Možná bude dobré znova otevřít SSH terminál
```

## LAMP - rozběhnutí

### Instalace Apache

Na LAMP server musíme nainstalovat Apache, ten umí snad všechno s webovým serverem:

```bash
apt update
apt install apache2
```

Instalováním balíčku se služba spustila sama, můžeme to ověřit, že když na nativním PC spustíme IP adresu LAMP serveru, tak dostaneme uvítací web.

Do Chromu/Firefoxu na vlastním PC zadejte IP adresu LAMP serveru, v našem případě `192.168.56.80`.

### Přidání PHP

Pro lepší a komplikovanější weby si stáhneme PHP:

```bash
apt install libapache2-mod-php
```

Pro jistotu teď restartujeme službu:

```bash
service apache2 restart
```

### Test PHP

Defaultně se ty stránky nacházejí ve složce `/var/www/html`. Tam je `index.html`, což se právě zobrazuje.

Pojďme si přejmenovat `index.html` na `index.php` a v něm upravíme následující:

```bash
cd /var/www/html
mv index.html index.php
nano index.php
```

Upravíme začátek souboru:

```php
<?php phpinfo(); ?>

<!DOCTYPE html PUBLIC ...
```

Pokud obnovíme LAMP server v prohlížeči, tak naskočí PHP info skript, tedy PHP nám funguje!

## Jak nastavujeme LAMP

Vše se děje ve složce `/etc/apache2`:

- **`apache2.conf`** - v něm jsou odkazy na další kousky nastavení pro Apache
- **`envvars`** - jsou proměnné, které Apache používá
- **`magic`** - samovysvětlující
- **`ports.conf`** - na kterých portech poslouchá
- **`*-available` a `*-enabled`** (conf, mods, sites) - všechny možné konfigurace, moduly nebo stránky, které může Apache obsluhovat a enabled je povolení těchto možností

### Sites-available vs sites-enabled

V `sites-available` je tam default pro zprovoznění stránky. Uvnitř najdeme adresu správce, document root je fyzické uložení a místo, kde se stránky nacházejí a logování.

Ale v `sites-enabled` tam nejsou, tedy není to aktivní adresa. Ručně je nebudeme spouštět, ale skrze příkazy.

### Moduly

`mods-available` jsou dostupné moduly (funkce), které Apache umí spustit. Jeden modul je i PHP, co se spustilo odtud během instalace.

### Odbočka (nemusíme dělat): Module userdir

> **Warning:** Tato sekce je volitelná a nemusí se dělat v rámci základního úkolu.

Pokud si nějaký uživatel (musí být vlastníkem) v jeho home složce založí složku `public_html`, tak bude brán jako webový prostor daného uživatele.

To je vše specifikováno v `/etc/apache2/mods-available/userdir.conf`, load logicky načítá kód do běhu serveru.

Povolíme pomocí příkazu a2 (umí spoustu jako dis or en, conf site a mod):

```bash
a2enmod userdir
```

Chce to po nás restart service:

```bash
systemctl restart apache2
```

Teď se na virtuálním počítači spustíme další konzoli skrze `Alt+F2`, přihlásím se pod loginem, vytvořím si v `~/` (tedy home) složku public_html a v ní index.html:

```bash
# Na druhém terminálu (Alt+F2)
mkdir public_html
cd public_html
echo "Hello from SLI0124!" > index.html
```

Pokud jsme pracovali správně, tak v prohlížeči pod loginem se objeví zpráva z adresáře uživatele: `http://192.168.56.80/~sli0124/`

Vše by mělo fungovat, můžeme se odhlásit z druhého terminálu skrze `Alt+D` nebo `exit` a přepnout se zpět do hlavního terminálu skrze `Alt+F1`.

## Více webových stránek na jedné IP adrese

Podle hlavičky GET požadavku se rozlišuje, kterou stránku vrátí. IP je vždy stejná pro různé stránky, ale podle hlavičky pošle jiné stránky.

### Přidání DNS záznamů

Abychom přiřadili normální doménu, musíme na **kopii DNS 1 serveru** pro LAMP upravit soubor `/etc/bind/db.sli0124.cz`.

Máme dva způsoby:

1. Buď změníme odkaz `sli0124.cz.` na IP adresu LAMP serveru, nebo
2. Uděláme A záznam pro LAMP server

Existuje více postupů. U prvního způsobu bychom museli všude, kde je IP adresa domeny z DNS 1 na LAMP server.

Druhý způsob je zmíněn ve videu a přijde mi jednodušší - uděláme `lamp` A záznam, a na odkazy `wiki.`, `test.`, `whatever.` bude odkazovat na LAMP server.

**A taky musíme změnit sériové číslo!**

Celý záznam:

```bind
$TTL 3h                            ;doba expirace všech záznamů
@       IN      SOA     ns1.sli0124.cz. spravce.sli0124.cz. (  ; autoritativní DNS server + email správce bez @
                         2025110400 ; seriové číslo, často ve formě data - ZMĚNIT!
                         4h         ; jak často si stahuje data sekundární server
                         2h         ; za jak dlouho se má sek.server pokusit stáhnout data při neúspěchu
                         2w         ; kdy platnost dat v sek.serveru vyprší
                         1h )       ; jak dlouho si mají data pamatovat cache servery
;
@       IN      NS      ns1.sli0124.cz. ; autoritativní servery pro doménu
@       IN      NS      ns2.sli0124.cz. 

sli0124.cz.    IN      MX      10      smtp.sli0124.cz.  ; primární emailový server
sli0124.cz.    IN      MX      20      smtp2.sli0124.cz. ; sekundární emailový server
sli0124.cz.    IN      A       192.168.56.105            ; primární záznam
ns1            IN      A       192.168.56.105
ns2            IN      A       192.168.56.106
smtp           IN      A       192.168.56.105
smtp2          IN      A       192.168.56.106
lamp           IN      A       192.168.56.80              ; NOVĚ PŘIDÁNO
www            IN      CNAME   lamp.sli0124.cz.           ; NOVĚ PŘIDÁNO
wiki           IN      CNAME   lamp.sli0124.cz.          ; NOVĚ PŘIDÁNO
mail           IN      CNAME   lamp.sli0124.cz.          ; NOVĚ PŘIDÁNO
test           IN      CNAME   lamp.sli0124.cz.          ; NOVĚ PŘIDÁNO
subdomena1     IN      A       192.168.56.105
subdomena2     IN      CNAME   sli0124.cz.
www1           IN      A       192.168.56.105
www2           IN      A       192.168.56.105

_http._tcp     IN      SRV     1 2 80  www1
               IN      SRV     5 3 80  www2

_http._tcp.www IN      SRV     1 2 80  www1.sli0124.cz.
               IN      SRV     5 3 80  www2.sli0124.cz.

*._tcp         IN      SRV     0 0 0   .  ;ostatní služby nejsou podporovány
alias          IN      CNAME   www.sli0124.cz.
```

Potvrdíme změny:

```bash
service bind9 restart
```

A vyzkoušíme, jestli se propagoval nový záznam:

```bash
nslookup www.sli0124.cz 127.0.0.1
```

Výstup by měl být:

```bash
Server:         127.0.0.1
Address:        127.0.0.1#53

www.sli0124.cz  canonical name = lamp.sli0124.cz.
Name:   lamp.sli0124.cz
Address: 192.168.56.80
```

Je tam adresa na LAMP server, paráda! DNS je vyřešena.

### Test DNS na LAMP serveru

Zkusíme na LAMP serveru nslookup:

```bash
apt install dnsutils
nslookup www.sli0124.cz
```

Výstup:

```bash
Server:         192.168.56.105
Address:        192.168.56.105#53

www.sli0124.cz  canonical name = lamp.sli0124.cz.
Name:   lamp.sli0124.cz
Address: 192.168.56.80
```

## Příprava testovacího systému

Teď si spustíme systém pro testování webového interface. Nastavíme si unikátní IP adresu v `/etc/network/interfaces`:

```bash
#iface enp0s8 inet dhcp
allow-hotplug enp0s8
iface enp0s8 inet static
        address 192.168.56.110
        netmask 255.255.255.0
```

A do `/etc/resolv.conf` přidat DNS pro LAMP server:

```bash
nameserver 192.168.56.105
```

A reboot (po reboot znova nastavit `/etc/resolv.conf`).

### Instalace textového prohlížeče

Na prohlížení webu jsou dostupné např. `w3m`, `lynx`, `elinks` a mnoho dalších. Nainstalujeme si třeba elinks:

```bash
apt install elinks
elinks www.sli0124.cz
# Odchází se stisknutím 'q' a potvrzením "Yes"
```

Teď se nám zobrazí phpinfo defaultní stránky na doméně, paráda!

Jeden si může všimnout, že na tuto defaultní stránku nás nasměruje i `wiki.sli0124.cz`, `test.sli0124.cz` atd. To si teď nastavíme.

## WWW stránka

Na LAMP serveru:

```bash
cd /var/www
```

Bývá zvykem vytvořit složku stejně tak, jak se jmenuje doména, tedy:

```bash
mkdir www.sli0124.cz
cd www.sli0124.cz
echo "Hello from sli0124!" > index.html
```

Stránku máme vytvořenou, teď ji musíme povolit v config souborech Apache:

```bash
cd /etc/apache2/sites-available
cp 000-default.conf www.sli0124.cz.conf # na konci musí být .conf
```

Teď upravíme všechny data v tomto souboru:

```bash
nano www.sli0124.cz.conf
```

Změníme:

```apache
...
# However, you must set it for any further virtual host explicitly.
ServerName www.sli0124.cz

ServerAdmin webmaster@sli0124.cz
DocumentRoot /var/www/www.sli0124.cz

# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
...
```

Teď příkazy zakážeme defaultní stránky a povolíme jednotlivé ostatní domény:

```bash
a2dissite 000-default
systemctl reload apache2
a2ensite www.sli0124.cz
systemctl restart apache2
```

Na zkušebním terminálu zkusíme:

```bash
elinks www.sli0124.cz
# Měli bychom dostat "Hello from sli0124!"
```

## Nastavení wiki virtuálního hostu

```bash
cd /var/www
mkdir wiki.sli0124.cz
cd wiki.sli0124.cz
echo "Hello from wiki!" > index.html
```

```bash
cd /etc/apache2/sites-available
cp www.sli0124.cz.conf wiki.sli0124.cz.conf
nano wiki.sli0124.cz.conf
```

Změníme:

```apache
...
# However, you must set it for any further virtual host explicitly.
ServerName wiki.sli0124.cz

ServerAdmin webmaster@sli0124.cz
DocumentRoot /var/www/wiki.sli0124.cz

# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
...
```

```bash
a2ensite wiki.sli0124.cz
systemctl reload apache2
```

Na grafickém terminálu vyzkoušíme:

```bash
elinks wiki.sli0124.cz
```

A měli bychom dostat odpověď "Hello from wiki!"

Máme nastavenou doménu wiki a se pustíme do stažení MariaDB pro MediaWiki.

### MariaDB

Kdysi to býval MySQL, ale už není úplně open-source, tak to nahradili MariaDB:

```bash
apt install default-mysql-server # instaluje to MariaDB
```

```bash
mysql -u root -p
```

V MariaDB konzoli:

```sql
CREATE DATABASE wiki;
USE wiki;
CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'wiki';
GRANT ALL ON wiki.* TO wiki@localhost;
\q
```

Databázi máme, na ni chceme spustit aktuální MediaWiki, tu si musíme stáhnout na mediawiki.org → Download → (on download) copy link.

```bash
cd /root/
apt install unzip wget
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.2.zip
unzip mediawiki-1.44.2.zip

cp -r mediawiki-1.44.2/* /var/www/wiki.sli0124.cz/
cd /var/www/wiki.sli0124.cz/
rm index.html
```

Teď by mělo v webové konzoli ukázat, že nám chybí nějaké balíčky, u mě to byly:

```bash
apt install php-mbstring php-xml php-mysql php-intl # popřípadě doinstalovat ostatní
```

Pokud se vše podařilo, měli bychome dostat chybu, že `LocalSettings.php not found`.

### Webová konfigurace MediaWiki

Nastavte si na Linux počítači v `/etc/resolv.conf` DNS serveru naši (pro Windows nevím, jak se to dělá), nebo použijte elinks, tady budu používat elinks, ale skrze web je to samé.

Posunujeme se šipkami nahoru a dolů, enterem se dostaneme na zadávání do pole, šipkami nahoru a dolů jdeme pryč.

#### Language

Šipkami se dostante k volbě a enterem na CS nebo ENG, enterem jsme si našel cs. Potvrďte POST požadavek.

#### Vítejte v MediaWiki

Pokračovat → POST

#### Připojení k databázi

- Databázový server: `localhost`
- Jméno databáze: `wiki`
- Prefix databázových tabulek: `wiki` (může být prázdné)
- Uživatelský účet pro instalaci: `wiki`
- Databázové heslo: `wiki`

Pokračovat → POST

#### Nastavení databáze

- Databázové uživatelské jméno: `sli0124`
- Heslo: `sli0124`

#### Název

- Název hostitele v URL (ponechat)
- Název wiki: `sli0124`
- Jmenný prostor projektu (zaškrtnout jiný, uvést): `Wiki SLI0124`

**Správcovský účet:**

- Uživatelské jméno: `sli0124`
- Heslo (musí být dlouhé alespoň 10 znaků): `sli0124sli0124`
- Heslo ještě jednou: `sli0124sli0124`
- Emailová adresa: (nechat prázdné)

Necháme si zaškrtnutou možnost "Už mě to nudí, prostě nainstaluj wiki", kdybyste chtěli, tak zvolte "Ptej se mě dál".

> **Poznámka:** Mně se stalo, malé okno se seklo na instalaci, doporučuji zvětšit na plné okno.

Pokračovat → POST

#### Instalovat

Pokračovat → POST

#### Restartovat instalaci

Pokračovat → POST

A ještě jednou, dokud neuvidím **stáhnout LocalSettings.php**. Enterem kliknu na odkaz a dám save (tohle už nebude potom dostupné, nevypínat/obnovovat dokud nevíme, kde ten soubor skutečně je a existuje).

Teď se nám uložilo `LocalSettings.php` do `/root/LocalSettings.php` na tom web terminálu virtuálním počítači.

Takže z něj to pošleme na LAMP server buď z nového SSH terminálu, nebo skrze virtuální počítač:

```bash
scp LocalSettings.php sli0124@192.168.56.80:
```

Pokud se na LAMP serveru podíváme do `/home/sli0124/`, tak tam najdeme naše `LocalSettings.php`:

```bash
cp /home/sli0124/LocalSettings.php /var/www/wiki.sli0124.cz/
```

Teď by mělo vše fungovat!

## Test stránka

```bash
cd /var/www
mkdir test.sli0124.cz
cd test.sli0124.cz
nano index.php # AI
```

Vložíme kompletní PHP kód se styly a server info (použijeme AI nebo napíšeme vlastní):

```php
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test stránka SLI0124</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Test stránka SLI0124</h1>

        <div class="info">
            <h2>Server Info:</h2>
            <p><strong>Aktuální čas:</strong> <?php echo date('d.m.Y H:i:s'); ?></p>
            <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
            <p><strong>PHP verze:</strong> <?php echo phpversion(); ?></p>
            <p><strong>Vaše IP:</strong> <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
        </div>

        <div class="info">
            <h2>PHP Test:</h2>
            <?php
            $cisla = [1, 2, 3, 4, 5];
            $soucet = array_sum($cisla);
            echo "<p>Součet čísel " . implode(", ", $cisla) . " = <strong>$soucet</strong></p>";
            ?>
        </div>
    </div>
</body>
</html>
```

```bash
cd /etc/apache2/sites-available
cp www.sli0124.cz.conf test.sli0124.cz.conf
nano test.sli0124.cz.conf
```

Změníme:

```apache
<VirtualHost *:80>
    ServerName test.sli0124.cz

    ServerAdmin webmaster@sli0124.cz
    DocumentRoot /var/www/test.sli0124.cz

    ErrorLog ${APACHE_LOG_DIR}/test.sli0124.cz-error.log
    CustomLog ${APACHE_LOG_DIR}/test.sli0124.cz-access.log combined
</VirtualHost>
```

```bash
a2ensite test.sli0124.cz
systemctl reload apache2
```

Na testovacím virtuálním počítači (nebo přes elinks na LAMP serveru):

```bash
elinks test.sli0124.cz
```

Měli byste vidět testovací stránku s informacemi o serveru a jednoduchým PHP výpočtem.
