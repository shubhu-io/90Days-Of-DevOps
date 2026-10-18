#!/bin/bash
# Day 15 - Networking diagnostic script
# Runs dig, ip addr, ss and saves everything to net-report.txt
# Usage: ./net-check.sh

OUT="net-report.txt"
: > "$OUT"

echo "===== Day 15 Networking Report =====" >> "$OUT"
echo "Date: $(date)" >> "$OUT"
echo "Host: $(hostname)" >> "$OUT"
echo "" >> "$OUT"

echo "----- 1. DNS (dig google.com) -----" >> "$OUT"
if command -v dig >/dev/null 2>&1; then
    dig google.com >> "$OUT" 2>&1
    echo "" >> "$OUT"
    echo "Short A record: $(dig +short google.com A)" >> "$OUT"
    echo "A record + answer: $(dig google.com A +noall +answer)" >> "$OUT"
else
    echo "dig not installed. Run: sudo apt install -y dnsutils" >> "$OUT"
fi
echo "" >> "$OUT"

echo "----- 2. IP Addressing (ip -br addr show) -----" >> "$OUT"
ip -br addr show >> "$OUT" 2>&1
echo "" >> "$OUT"
echo "Global IPv4 addresses:" >> "$OUT"
ip -4 addr show scope global >> "$OUT" 2>&1
echo "" >> "$OUT"

echo "----- 3. Private IP check -----" >> "$OUT"
python3 - <<'PY' >> "$OUT" 2>&1
import ipaddress
for a in ['10.0.1.50','172.16.4.1','172.31.255.254','172.32.4.1','192.168.1.10','8.8.8.8']:
    print(f"{a:16} is_private={ipaddress.ip_address(a).is_private}")
PY
echo "" >> "$OUT"

echo "----- 4. CIDR / Subnetting -----" >> "$OUT"
python3 - <<'PY' >> "$OUT" 2>&1
import ipaddress
for c in ['192.168.1.0/24','192.168.0.0/16','192.168.1.0/28']:
    n = ipaddress.ip_network(c)
    print(f"{str(c):18} mask={str(n.netmask):16} total={n.num_addresses:<9} usable={n.num_addresses-2}")
PY
echo "" >> "$OUT"

echo "----- 5. Listening Ports (ss -tulpn) -----" >> "$OUT"
if command -v ss >/dev/null 2>&1; then
    ss -tulpn >> "$OUT" 2>&1
else
    echo "ss not installed. Run: sudo apt install -y iproute2" >> "$OUT"
fi
echo "" >> "$OUT"

echo "----- 6. Common port matches -----" >> "$OUT"
ss -tulpn 2>/dev/null | grep -E ':(22|53|80|443|3306|6379|27017)\b' >> "$OUT" 2>&1 || echo "No matching ports listening" >> "$OUT"
echo "" >> "$OUT"

echo "===== End of report =====" >> "$OUT"

echo "Report saved to: $OUT"
cat "$OUT"
