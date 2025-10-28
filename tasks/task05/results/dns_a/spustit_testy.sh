#!/bin/bash
// filepath: spustit_testy.sh
echo "=== Test SOA záznamu na primárním serveru ===" > testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 sli0124.cz SOA" >> testy_vysledky.txt
dig @192.168.56.105 sli0124.cz SOA >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test NS záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 sli0124.cz NS" >> testy_vysledky.txt
dig @192.168.56.105 sli0124.cz NS >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test A záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 ns1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 ns1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 www.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 www.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test CNAME záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 alias.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 alias.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test SRV záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 _http._tcp.sli0124.cz SRV" >> testy_vysledky.txt
dig @192.168.56.105 _http._tcp.sli0124.cz SRV >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test reverzních záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 -x 192.168.56.105" >> testy_vysledky.txt
dig @192.168.56.105 -x 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 -x 192.168.56.106" >> testy_vysledky.txt
dig @192.168.56.105 -x 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - SOA ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 sli0124.cz SOA" >> testy_vysledky.txt
dig @192.168.56.106 sli0124.cz SOA >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - NS ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 sli0124.cz NS" >> testy_vysledky.txt
dig @192.168.56.106 sli0124.cz NS >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - A záznam ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 ns2.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.106 ns2.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - reverzní záznam ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 -x 192.168.56.106" >> testy_vysledky.txt
dig @192.168.56.106 -x 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - CNAME ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 alias.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 alias.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - SRV ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 _http._tcp.sli0124.cz SRV" >> testy_vysledky.txt
dig @192.168.56.106 _http._tcp.sli0124.cz SRV >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Testy dokončeny ===" >> testy_vysledky.txt

