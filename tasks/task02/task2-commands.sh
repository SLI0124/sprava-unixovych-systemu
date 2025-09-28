# Instalace potřebných balíčků pro překlad kernelu
apt install make gcc libncurses-dev bc xz-utils libelf-dev libssl-dev bison flex gawk build-essential bison libssl-dev wget htop

# Přechod do adresáře se zdrojovými kódy kernelu
cd /usr/src

# Stažení nejnovějšího kernelu (nejnovější verzi si najděte na kernel.org)
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.16.9.tar.xz

# Rozbalení archivu kernelu
xz -d linux-6.16.9.tar.xz
tar -xaf linux-6.16.9.tar

# Vytvoření symbolického odkazu na aktuální kernel
ln -s linux-6.16.9 linux

# Smazání archivu a tarballu pro úsporu místa
rm linux-6.16.9.tar
rm linux-6.16.9.tar.xz

# Přechod do adresáře se zdrojáky kernelu
cd linux

# Zkopírování výchozí konfigurace kernelu
cp /boot/config-$(uname -r) ../
# nezapoměnte si zkopírovat jméno kernelu pro nahrání v menuconfig

# Spuštění menuconfig pro konfiguraci kernelu
make menuconfig

# načtěte config z adresáře jednoho výše a připojte k názvu kernelu svůj login

# Kontrola změny názvu kernelu (login v LOCALVERSION), pokud zde není, něco jste udělal špatně
cat .config | grep LOCALVERSION

# Překlad kernelu s využitím všech jader (dvojnásobek počtu CPU)
make -j $(( $(nproc) * 2 ))

# Překlad a instalace modulů kernelu
make modules -j $(( $(nproc) * 2 ))

# Instalace modulů do systému
make modules_install

# Instalace kernelu do systému
make install

# Restart systému pro nabootování nového kernelu
reboot

# zvolte nový kernel v GRUBu

# Kontrola verze běžícího kernelu
uname -r

# Výpis detailní verze kernelu (odevzdává se)
cat /proc/version
