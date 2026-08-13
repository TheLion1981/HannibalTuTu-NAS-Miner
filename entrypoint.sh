#!/bin/sh
set -eu

PROJECT_NAME="TheLion81 + Hannibal_TuTu NAS Miner"
PROJECT_VERSION="1.0.0"

WALLET="${WALLET:-}"
POOL="${POOL:-gulf.moneroocean.stream:10128}"
WORKER="${WORKER:-Synology-NAS}"
THREADS="${THREADS:-3}"
PRINT_TIME="${PRINT_TIME:-60}"

case "$THREADS" in
  ''|*[!0-9]*)
    echo "FOUT: THREADS moet een heel getal zijn (bijvoorbeeld 3)."
    exit 2
    ;;
esac

if [ "$THREADS" -lt 1 ]; then
  echo "FOUT: THREADS moet minimaal 1 zijn."
  exit 2
fi

if [ -z "$WALLET" ] || [ "$WALLET" = "VUL_HIER_JE_MONERO_WALLET_IN" ]; then
  echo "FOUT: Vul eerst je eigen Monero-wallet in bij WALLET."
  exit 2
fi

case "$WALLET" in
  *[!123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]*)
    echo "FOUT: WALLET bevat ongeldige tekens. Controleer het Monero-adres."
    exit 2
    ;;
esac

wallet_len=${#WALLET}
if [ "$wallet_len" -ne 95 ] && [ "$wallet_len" -ne 106 ]; then
  echo "WAARSCHUWING: Monero-adressen zijn normaal 95 of 106 tekens; dit adres heeft $wallet_len tekens."
  echo "Controleer het adres voordat je verder mined."
fi

COMMIT="onbekend"
[ -r /app/XMRIG_COMMIT ] && COMMIT="$(cat /app/XMRIG_COMMIT)"

cat > /app/config.json <<EOFJSON
{
  "autosave": true,
  "background": false,
  "colors": true,
  "title": true,
  "randomx": {
    "init": -1,
    "mode": "auto",
    "1gb-pages": false,
    "rdmsr": true,
    "wrmsr": true,
    "numa": true
  },
  "cpu": {
    "enabled": true,
    "huge-pages": true,
    "huge-pages-jit": false,
    "priority": null,
    "memory-pool": true,
    "yield": true,
    "asm": true
  },
  "opencl": { "enabled": false },
  "cuda": { "enabled": false },
  "donate-level": 0,
  "donate-over-proxy": 0,
  "pools": [
    {
      "algo": null,
      "coin": null,
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "$WORKER",
      "rig-id": "$WORKER",
      "nicehash": false,
      "keepalive": true,
      "enabled": true,
      "tls": false
    }
  ],
  "print-time": $PRINT_TIME,
  "health-print-time": 60,
  "retries": 5,
  "retry-pause": 5,
  "watch": true,
  "rebench-algo": false,
  "bench-algo-time": 20,
  "pause-on-battery": false,
  "pause-on-active": false
}
EOFJSON

echo "============================================================"
echo " $PROJECT_NAME v$PROJECT_VERSION"
echo " Makers : TheLion81 & Hannibal_TuTu"
echo " Fork   : MoneroOcean/xmrig"
echo " Commit : $COMMIT"
echo " Pool   : $POOL"
echo " Worker : $WORKER"
echo " Threads: $THREADS"
echo " XMRig developer donation: 0%"
echo " Profit/algo switching    : aan"
echo "============================================================"

exec /usr/local/bin/xmrig --config=/app/config.json --threads="$THREADS"
