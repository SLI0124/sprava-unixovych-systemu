# Cvičení 5: DNS

Toto cvičení je zaměřeno na konfiguraci **DNS serveru pomocí BIND9** v distribuci Debian. Budeme vytvářet primární a sekundární DNS servery, které budou obsluhovat vlastní doménu.

## Co je DNS

**Domain Name System (DNS)** je hierarchický systém pro překlad doménových jmen na IP adresy a naopak. Funguje jako "telefonní seznam" internetu, který umožňuje uživatelům používat snadno zapamatovatelná jména místo složitých číselných IP adres.

DNS funguje na principu distribuované databáze organizované do hierarchické stromové struktury. Na vrcholu této hierarchie se nachází root servery (označované tečkou "."), pod nimi jsou top-level domény (.com, .cz, .eu), a dále se struktura větví až k jednotlivým hostům.

### Důležité koncepty DNS

**Mylně se můžeme domnívat, že pokud vytvoříme doménu, je dostupná na internetu** - to ovšem není pravda! Museli bychom za nějakým správcem zaplatit si u něj doménu a on by zařídil překlad této domény na IP adresu, zveřejnil pro všechny ostatní na širokém webu tento překlad.

My chceme, aby DNS probíhal na našem serveru a ne na školním nebo VirtualBox DNS serveru. Cílem bude zprovoznit naši vlastní doménu pouze v našem lokálním prostředí.

## Příprava prostředí

Před začátkem práce si připravte dva virtuální stroje z předchozích cvičení:

1. **DNS1** (primární server) - IP: 192.168.56.105 (*vše je nastaveno automaticky, u Vás se IP adresy mohou lišit*)
2. **DNS2** (sekundární server) - IP: 192.168.56.106

Oba stroje nastavte s dvojicí síťových adaptérů:

- První adaptér: NAT (pro přístup k internetu)
- Druhý adaptér: Host-only adapter (vboxnet0)

### Pojmenování počítačů

Je dobré si pojmenovat počítače tak, abyste se v nich lépe orientovali. Doporučuji nastavit hostname:

**Na prvním serveru (DNS1):**

```bash
# Změna hostname na dns1
hostnamectl set-hostname dns1

# Nebo editací souboru (starší způsob)
echo "dns1" > /etc/hostname

# Restart pro aplikování změn
reboot
```

**Na druhém serveru (DNS2):**

```bash
# Změna hostname na dns2
hostnamectl set-hostname dns2

# Nebo editací souboru (starší způsob)
echo "dns2" > /etc/hostname

# Restart pro aplikování změn
reboot
```

Po restartu uvidíte nové jméno v command promptu (např. `root@dns1:~#` místo `root@debian:~#`).

### Konfigurace statické IP adresy

Pro správnou funkci DNS serverů je důležité nastavit statické IP adresy. Upravte soubor `/etc/network/interfaces`:

**Na prvním serveru (DNS1) - IP: 192.168.56.105:**

```bash
nano /etc/network/interfaces
```

```ini
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface (NAT)
auto enp0s3
iface enp0s3 inet dhcp

# Host-only network interface (static IP)
auto enp0s8
iface enp0s8 inet static
    address 192.168.56.105
    netmask 255.255.255.0
```

**Na druhém serveru (DNS2) - IP: 192.168.56.106:**

```bash
nano /etc/network/interfaces
```

```ini
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface (NAT)
auto enp0s3
iface enp0s3 inet dhcp

# Host-only network interface (static IP)
auto enp0s8
iface enp0s8 inet static
    address 192.168.56.106
    netmask 255.255.255.0
```

Po úpravě restartujte síťové služby:

```bash
systemctl restart networking
```

Nebo restartujte celý systém pro jistotu:

```bash
reboot
```

## Krok 1: Instalace potřebných balíčků

Na obou serverech nainstalujte BIND9 a pomocné nástroje:

```bash
apt update
apt install bind9 dnsutils ldnsutils
```

### Co jsme nainstalovali

- **BIND9**: Berkeley Internet Name Domain verze 9 - jeden z nejpoužívanějších DNS serverů na světě
- **dnsutils**: Balíček obsahující nástroje jako `nslookup`, `dig`, `host` pro testování DNS
- **ldnsutils**: Další užitečné DNS nástroje

### Testování DNS nástrojů

Po instalaci můžete otestovat základní funkčnost DNS:

```bash
# Test překladu doménového jména (v tuto chvíli ještě funguje přes školní/VirtualBox DNS)
nslookup www.vsb.cz
```

> **Poznámka**: Ping nemusí fungovat, ale to nevadí - důležité je, že se umí přeložit doménové jméno na IP adresu. Kromě pingu jsme si zjistili, že se umí přeložit doménové jméno na IP adresu - což je přesně to, co DNS má dělat!

## Krok 2: Konfigurace primárního DNS serveru

### Pracovní adresář

Budeme pracovat v adresáři `/etc/bind`, kde najdete spoustu konfiguračních souborů. Pokud se do nich podíváte, asi vám dojde, co dělají:

- **`named.conf.options`**: Uvnitř je položka `forwarders`, která říká, která je nadřazená DNS. Zakomentované znamená, že používáme DNS internetu.
- **`named.conf.local`**: Jsou uvedeny zóny RFC1918, což jsou zóny, které se nepoužívají nikde na internetu a jen na privátních sítích.
- **Soubory `db.*`**: Zónové soubory, za tečkou je zóna, o kterou se starají.

### Teorie: Co jsou zóny a autoritativní servery

**Zóna** je část DNS jmenného prostoru, za kterou je konkrétní DNS server zodpovědný. Například zóna `sli0124.cz` obsahuje všechny DNS záznamy pro doménu `sli0124.cz` a její subdomény.

**Autoritativní server** je DNS server, který má originální a konečné informace o konkrétní zóně. Když se někdo zeptá na záznam z této zóny, autoritativní server odpoví s příznakem "AA" (Authoritative Answer).

### Teorie: SOA záznam (Start of Authority)

SOA záznam je nejdůležitější záznam v každé DNS zóně. Obsahuje:

- **Primární DNS server**: Hlavní server zodpovědný za zónu
- **Email správce**: Kontakt na administrátora (tečka nahrazuje @)
- **Sériové číslo**: Verze zóny - při každé změně se musí zvýšit!
- **Refresh**: Jak často sekundární server kontroluje aktualizace
- **Retry**: Jak dlouho čekat při neúspěšném pokusu o aktualizaci
- **Expire**: Kdy sekundární server přestane odpovídat, pokud nemůže kontaktovat primární
- **Minimum TTL**: Minimální doba cache pro záporné odpovědi

### Teorie: DNS záznamy

#### Rozdelení jednotlivých záznamů

- **A**: Záznam, který definuje překlad domény na IP adresu (AAAA je pro IPv6)
- **MX**: Je pro mailové služby
- **CNAME**: Symbolický link/zástupce
  - Pokud někdo zavolá CNAME záznam, zavolá se IP adresa dané domény
  - Používá se tehdy, kdy mám spoustu domén, stačí to změnit pouze na jednom místě a ne pro každou službu
- **SRV**: Málo používaný, využívá se pro určení, který server se stará o danou službu dané domény
  - Pokud využívám TCP a UDP, funguje na www  
  - Dále se nastavuje priorita a váha pro load balancing
- **NS**: Autoritativní servery pro doménu, musí mít i A záznamy
- **PTR**: Používá se pro reverzní DNS (IP adresa → doménové jméno)

#### Důležitá syntaktická pravidla

- **Správce nemá @**: Protože se nahrazuje první tečka
- **Sériové číslo**: Při každé změně se musí inkrementovat, je zvykem udávat datum: YYYYMMDDNN, kdy NN je počet pro daný den
- **Dva jmenné servery**: Primární a sekundární, pokud nefunguje jeden, nahradí jej druhý
- **Tečka na konci u MX**: Například u mailového serveru `MX` je tečka na konci, tedy za `.cz.` - ta tečka tam musí být, protože to je kořen toho stromu, ten nejvrchnější, od té tečky se vše větví
- **Za NS1 a NS2**: Už nepíšeme tečku, když to nenapíšu, automaticky se tam to doplní

### Vytvoření zónového souboru

Vytvořte soubor `/etc/bind/db.sli0124.cz`:

```bash
nano /etc/bind/db.sli0124.cz
```

Zkopírujte následující obsah a **všude, kde je `example`, nahraďte za `sli0124`** (prostě svůj login):

```bind
$TTL 3h                    ;doba expirace všech záznamů
@       IN      SOA     ns1.sli0124.cz. spravce.sli0124.cz. (  ; autoritativní DNS server + email správce bez @
                         2025102700 ; seriové číslo, často ve formě data
                         4h         ; jak často si stahuje data sekundární server
                         2h         ; za jak dlouho se má sek.server pokusit stáhnout data při neúspěchu
                         2w         ; kdy platnost dat v sek.serveru vyprší
                         1h )       ; jak dlouho si mají data pamatovat cache servery
;
@       IN      NS      ns1.sli0124.cz. ; autoritativní servery pro doménu, musí mít i A záznamy
@       IN      NS      ns2.sli0124.cz. ; autoritativní servery pro doménu, musí mít i A záznamy

sli0124.cz.    IN      MX      10      smtp.sli0124.cz.  ; primární emailový server
sli0124.cz.    IN      MX      20      smtp2.sli0124.cz. ; sekundární emailový server
sli0124.cz.    IN      A       192.168.56.105           ; primární záznamy
ns1            IN      A       192.168.56.105
ns2            IN      A       192.168.56.106
smtp           IN      A       192.168.56.105
smtp2          IN      A       192.168.56.106
www            IN      CNAME   sli0124.cz.
wiki           IN      CNAME   sli0124.cz.
test           IN      CNAME   sli0124.cz.
subdomena1     IN      A       192.168.56.105
subdomena2     IN      CNAME   sli0124.cz.
www1           IN      A       192.168.56.105
www2           IN      A       192.168.56.105

_http._tcp     IN      SRV     1 2 80  www1 ; _http sluzba, _tcp protokol, 1 priorita, 2 váha
               IN      SRV     5 3 80  www2

_http._tcp.www IN      SRV     1 2 80  www1.sli0124.cz. ; _http sluzba, _tcp protokol, 1 priorita, 2 váha
               IN      SRV     5 3 80  www2.sli0124.cz.

*._tcp         IN      SRV     0 0 0   .  ;ostatní služby nejsou podporovány
```

Můžeme si všimnout, že jeden A záznam je jiný, tedy hned ten první: `sli0124.cz.    IN      A 192.168.56.105` - to je hlavní záznam, když někdo napíše do prohlížeče `sli0124.cz`, tak se dostane na IP adresu. Ostatní záznamy jsou pro různé služby, které můžeme využít skrze virtuální webservery, mailové servery atd.

### Konfigurace v named.conf.local

Do `/etc/bind/named.conf.local` je nutné uvést odkaz na zónový soubor:

```bash
nano /etc/bind/named.conf.local
```

Přidejte:

```bind
zone "sli0124.cz" {
       type master;    // jedná se o primární server pro danou doménu
       file "/etc/bind/db.sli0124.cz";
};
```

Tady říkáme, že se DNS bude starat o tuto doménu, jsme primární a soubor s popisem domény je ten file.

### Kontrola a spuštění

```bash
# Zkontrolujeme pomocí příkazu
named-checkconf

# Spustíme pomocí
service bind9 restart

# Pokud nemáme žádné chyby, tak vše se podařilo nahodit
service bind9 status
```

### Testování primárního serveru

```bash
# Test základního překladu
nslookup sli0124.cz 127.0.0.1
```

Výstup by měl vypadat takto:

```plaintext
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   sli0124.cz
Address: 192.168.56.105
```

Vidíme, že záznamy existují a pro danou službu máme i IP adresu.

Můžete zkusit i další testy:

```bash
nslookup ns1.sli0124.cz 127.0.0.1
nslookup ns2.sli0124.cz 127.0.0.1
nslookup www.sli0124.cz 127.0.0.1
nslookup wiki.sli0124.cz 127.0.0.1
```

U www vidíme, že ukazuje na canonical name, což dělá záznam CNAME.

> **Tip**: nslookup lze udělat i interaktivně, můžete nastavit `set type=MX` a `sli0124.cz`, nám ukáže jiný záznam, informace o mailových serverech dané domény. Můžete zkusit seznam.cz, gmail.com

### Alternativní nástroj dig

Alternativně pro kontrolu je možné použít nástroj dig:

```bash
dig sli0124.cz @127.0.0.1
dig _http._tcp.sli0124.cz SRV @127.0.0.1
```

## Krok 3: Příprava pro sekundární server

Teď máme hotový primární server, pojďme se vrhnout na server sekundární.

### Teorie: ACL

**ACL (Access Control List)** definuje, kterým IP adresám je povoleno provádět určité operace. V našem případě určujeme, kdo smí stahovat zónové soubory.

**Allow-transfer** explicitně povoluje konkrétním serverům stáhnout kopii zóny.

Abychom mohli nakonfigurovat sekundární server, musíme přidat na primární server do `/etc/bind/named.conf.local`:

```bash
nano /etc/bind/named.conf.local
```

Přidejte ACL a allow-transfer:

```bind
acl "sli0124.cz" {
    192.168.56.106; // IP adresa sekundární DNS
};

zone "sli0124.cz" {
       type master;
       file "/etc/bind/db.sli0124.cz";
       allow-transfer { "sli0124.cz"; }; // a tady toto nové
};
```

## Krok 4: Konfigurace sekundárního DNS serveru

### Teorie: Master-Slave architektura

**Primární (Master) server**:

- Obsahuje originální zónové soubory
- Všechny změny se provádějí pouze zde
- Odpovídá na dotazy a poskytuje data sekundárním serverům

**Sekundární (Slave) server**:

- Automaticky stahuje data z primárního serveru
- Periodicky kontroluje sériové číslo SOA záznamu
- Pokud je sériové číslo vyšší, stáhne aktualizace
- Může odpovídat na DNS dotazy stejně jako primární server
- Poskytuje redundanci a rozložení zátěže

**Důležité**: Soubory na sekundárním serveru se ukládají do `/var/cache/bind/` protože si je server stahuje automaticky - nepíšeme je ručně!

Nyní můžeme pracovat na sekundárním DNS, tedy na druhém virtualizovaném PC.

Na druhém serveru upravte `/etc/bind/named.conf.local`:

```bash
nano /etc/bind/named.conf.local
```

```bind
//
// Do any local configuration here
//

// primární DNS se nachází na této IP adrese
masters sli0124.cz-master { 192.168.56.105; };

// spravujeme zónu
zone "sli0124.cz" {
        type slave; //tohle je slave, tedy sekundární
        file "/var/cache/bind/db.sli0124.cz"; // stáhni si z primární tu informaci
        masters { sli0124.cz-master; }; // a až si stáhneš tu informaci, ulož si ji zde
};
```

### Restart a testování

Tak, teď si na primární DNS restartujeme service a zkusíme najít naši doménu skrze sekundární DNS:

```bash
# Na primárním serveru
service bind9 restart
nslookup sli0124.cz 192.168.56.106
nslookup post.cz 192.168.56.106 # tuhle adresu zná
```

Nyní na druhé DNS restartujeme DNS service:

```bash
# Na sekundárním serveru
service bind9 restart
```

Mělo by vše jít, kdyby ne, tak si rozeběhněte status service a najděte chyby, zkontrolujte IP adresy.

## Krok 5: Konfigurace reverzních DNS záznamů

### Teorie: Reverzní DNS

**Reverzní DNS** umožňuje překlad IP adres zpět na doménová jména (opačný směr než běžný DNS). Funguje tak, že:

1. IP adresa se "obrátí" a připojí se speciální doména `.in-addr.arpa`
2. Pro adresu 192.168.56.105 se vytvoří dotaz na `105.56.168.192.in-addr.arpa`
3. Odpovědí je PTR záznam obsahující doménové jméno

**Proč je reverzní DNS důležité:**

- **Ověření identity**: Mailové servery často kontrolují reverzní DNS
- **Bezpečnost**: Některé služby vyžadují konzistentní přímé i reverzní záznamy
- **Logování**: Administrátoři chtějí vidět jména místo IP adres v logách

### Vytvoření reverzního zónového souboru

Pro síť `192.168.56.0/24` vytvoříme reverzní zónu. Vytvořte soubor `/etc/bind/db.192.168.56`:

```bash
nano /etc/bind/db.192.168.56
```

Vložte následující obsah (nahraďte `sli0124` za svůj login):

```bind
$TTL    86400
56.168.192.in-addr.arpa.  IN  SOA     ns1.sli0124.cz. admin.sli0124.cz. (
                            2025102801 ; Serial - datum + revize
                            4h         ; Refresh - sekundární se dotazuje po 4h
                            2h         ; Retry - při chybě zkusí znovu po 2h
                            2w         ; Expire - po 2 týdnech data zneplatní
                            1h )       ; Negative Cache TTL
;

; --- Autoritativní jmenné servery ---
56.168.192.in-addr.arpa.  IN  NS      ns1.sli0124.cz.
56.168.192.in-addr.arpa.  IN  NS      ns2.sli0124.cz.

; --- Reverzní PTR záznamy ---
; Formát: posledni_oktet.síť.in-addr.arpa. IN PTR doménové_jméno.
105.56.168.192.in-addr.arpa.  IN  PTR     ns1.sli0124.cz.
106.56.168.192.in-addr.arpa.  IN  PTR     ns2.sli0124.cz.
1.56.168.192.in-addr.arpa.    IN  PTR     router.sli0124.cz.
10.56.168.192.in-addr.arpa.   IN  PTR     webserver.sli0124.cz.
110.56.168.192.in-addr.arpa.  IN  PTR     wiki.sli0124.cz.
```

### Aktualizace konfigurace primárního serveru

Upravte `/etc/bind/named.conf.local` na primárním serveru a přidejte konfiguraci pro reverzní zónu:

```bash
nano /etc/bind/named.conf.local
```

Přidejte na konec souboru:

```bind
acl "56.168.192.in-addr.arpa" {
    192.168.56.106;
};

zone "56.168.192.in-addr.arpa" {
       type master;
       file "/etc/bind/db.192.168.56";
       allow-transfer { "56.168.192.in-addr.arpa"; };
};
```

### Aktualizace sekundárního serveru

Na sekundárním serveru přidejte do `/etc/bind/named.conf.local` konfiguraci pro reverzní zónu:

```bash
nano /etc/bind/named.conf.local
```

Přidejte:

```bind
zone "56.168.192.in-addr.arpa" {
        type slave;
        file "/var/cache/bind/db.192.168.56";
        masters { sli0124.cz-master; };
};
```

### Restart služeb a testování

Na obou serverech restartujte BIND9:

```bash
service bind9 restart
service bind9 status
```

### Testování reverzního DNS

```bash
# Test reverzního překladu na primárním serveru
nslookup 192.168.56.105 127.0.0.1

# Test na sekundárním serveru
nslookup 192.168.56.105 192.168.56.106

# Alternativně můžete použít dig
dig -x 192.168.56.105 @127.0.0.1
dig -x 192.168.56.106 @192.168.56.106
```

Úspěšný výstup by měl vypadat takto:

```plaintext
Server:         127.0.0.1
Address:        127.0.0.1#53

105.56.168.192.in-addr.arpa     name = ns1.sli0124.cz.
```

### Testování konzistence přímých a reverzních záznamů

Pro úplné ověření funkčnosti otestujte konzistenci:

```bash
# Přímý překlad
nslookup ns1.sli0124.cz 127.0.0.1
# Reverzní překlad výsledné IP adresy
nslookup 192.168.56.105 127.0.0.1
```

Oba testy by měly vracet konzistentní výsledky - doménové jméno a IP adresa by si měly odpovídat v obou směrech.

## Struktura výsledků

Adresář `results/` obsahuje:

- **dns_a/**: Konfigurace primárního DNS serveru
  - `db.sli0124.cz`: Zónový soubor pro doménu
  - `db.192.168.56`: Reverzní DNS soubor  
  - `named.conf.local`: Lokální konfigurace BIND9
  - `testy_vysledky.txt`: Výsledky testování DNS funkcionalit
  - `spustit_testy.sh`: Automatizovaný testovací skript

- **dns_b/**: Konfigurace sekundárního DNS serveru
  - `named.conf.local`: Konfigurace slave serveru
