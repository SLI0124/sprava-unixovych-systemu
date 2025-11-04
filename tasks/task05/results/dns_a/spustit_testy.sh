#!/bin/bash

echo "=== Test SOA záznamu na primárním serveru ===" > testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 sli0124.cz SOA" >> testy_vysledky.txt
dig @192.168.56.105 sli0124.cz SOA >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test SOA záznamu pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=SOA sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=SOA sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test NS záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 sli0124.cz NS" >> testy_vysledky.txt
dig @192.168.56.105 sli0124.cz NS >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test NS záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=NS sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=NS sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test A záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 ns1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 ns1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 www.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 www.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 subdomena1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 subdomena1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 www1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 www1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 www2.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.105 www2.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test A záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup ns1.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup ns1.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup www.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup www.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup subdomena1.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup subdomena1.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup www1.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup www1.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup www2.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup www2.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test CNAME záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 alias.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 alias.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 www.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 www.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 wiki.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 wiki.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 test.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 test.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 subdomena2.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.105 subdomena2.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test CNAME záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=CNAME alias.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=CNAME alias.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME www.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=CNAME www.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME wiki.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=CNAME wiki.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME test.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=CNAME test.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME subdomena2.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=CNAME subdomena2.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test MX záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 sli0124.cz MX" >> testy_vysledky.txt
dig @192.168.56.105 sli0124.cz MX >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test MX záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=MX sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=MX sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test SRV záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 _http._tcp.sli0124.cz SRV" >> testy_vysledky.txt
dig @192.168.56.105 _http._tcp.sli0124.cz SRV >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test SRV záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=SRV _http._tcp.sli0124.cz 192.168.56.105" >> testy_vysledky.txt
nslookup -type=SRV _http._tcp.sli0124.cz 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test reverzních záznamů na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.105 -x 192.168.56.105" >> testy_vysledky.txt
dig @192.168.56.105 -x 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.105 -x 192.168.56.106" >> testy_vysledky.txt
dig @192.168.56.105 -x 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test reverzních záznamů pomocí nslookup na primárním serveru ===" >> testy_vysledky.txt
echo "Příkaz: nslookup 192.168.56.105 192.168.56.105" >> testy_vysledky.txt
nslookup 192.168.56.105 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup 192.168.56.106 192.168.56.105" >> testy_vysledky.txt
nslookup 192.168.56.106 192.168.56.105 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - SOA ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 sli0124.cz SOA" >> testy_vysledky.txt
dig @192.168.56.106 sli0124.cz SOA >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - SOA pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=SOA sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=SOA sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - NS ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 sli0124.cz NS" >> testy_vysledky.txt
dig @192.168.56.106 sli0124.cz NS >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - NS pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=NS sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=NS sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - A záznam ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 ns2.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.106 ns2.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 subdomena1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.106 subdomena1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 www1.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.106 www1.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 www2.sli0124.cz A" >> testy_vysledky.txt
dig @192.168.56.106 www2.sli0124.cz A >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - A záznam pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup ns2.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup ns2.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup subdomena1.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup subdomena1.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup www1.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup www1.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup www2.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup www2.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - MX záznamy ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 sli0124.cz MX" >> testy_vysledky.txt
dig @192.168.56.106 sli0124.cz MX >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - MX záznamy pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=MX sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=MX sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - reverzní záznam ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 -x 192.168.56.106" >> testy_vysledky.txt
dig @192.168.56.106 -x 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test sekundárního serveru - reverzní záznam pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup 192.168.56.106 192.168.56.106" >> testy_vysledky.txt
nslookup 192.168.56.106 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - CNAME ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 alias.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 alias.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 www.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 www.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 wiki.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 wiki.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 test.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 test.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: dig @192.168.56.106 subdomena2.sli0124.cz CNAME" >> testy_vysledky.txt
dig @192.168.56.106 subdomena2.sli0124.cz CNAME >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - CNAME pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=CNAME alias.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=CNAME alias.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME www.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=CNAME www.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME wiki.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=CNAME wiki.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME test.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=CNAME test.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "Příkaz: nslookup -type=CNAME subdomena2.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=CNAME subdomena2.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - SRV ===" >> testy_vysledky.txt
echo "Příkaz: dig @192.168.56.106 _http._tcp.sli0124.cz SRV" >> testy_vysledky.txt
dig @192.168.56.106 _http._tcp.sli0124.cz SRV >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Test synchronizace sekundárního serveru - SRV pomocí nslookup ===" >> testy_vysledky.txt
echo "Příkaz: nslookup -type=SRV _http._tcp.sli0124.cz 192.168.56.106" >> testy_vysledky.txt
nslookup -type=SRV _http._tcp.sli0124.cz 192.168.56.106 >> testy_vysledky.txt
echo "" >> testy_vysledky.txt
echo "" >> testy_vysledky.txt

echo "=== Testy dokončeny ===" >> testy_vysledky.txt

