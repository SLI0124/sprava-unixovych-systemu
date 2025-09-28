# Cvičení 1: Instalace GNU/Debian

První  cvičení je zaměřeno na instalaci operačního systému **GNU/Debian** skrze virtuální stroj [VirtualBox](https://www.virtualbox.org/). Dále potřebujeme instalační obraz [Debianu](https://www.debian.org/).

## Krok 1: příprava prostředí VirtualBox

Ještě než začneme s instalací Debianu, je potřeba přidat do VirtualBoxu další síťový adaptér, který nám umožní se připojit na virtuální stroj skrze **SSH**.

1. Otevřete VirtualBox a v nastavení najděte sekci **"Síť" (Network)**. Momentálně tam nebude žádný adaptér. Přidejte nový a měla by se vytvořit síťová karta **"vboxnet0"**.
2. Zpátky v sekci pro stroje přidejte nový virtuální stroj. Pojemnujte si jej třeba **Debian a číslo cvičením**. Nezadávejte ještě instalační médium. Jen si ho pojmenujte a přejděte dále na nastavení hardwaru.
3. Jelikož to bude jen server s příkazovou řádkou, nemusíme mu dávat moc paměti. Nechte tu hodnotu, na kterou to VirtualBox navrhuje a možná dvakrát více. Procesor jsem nastavil jeden a neměl jsem nikdy problém.
4. V poslední sekci **"Úložiště"** se vytvoří virtuální disk. Základní velikost doporučuji zvednout na alespoň **30GB**, klidně i více. Tento disk okamžitě nezabared daných 30GB, ale bude používat jen to místo, které potřebuje. **Nezaškrtněte předem alokaci celého disku.** To by potom těch X GB zabralo hned. Další cvičení nejde udělat s 20GB diskem, tak doporučuji se tomu hned vyhnout a zadat rovnou **30GB a více**.
5. Potvrďte výběr a dostanete se zpět do hlavního okna VirtualBoxu. Nyní je potřeba přidat síťový adaptér, který jsme si na začátku vytvořili. Otevřete nastavení stroje a přejděte do sekce **"Síť"**. Zde povolte druhý adaptér a jako typ připojení zvolte **"Připojeno k síti hostitele" (Host-only Adapter)**. Jako název vyberte **"vboxnet0"**. To je základní pojmenování.
6. Spusťte virtuální stroj. Vyskočí na vás okno, že není připojeno žádné médium. To je v pořádku. Vyberte instalační **ISO obraz Debianu**, který jste si stáhli a připojte jej jako virtuální CD/DVD mechaniku. Potvrďte a můžeme začít s instalací.

## Krok 2: Instalace Debianu

Instalace sama o sobě není složitá. Vyberte si jazyk, zemi, klávesnici dle své preference a pokračujte dále. Většina voleb zůstává výchozích, takže vše odentrujte. Bacha na to, že **Tab**, **Enter** a **Space** fungují jinak než v běžném prostředí. Tabem se přepínáte mezi položkami, Enter volbu potvrdí a Space zaškrtí/odškrtí volbu.

Jak jsem říkal, vše nechte na výchozích hodnotách. Jen na třech místech je potřeba zasáhnout:

1. V sekcci **"Write changes to disks"** je základní volba **Ne**. Jen vyberte **Ano** a pokračujte.
2. Při výběru softwaru, který chcete nainstalovat, zvolte **"SSH server"**. To nám umožní se na stroj připojit vzdáleně. Dále můžete zvolit **"standardní systémové nástroje"**, ale není to nutné. Já si je vždy přidám, protože to ušetři spoustu instalovaní a času na příkazy, na které jsem dávno zvyklý.
Ve stejné sekci **zrušte volbu "Desktop environment" a "GNOME"**. Nemá smysl instalovat grafické prostředí na server, který bude běžet v příkazové řádce.
3. Poslední volba je instalace **GRUB bootloaderu**. Zvolte **Ano** a jako zařízení pro instalaci vyberte **primární disk**, který jsme vytvořili na začátku. V mém případě to byl `/dev/sda`.

To by mělo být vše. Nabídne se vám restart a můžete se přihlásit do svého nového Debianu.

## Krok 3: Připojení přes SSH

Nyní je potřeba zjistit **IP adresu**, kterou nám přidělil VirtualBox. To zjistíme příkazem:

```bash
ip add
```

Správný výstup bude vypadat nějak takto:

```plaintext
sli0124@debbie:~$ ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:19:25:8e brd ff:ff:ff:ff:ff:ff
    altname enx08002719258e
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86329sec preferred_lft 86329sec
    inet6 fd17:625c:f037:2:a00:27ff:fe19:258e/64 scope global dynamic mngtmpaddr proto kernel_ra 
       valid_lft 86331sec preferred_lft 14331sec
    inet6 fe80::a00:27ff:fe19:258e/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:9e:6b:65 brd ff:ff:ff:ff:ff:ff
    altname enx0800279e6b65
```

1. **Loopback** je interní adresa, kterou nebudeme potřebovat.  
2. Druhý adaptér (**enp0s3**) je ten, který nám umožňuje přístup na internet skrze NAT. Ten také nebudeme potřebovat.
3. Nás zajímá **třetí adaptér (enp0s8)**, který nám přidělil VirtualBox. V mém případě je to adresa `enp0s8` Abychom se na stroj mohl připojit, musíme říct SSH klientovi, aby použil tento adaptér. Na to potřebujeme doinstalovat balíčeky:

```bash
su                          # přepnutí na root uživatele
apt search dhclient         # vyhledání balíčku
apt install isc-dhcp-client # současný balíček pro DHCP klienta
```

Nyní můžeme získat IP adresu:

```bash
dhclient enp0s8 # získání IP adresy pro adaptér enp0s8
ip add          # znovu vypíšeme adresy abychom viděli novou IP
```

Nyní by tam měla být nová adresa, která bude vypadat nějak takto:

```plaintext
sli0124@debbie:~$ ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:19:25:8e brd ff:ff:ff:ff:ff:ff
    altname enx08002719258e
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86329sec preferred_lft 86329sec
    inet6 fd17:625c:f037:2:a00:27ff:fe19:258e/64 scope global dynamic mngtmpaddr proto kernel_ra 
       valid_lft 86331sec preferred_lft 14331sec
    inet6 fe80::a00:27ff:fe19:258e/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:9e:6b:65 brd ff:ff:ff:ff:ff:ff
    altname enx0800279e6b65
    inet 192.168.56.104/24 brd 192.168.56.255 scope global dynamic enp0s8
       valid_lft 547sec preferred_lft 547sec
    inet6 fe80::a00:27ff:fe9e:6b65/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

Všimnete si řádku s **`enp0s8`**, kde je nová **IP adresa**. V mém případě je to **`192.168.56.104`**. Tuto adresu si zapamatujte, protože ji budeme potřebovat pro připojení. Na nativním počítači spusťte terminál a zadejte:

```bash
ssh <VÁŠ_LOGIN>@<IP_ADRESA_NA_INTERFACE_ENP0S8>
```

Kde **`<VÁŠ_LOGIN>`** je uživatelské jméno, které jste si vytvořili při instalaci Debianu a **`<IP_ADRESA_NA_INTERFACE_ENP0S8>`** je IP adresa, kterou jste získali pro adaptér `enp0s8`. Po zadání příkazu se vás terminál zeptá, zda chcete přidat klíč do známých hostů. Odpovězte **"yes"** a pokračujte. Následně budete vyzváni k zadání hesla. Zadejte heslo, které jste si vytvořili při instalaci.

A jste přihlášeni na svůj nový Debian server! Máme hotovo. Tuto instanci budeme používat v dalších cvičeních skrze klonování, takže si ji **neodstraňujte**.

Prvním úkolem bývá vypsání rootovského adresáře skrze SSH v terminálu nativního počítače. Děláme to tak, protože kopírovat a vkládat do virtuálního stroje nejde out of the box. Navíc pokud máte někde server, tak je vysoce pravděpodobné, že budete v něm pracovat skrze vzdálený terminál. Výsledek zobrazíte příkazem:

```bash
sudo ls -la /
```

To **lomítko** je důležité, protože znamená **kořenový adresář**. Bez něj byste vypsali obsah vašeho domovského adresáře. Výsledek by měl vypadat nějak takto:

```plaintext
sli0124@debbie:~$ ls -la /
total 64
drwxr-xr-x  18 root root  4096 Sep 25 08:53 .
drwxr-xr-x  18 root root  4096 Sep 25 08:53 ..
lrwxrwxrwx   1 root root     7 Sep 25 08:49 bin -> usr/bin
drwxr-xr-x   3 root root  4096 Sep 25 09:00 boot
drwxr-xr-x  18 root root  3240 Sep 25 09:04 dev
drwxr-xr-x  73 root root  4096 Sep 25 09:04 etc
drwxr-xr-x   3 root root  4096 Sep 25 08:59 home
lrwxrwxrwx   1 root root    35 Sep 25 08:53 initrd.img -> boot/initrd.img-6.12.48+deb13-amd64
lrwxrwxrwx   1 root root    35 Sep 25 08:52 initrd.img.old -> boot/initrd.img-6.12.43+deb13-amd64
lrwxrwxrwx   1 root root     7 Sep 25 08:49 lib -> usr/lib
lrwxrwxrwx   1 root root     9 Sep 25 08:49 lib64 -> usr/lib64
drwx------   2 root root 16384 Sep 25 08:49 lost+found
drwxr-xr-x   3 root root  4096 Sep 25 08:49 media
drwxr-xr-x   2 root root  4096 Sep 25 08:50 mnt
drwxr-xr-x   2 root root  4096 Sep 25 08:50 opt
dr-xr-xr-x 153 root root     0 Sep 25 09:04 proc
drwx------   3 root root  4096 Sep 25 09:03 root
drwxr-xr-x  19 root root   580 Sep 25 09:05 run
lrwxrwxrwx   1 root root     8 Sep 25 08:49 sbin -> usr/sbin
drwxr-xr-x   2 root root  4096 Sep 25 08:50 srv
dr-xr-xr-x  13 root root     0 Sep 25 09:04 sys
drwxrwxrwt   7 root root   140 Sep 25 09:04 tmp
drwxr-xr-x  12 root root  4096 Sep 25 08:50 usr
drwxr-xr-x  11 root root  4096 Sep 25 09:01 var
lrwxrwxrwx   1 root root    32 Sep 25 08:53 vmlinuz -> boot/vmlinuz-6.12.48+deb13-amd64
lrwxrwxrwx   1 root root    32 Sep 25 08:52 vmlinuz.old -> boot/vmlinuz-6.12.43+deb13-amd64
```

## Poznámka

Spuštění příkazu `dhclient enp0s8` je potřeba po každém restartu virtuálního stroje, protože to v paměti nastavané a ne pernamentně skrze konfigurační soubor. Pokud byste chtěli, aby se IP adresa přidělovala automaticky při startu, je potřeba upravit konfigurační soubor sítě v souboru **`/etc/network/interfaces`** a přidat tam:

```plaintext
auto enp0s8
iface enp0s8 inet dhcp
```

Poté restartujte síťové služby příkazem:

```bash
ifdown enp0s8 && ifup enp0s8
```

Nyní by se měla IP adresa přidělovat automaticky při každém startu virtuálního stroje.
