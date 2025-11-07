# Cvičení 8: IMAP a SMTP server

Toto cvičení je zaměřeno na konfiguraci **SMTP a IMAP serveru pomocí Postfix** v distribuci Debian.

## Úvod do problematiky

**SMTP** je pro posílání emailů.

**IMAP** je pro vyzvedávání těchto emailů.

### Jak funguje email

Když zmáčknete odeslat, co se stane? Dva důležité informace - od koho je a komu patří?

Server odchozí pošty se podívá na hlavičku emailu a podívá se před a po zavináč. Podívá se za zavináč, pokud tam je doména, kterou spravuje on sám, zařadí jej do fronty lokálně a pomocí před zavináčem se dívá po schránce, kde to má dorazit. Pokud tam není ta doména, tak pomocí DNS se zeptá, který server spravuje doménu a serveru to přepošle.

## Příprava prostředí

Prerekvizity:

- jeden stroj (klon) pro SMTP-IMAP
- klon DNS1, asi jej budeme znova měnit, tak pro jistotu uděláme klon  
- DNS2 pouze spustíme
- LAMP server bude stačit spustit, tam nová stránka navíc neuškodí
- testovací stroj, můžeme použít z minula

## Konfigurace SMTP-IMAP serveru

Na SMTP-IMAP nastavíme statickou IP adresu:

```bash
nano /etc/network/interfaces
```

```bash
#iface enp0s8 inet dhcp
allow-hotplug enp0s8
iface enp0s8 inet static
        address 192.168.56.107
        netmask 255.255.255.0
```

A aktivujeme interface:

```bash
ifup enp0s8
```

## Konfigurace DNS

V DNS si upravíme SMTP1 a SMTP2 na IP adresu IMAP serveru:

```bash
nano /var/lib/bind/db.sli0124.cz
```

```bash
...
ns2            IN      A       192.168.56.106
smtp           IN      A       192.168.56.107 # použijeme jen jeden server
smtp2          IN      A       192.168.56.107 # mohli bychom nastavit 2, ale takhle to bude stačit
www            IN      CNAME   sli0124.cz.
...
```

Stáhneme knihovny:

```bash
apt install dnsutils net-tools telnet
```

Nastavíme DNS na naši DNS:

```bash
nano /etc/resolv.conf
```

```bash
nameserver 192.168.56.105
```

Pro jistotu změníme i název stroje:

```bash
hostnamectl set-hostname smtp-imap
```

Pro změnu se odhlásíme a přihlásíme zpět pomocí Ctrl+D.

## Instalace Postfix

Teď nainstalujeme postfix knihovnu:

```bash
apt install postfix
```

Zvolíme **Internet Site/internetový počítač** - nějaký set doporučených minimálních nastavení.

**Poštovní jméno systému/system mail name:** `sli0124.cz` (doména, kterou bude spravovat tento mail)

Abychom se podívali, že nějaký server běží, tak zadáme příkaz:

```bash
netstat -pln
```

Tam hned nahoře vidíme, že master poslouchá na portu 25, což znamená, že služba funguje a běží.

## První test - lokální email

Trocha teorie za námi, pojďme si poslat mail:

```bash
telnet localhost 25
```

Klíčové SMTP příkazy:

```bash
helo sli0124.cz          # pozdrav s doménou
mail from: sli0124@sli0124.cz    # od koho
rcpt to: sli0124@sli0124.cz      # pro koho  
data                     # začátek obsahu
test numero uno          # obsah emailu
.                        # ukončení obsahu
quit                     # ukončení relace
```

**Hledáme:** Odpověď `250 2.0.0 Ok: queued` = email byl přijat do fronty.

Co se stalo? Server zjistil, že spravuje doménu `sli0124.cz` a lokálně email doručil.

Ověření doručení:

```bash
cat /var/spool/mail/sli0124
```

**Hledáme:** Email s hlavičkami a obsahem "test numero uno".

## Test ze vzdáleného počítače

Test z jiného stroje pomocí DNS jména:

```bash
telnet smtp.sli0124.cz 25
```

**Hledáme:** Připojení na IP `192.168.56.107` a stejné SMTP příkazy jako v kroku 4.

**Důležité:** Ověřujeme, že DNS překlad funguje a email se doručí stejně jako lokálně.

## Konfigurace Relay

Říkali jsme si, že se podívá na zavináč a podle toho, jestli ho najde u sebe nebo ne, tak ho pošle nebo nepošle do internetu, jenže kdyby to tak fungovalo, tak lze lehce spamovat, tedy je nastaven relay.

V `/etc/postfix/main.cf` je konfigurace, kde vidíme položky:

- **hostname:** jméno serveru
- **aliasy:** budou dále
- **myorigin:** což je mailové jméno
- **mydestination:** seznam domén, pro které server pracuje, za tím zavináčem hledá právě tady
- **relayhost:** určen pro situaci, kdy poštovní server pracuje v rámci sítě, ve které je zakázáno kontaktovat poštovní servery na internetu (můžu posílat maily na školní síti pouze skrze školní mail server) takže to je hodnota pro server, přes které se mají posílat "relayované" emaily
- **mynetworks:** (navazuje na smptd_relay_restrictions hodnotou permit_mynetworks) zde je řečeno z těchto sítí může dělat relay

Test relay - pokus o odeslání mimo naši doménu:

```bash
rcpt to: sli0124@vsb.cz
454 4.7.1 <sli0124@vsb.cz>: Relay access denied
```

**Hledáme:** Chybu "Relay access denied" = server odmítá přeposílat emaily mimo svou doménu.

Aby to fungovalo, musíme zpět na IMAP stroji upravit soubor a řádek:

```bash
nano /etc/postfix/main.cf
```

```bash
...
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 192.168.56.0/24
...
```

Config obnovíme:

```bash
postfix reload
```

A teď lze poslat email ven z lokální sítě.

## Poštovní aliasy

Každý uživatel z `/home/` je i uživatel mailu.

Přidáme si jednoho uživatele navíc:

```bash
useradd sli124
```

Pokud chceme aliasy a lepší zprávu serverového mailu, tak editujeme soubor:

```bash
nano /etc/aliases
```

```bash
# See man 5 aliases for format
postmaster:    root
studenti: sli0124@sli0124.cz, sli124@sli0124.cz
```

Teď jsme specifikovali skupinu. Aby se provedli změny, provedeme příkaz:

```bash
newaliases # provedli se změny v /etc/aliases jak v text souboru, tak i v db souboru
```

Test aliasu - odeslání na skupinu:

```bash
telnet smtp.sli0124.cz 25
rcpt to: studenti@sli0124.cz
250 2.1.5 Ok
```

**Hledáme:** Odpověď `250 2.1.5 Ok` = alias byl rozpoznán.

Ověření doručení - email dostali všichni uživatelé ze skupiny:

```bash
cat /var/spool/mail/sli124
cat /var/spool/mail/sli0124
```

**Hledáme:** Hlavičku `X-Original-To: studenti@sli0124.cz` = email byl původně adresován na alias.

Stejně tak jde i udělat to, že nebudu posílat jen na loginy, ale na jména, to si tam přidat přesně tak, jak je to na škole:

```bash
root@smtp-imap:/var/spool/mail# cat /etc/aliases
# See man 5 aliases for format
postmaster:    root
studenti: sli0124@sli0124.cz, sli124@sli0124.cz
borec: sli0124@sli0124.cz
```

Potom:

```bash
newaliases
```

Test individuálního aliasu:

```bash
telnet smtp.sli0124.cz 25
rcpt to: borec@sli0124.cz
250 2.1.5 Ok
```

**Hledáme:** Email doručený do `/var/spool/mail/sli0124` s hlavičkou `X-Original-To: borec@sli0124.cz`.

## Kanonické názvy

Normálně vidíme login, to je špatné proti útokům, tak se login přepíše na first name last name místo loginu.

```bash
cd /etc/postfix
nano canonical
```

```bash
root@smtp-imap:/etc/postfix# cat canonical
sli0124 vojtech.sliva
```

A vytvoříme pomocí:

```bash
postmap canonical # zase se vytvořila databáze pro rychlejší nalezení
```

```bash
nano /etc/postfix/main.cf
canonical_maps = hash:/etc/postfix/canonical # hash je ta databáze
```

A potvrzení:

```bash
postfix reload
```

Test kanonických jmen:

```bash
telnet smtp.sli0124.cz 25
mail from: sli0124@sli0124.cz
rcpt to: sli124@sli0124.cz
```

**Hledáme:** V emailu hlavičku `From: vojtech.sliva@sli0124.cz` místo původního `sli0124@sli0124.cz`.

## Mailbox a Maildir

Mailbox se využil doposud, všechny pošty se schovávají v jednom souboru, ale spousta mailů v jednom souboru je zátěž pro paměť.

Přechází se na maildir:

```bash
root@smtp-imap:/etc/postfix# nano /etc/postfix/main.cf
# na konec dodáme

home_mailbox = Maildir/

postfix reload
```

**Warning:** Často se nevytváří Maildir, buďto upravit skel soubor pro nového uživatele, nebo prostě tu složku vytvořit:

```bash
mkdir -p /home/sli0124/Maildir/{cur,new,tmp}
chown -R sli0124:sli0124 /home/sli0124/Maildir
chmod -R 700 /home/sli0124/Maildir
```

Test Maildir - pošleme zkušební email:

```bash
telnet smtp.sli0124.cz 25
rcpt to: sli124@sli0124.cz
```

**Hledáme:** Email se **NEULOŽÍ** do `/var/spool/mail/sli124`, ale do `/home/sli124/Maildir/new/`.

Ověření Maildir:

```bash
ls -la /home/sli124/Maildir/new/
cat /home/sli124/Maildir/new/[filename]
```

**Výsledek:** Místo jednoho velkého souboru máme jednotlivé soubory pro každý email.

Takže místo zapisování do jednoho souboru teď máme pro každý mail jeden nový soubor.
