# Cvičení 3: Tvorba ovladačů

V tomhle cvičení si vyzkoušíme, jak se dělají kernelové moduly v Linuxu – hlavně ovladače zařízení. Vyzkoušíme si je kompilovat, nahrávat a mazat, a taky vytvořit jednoduchý způsob, jak komunikovat s uživatelským prostorem přes soubory v `/dev` a `/proc`. Máme poskytnuty ukázkové moduly.

## Před tím, než začneme

Pokud máte zkompilovaný kernel z minulého cvičení, můžete ho použít. Nemusíte dělat nic navíc. Pokud ne, stáhněte si hlavičkové soubory pro právě běžící kernel:

```bash
apt-get install linux-headers-$(uname -r)
```

Pokud by tento příkaz nefungoval, vypište si verzi kernelu pomocí `cat /proc/version` a podle toho si stáhněte odpovídající hlavičkové soubory z balíčkového systému.

```bash
apt search linux-headers
```

Z tohoto výpisu si vyberte ten, který odpovídá vaší verzi kernelu a nainstalujte ho.

## Vytvoření modulu

V nějaké prázdné složce, kterou potom dohledáte, si stáhneme ukázkový modul:

```bash
wget http://seidl.cs.vsb.cz/iso/module_sample.tar
tar -xvf module_sample.tar
```

V této složce jsou dvě složky: *hello_dev* a *hello_proc*. V každé z nich je jednoduchý modul, který se dá zkompilovat skrze `make` a nahrát do kernelu. V každé složce je také *Makefile*, který nám s kompilací pomůže.

### Klíčové znaky modulu

Každý kernel modul je samostatná jednotka, která rozšiřuje funkce jádra. Modul může poskytovat nové rozhraní, zařízení, nebo měnit chování systému. Základní vlastnosti modulu jsou:

- **Funkce modulu:** Modul by měl mít jasně popsaný účel – *co dělá* a *proč je v systému*.
- **Vstupy:** Modul přijímá vstupy různými způsoby – například zápisem do zařízení, předáním parametrů při zavádění, voláním funkcí nebo komunikací s jinými částmi jádra.
- **Výstupy:** Modul poskytuje výstupy – například data pro uživatelský prostor, návratové hodnoty, logování do systémového logu, nebo změny stavu systému.
- **Rozhraní:** Modul obvykle definuje rozhraní (např. soubor v `/dev` nebo `/proc`), přes které s ním komunikuje uživatel nebo jiné části systému.
- **Životní cyklus:** Modul se zavádí (`insmod`), inicializuje, používá, a může být odebrán (`rmmod`). Při zavedení i odebrání by měl správně uvolnit všechny prostředky.

*Dobře navržený modul má vstupy a výstupy jasně zdokumentované*, což usnadňuje jeho použití, testování i údržbu.

Každý modul by měl mít jasně definované **vstupy** (například zápis, parametry, volání funkcí) a **výstupy** (například návratové hodnoty, data pro uživatele, logování). Vstupem může být například zápis do zařízení, předání parametrů při zavádění modulu, nebo volání funkcí z jiných částí jádra. Výstupem může být návratová hodnota, výpis do logu, data dostupná uživatelskému prostoru, nebo změna stavu systému. To umožňuje modul správně testovat, používat a dokumentovat.

**Vstupy/výstupy modulu hello_dev:**

- **Vstup:** Zápis do `/dev/hello` (např. `echo "Ahoj" > /dev/hello`) – text se uloží do interního bufferu a vypíše do logu jádra (`dmesg`).
- **Výstup:** Čtení z `/dev/hello` (např. `cat /dev/hello`) – vrací text *"Hello, world!\n"* pouze při prvním čtení (soubor se chová jako jednorázový výstup).

**Stručný popis funkcí:**

- *hello_read*: Implementuje obsluhu systémového volání `read()`. Vrací pevný text, kontroluje pozici v souboru (`ppos`), kopíruje data do uživatelského prostoru.
- *hello_write*: Implementuje obsluhu `write()`. Přijímá data od uživatele, ukládá je do bufferu a vypisuje do logu jádra (`printk`).

**Exportované symboly a metadata:**

- Modul exportuje zařízení `/dev/hello` pomocí rozhraní *miscdevice*.
- Metadata: `MODULE_LICENSE`, `MODULE_AUTHOR`, `MODULE_DESCRIPTION`, `MODULE_VERSION`.

**Chování při zavedení/odebrání:**

- Při zavedení (`insmod`) se zařízení zaregistruje a je dostupné v `/dev`.
- Při odebrání (`rmmod`) se zařízení odregistruje.

### hello_dev

Tento modul vytvoří jednoduché zařízení **/dev/hello**, které když otevřeme a přečteme, vrátí nám text *"Hello, world!\n"*. Pokud do zařízení zapíšeme nějaký text, uloží se do interního bufferu jádra a zároveň se vypíše do jádrového logu. Modul využívá rozhraní *miscdevice*, které zjednodušuje registraci zařízení v jádře.

## Kompilace hello_dev

```bash
cd hello_dev
make
```

Pokud by kompilace proběhla bez chyb, stáhli jste správně hlavičkové soubory a máte funkční prostředí. Kdyby se objevily chyby, zkontrolujte, zda máte nainstalované *správné hlavičkové soubory* pro váš běžící kernel.

## Nahrání a použití modulu hello_dev

```bash
insmod hello_dev.ko
echo "Ahoj" > /dev/hello
cat /dev/hello
# Výstup:
Hello, world!
dmesg | tail
# Výstup v logu jádra:
[  597.792609] Messages:Ahoj
                | Size:5
```

## Odebrání modulu hello_dev

```bash
rmmod hello_dev
```

### hello_proc

*hello_proc.c* je jednoduchý kernel modul, který vytvoří soubor **/proc/hello**. Po načtení tohoto souboru (např. pomocí `cat`) vypíše aktuální hodnotu konstanty *HZ*, která udává frekvenci časovače jádra (počet ticků za sekundu). Modul využívá rozhraní *procfs* a funkce *seq_file* pro bezpečný výpis dat.

## Kompilace hello_proc

```bash
cd hello_proc
make
```

## Nahrání a použití modulu hello_proc

```bash
insmod hello_proc.ko
cat /proc/hello
# Výstup:
100
```

## Odebrání modulu hello_proc

```bash
rmmod hello_proc
```

## Úkoly

V tomto cvičení se naučíte vytvářet kernel moduly, které umožňují čtení a zápis do souborů ve složkách *`/proc`* nebo *`/dev`*, včetně netriviální logiky a dokumentace jejich rozhraní.

## Moje implementace

*Vytvořil jsem modul* **/dev/checksum**, *který umožňuje výpočet kontrolních součtů nad zapsanými daty*. Podporuje algoritmy **md5**, **sha1**, **sha256**, **xor** a parametrizaci počtu iterací (*level*). Zápisem do zařízení se nastaví vstupní data, čtením se získá výsledek podle zvoleného algoritmu. Algoritmus i úroveň lze měnit pomocí parametrů modulu.
