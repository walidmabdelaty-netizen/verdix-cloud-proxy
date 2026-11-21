#!/bin/bash

# 1. Start Squid Proxy
if ! pgrep -x "squid" > /dev/null; then
    echo "[*] Starting Squid Proxy..."
    squid -N -d1 > squid.log 2>&1 &
    sleep 3
else
    echo "[*] Squid is already running."
fi

# 2. Test Proxy Locally
echo "[*] Testing Local Proxy..."
STATUS=$(curl -s -x http://localhost:3128 -o /dev/null -w "%{http_code}" http://example.com)
if [ "$STATUS" -eq 200 ]; then
    echo "[+] Local Proxy is working (200 OK)."
else
    echo "[!] Local Proxy test failed (Status: $STATUS). Check squid.log."
    exit 1
fi

# 3. Start Tunnel
echo "[*] Starting localhost.run tunnel..."
echo "[*] Copy the URL below and use it as your proxy:"
ssh -o ServerAliveInterval=60 -R 80:localhost:3128 nokey@localhost.run
