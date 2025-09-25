# Cvičení 2: Překlad kernelu

Toto cvičení je zaměřeno na překlad nejnovějšího jádra kernelu Linuxu ze zdrojových kódů.

## Příprava prostředí

Než cokoliv spustíme, musíme si připravit prostředí. To uděláme tak, že si naklonujeme instanci z předchozího cvičení v VirtualBoxu. Pravým kliknutím zvolíme náš stroj a zvolíme "Clone". V dalším dialogu zvolíme "Linked Clone" a potvrdíme. Linked clone pouze inkrementuje změny oproti původnímu stroji, takže šetří místo na disku. U tohoto úkolu se bude hodit mít místa co možná nejvíce.

Na stažení a kompilaci kernelu budeme potřebovat spoustu místa. Ze zkušenosti je 30 GB dostatek, ale nebál bych se přidat více, protože virtuální stroj využije pouze to místo, které skutečně potřebuje. Případný troubleshooting je pouze na Vás. Vím, že to není pár jednoduchých příkazů. Nebo si případně přidat disk a nastavit si automatické mountování skrze `/etc/fstab`.

Poslední důležitá věc, kterou musíme udělat, je přidat virtuálnímu stroji více RAM a procesorů. Doporučuji alespoň 4GB RAM a veškeré dostupné procesory. Více jader urychlí značně kompilaci. Kompilace kernelu je totiž velmi náročná obzvláště na CPU, RAM a I/O operace na disku. Proto se nebojte tam dát maximální dostupné hodnoty. Počítač je stále responzivní a vše funguje dobře.

## Příprava zdrojových kódů a nástrojů

Po spuštění se opět přihlásíme skrze ssh a dhclient a přepneme se na super uživatele. Pro kompilaci kernelu budeme potřebovat několik balíčků, které nainstalujeme pomocí apt:

```bash
apt install make gcc libncurses-dev bc xz-utils libelf-dev libssl-dev bison flex gawk build-essential bison libssl-dev wget htop
```

Přepneme se do adresáře `/usr/src`, protože zde se nachází zdrojové kódy kernelu a je to dobré místo pro jejich uložení.

```bash
cd /usr/src
```

Následně si stáhneme nejnovější kernel ze stránek [Linuxu](https://www.kernel.org/). V době psaní tohoto textu je nejnovější verze 6.16.9, ale může být novější. Zkopríujete si link na stažení nejnovější verze. Na verzi nezáleží. Můžeme si jej stáhnout, rozbalit a přejít do jeho adresáře:

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.16.9.tar.xz
xz -d linux-6.16.9.tar.xz
tar -xaf linux-6.16.9.tar
```

Důležité je udělat symbolický odkaz `linux`, který bude ukazovat na nejnovější verzi kernelu. To nám usnadní práci, protože nebudeme muset pokaždé přepisovat číslo verze.

```bash
ln -s linux-6.16.9 linux
```

Pokud chceme co nejvíce místa, můžeme smazat stažený archiv a rozbalený tarball:

```bash
rm linux-6.16.9.tar
rm linux-6.16.9.tar.xz
```

Nyní máme vše připraveno pro kompilaci kernelu.

```bash
cd linux
```

Celé jádro je kompilované skrze `make`. Nejdříve si ale musíme vytvořit konfigurační soubor, který určuje, jaké části kernelu se mají překládat. Po nastavení a vybraní jednotlivých částí se tento soubor uloží jako `.config` do kořenového adresáře kernelu. My už ale tento soubor máme ve složce `/boot/`, což je výchozí konfigurace našeho aktuálního spuštěného kernelu. Můžeme jej zkopírovat do našeho adresáře:

```bash
cp /boot/config-$(uname -r) ../
```

Zkopírovaly jsme jej do nadřazeného adresáře, protože při výběru konfigurace se `.config` soubor vytvoří v aktuálním adresáři a tím pádem bychom jej přepsali. Doporučuji si název tohoto souboru zkpírovat, budeme jej brzy potřebovat. Na příjklad moje jméno je `config-6.12.48+deb13-amd64`.

## Výběr konfigurace kernelu

Nyní se můžeme pustit do výběru konfigurace kernelu. K tomu slouží několik nástrojů, my použijeme `menuconfig`, který je textový a pracuje v terminálu. Spustíme jej pomocí:

```bash
make menuconfig
```

Měla by na nás vyskočit textová nabídka. V této nabídce můžeme vybírat různé části kernelu, které chceme či nechceme překládat. Můžeme se pohybovat pomocí šipek, do podnabídek vstoupíme klávesou Enter a zpět se vrátíme klávesou Escape. Výběr možností provedeme klávesou mezerník. Všechny změny se ukládají do `.config` souboru, který je v aktuálním adresáři.

Samotný výběr a konfigurace je velmi složitý a záleží na tom, co chceme. Ne všechny konfigurace vedou ke znovuspustitelnému kernelu. Proto jsme si zkopírovali výchozí konfiguraci našeho aktuálního kernelu, která funguje. Doporučuji v nabídce nic neměnit a nahrát jej pomocí `Load`. Cesta potom vypadá následovně: `../config-6.12.48+deb13-amd64`. Zadání úkolu po nás poze chce, abychom pouze přidali na konec názvu kernelu svůj login. To uděláme v nabídce `General setup` -> `Local version - append to kernel release`. Zde přidáme na konec náš login, například `_sli01240`. To by mělo být vše a můžeme nabídku opustit a uložit změny. Při opuštění budeme vyzváni k uložení změn a nazveme soubor `.config`.

Pro kontrolu, zda se název kernelu správně změnil, můžeme použít příkaz:

```bash
cat .config | grep LOCALVERSION
```

Výstup by měl vypadat nějak takto:

```bash
root@debbie:/usr/src/linux$ cat .config | grep LOCALVERSION
CONFIG_LOCALVERSION="_sli0124"
# CONFIG_LOCALVERSION_AUTO is not set
```

Pokud zde nevidíte login, je to proto, že jste změnili název v nabídce a potom jste nahráli novou konfiguraci, která změny přepsala. V takovém případě spusťte `make menuconfig` znovu a změňte to, nejlépe ve správném pořadí.

## Kompilace kernelu

Nyní máme vše připraveno pro kompilaci kernelu. Kompilace je velmi náročný proces a může trvat i několik hodin v závislosti na výkonu vašeho počítače. Pro samotnou kompilaci použijeme příkaz:

```bash
make -j $(( $(nproc) * 2 )) 
```

Tento příkaz spustí kompilaci s počtem vláken rovným dvojnásobku počtu dostupných procesorových jader, což urychlí kompilaci. Počet jader jste nastavili v nastavení virtuálního stroje.

Pokud chceme, můžeme si na serveru spustit `htop`, který nám ukáže vytížení CPU a RAM během kompilace. Měli bychom vidět, že všechna jádra jsou plně vytížená a RAM je také značně využitá.

### Kompilace modulů

Moduly musíme taktéž zkompilovat. To provedeme příkazem:

```bash
make modules -j $(( $(nproc) * 2 ))
make modules_install
```

Tímto příkazem zkompilujeme a nainstalujeme všechny moduly kernelu. Moduly jsou zavaděny dynamicky a umožňují přidání funkcionality do kernelu bez nutnosti jeho znovu překladu. To je tzv. modularita kernelu. To jsou přesně ty zavaděče, které jsme viděli v nabídce `menuconfig` jako `M`, jako je audio, síťové karty, souborové systémy atd.

### Instalace kernelu

Celé to zakončíme instalací kernelu pomocí:

```bash
make install
```

Tento příkaz nainstaluje kernel do `/boot/` a aktualizuje zaváděcí zavaděč GRUB. Po dokončení instalace můžeme virutální stroj restartovat:

```bash
reboot
```

Během restartu musíme vybrat v nabídce GRUB náš nový kernel. Měl by být označen názvem s naším loginem na konci. Pro zajímavost se můžeme podívat na parametry kernelu zmáčknutím klávesy `e` v nabídce GRUB. Tím se dostaneme do režimu úprav, kde můžeme vidět různé parametry kernelu.

Najdeme řádek, který končí slovem `quiet`a smažeme jej. Tím zajistíme, že při bootování uvidíme všechny zprávy kernelu, což je užitečné kontrolu v případě, že by se něco pokazilo. Poté můžeme stisknout `F10`, nebo `Ctrl + X` pro spuštění s upravenými parametry.

Pokud vše proběhlo v pořádku, měli bychom se dostat do přihlašovací obrazovky. Přihlásíme se a zkontrolujeme verzi kernelu pomocí:

```bash
uname -r
```

Odevzdává se výstup příkazu:

```bash
cat /proc/version
```

Pokud vše dopadlo dobře, měli bychom vidět náš login na konci názvu kernelu. Například:

```bash
sli0124@debbie:~$ cat /proc/version 
Linux version 6.16.9_sli0124 (root@debbie) (gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44) #1 SMP PREEMPT_DYNAMIC Thu Sep 25 20:40:03 CEST 2025
```

## Poznámka ke závěrečnému testu: Ramdisk, initramfs a initrd

Modulární jádro Linuxu má jednu nevýhodu: aby mohl operační systém vůbec nastartovat, potřebuje mít k dispozici minimální zdroje – CPU, paměť a hlavně root filesystém. Jenže root filesystém nemusí být vždy na pevném disku, může být i na síti nebo v paměti. Aby se k němu jádro dostalo, potřebuje ovladače pro řadiče disků, síťových karet apod. Problém je, že modulární jádro si ovladače načítá až za běhu, ale při startu je ještě nemá k dispozici.

Kdybychom chtěli, aby jádro obsahovalo všechny možné ovladače pro všechny konfigurace PC, bylo by obrovské a neefektivní. Proto se používá tzv. init ram disk – speciální soubor, který vznikne při překladu kernelu a obsahuje jen ty nejdůležitější ovladače, které jsou potřeba pro start systému.

- **Ramdisk** je část paměti RAM, která se chová jako disk. Do něj se nahrají potřebné ovladače a soubory, které jádro potřebuje hned po startu.
- **initrd** (initial ramdisk) je starší způsob – jde o obraz malého filesystému, který se při startu nahraje do ramdisku a obsahuje základní ovladače (například pro disky a síťovky), aby jádro mohlo najít a připojit root filesystém.
- **initramfs** je novější varianta – místo obrazu filesystému je to archiv (cpio), který se rozbalí rovnou do paměti. Je jednodušší a rychlejší, protože nepotřebuje speciální filesystém.

Při startu si jádro nahraje ramdisk, vezme si z něj potřebné ovladače (například pro disky a síťové karty), načte je do paměti a připojí root filesystém. Teprve potom má přístup ke všem ostatním ovladačům a modulům (například pro zvuk, bluetooth atd.), které si může načíst později. Po připojení root filesystému se ramdisk zahodí a systém pokračuje v běžném běhu.

Díky tomuto mechanismu může jádro zůstat modulární a univerzální, aniž by muselo obsahovat tisíce ovladačů napevno.
