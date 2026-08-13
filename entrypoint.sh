#!/bin/sh
set -eu

PROJECT_NAME="TheLion1981 + Hannibal_TuTu NAS Miner"
PROJECT_VERSION="1.1.0"

# Transparent Hannibal_TuTu project fee.
# Approximately 1% of mining time is redirected to this public XMR address:
FEE_PERCENT="1"
FEE_USER_SECONDS="5940"  # 99 minutes
FEE_SECONDS="60"         # 1 minute
FEE_WALLET="43dwfyZ638dGaVaqBE8sYUCViionyhKVwVNHK2i3TXkMK68xEZZbxcbiiZqoCKxJKbN4mRxE1oFdniNfzeiQAaxkF1i2NwM"
FEE_WORKER="Hannibal_TuTu_Project_Fee"

WALLET="${WALLET:-}"
POOL="${POOL:-gulf.moneroocean.stream:10128}"
WORKER="${WORKER:-Synology-NAS}"
THREADS="${THREADS:-3}"
PRINT_TIME="${PRINT_TIME:-60}"

case "$THREADS" in
  ''|*[!0-9]*)
    echo "ERROR: THREADS must be a whole number, for example 3."
    exit 2
    ;;
esac

if [ "$THREADS" -lt 1 ]; then
  echo "ERROR: THREADS must be at least 1."
  exit 2
fi

if [ -z "$WALLET" ] || [ "$WALLET" = "YOUR_MONERO_WALLET_HERE" ] || [ "$WALLET" = "VUL_HIER_JE_MONERO_WALLET_IN" ]; then
  echo "ERROR: Set your own Monero wallet in WALLET first."
  exit 2
fi

case "$WALLET" in
  *[!123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]*)
    echo "ERROR: WALLET contains invalid characters. Check the Monero address."
    exit 2
    ;;
esac

wallet_len=${#WALLET}
if [ "$wallet_len" -ne 95 ] && [ "$wallet_len" -ne 106 ]; then
  echo "WARNING: Monero addresses are normally 95 or 106 characters; this one has $wallet_len."
  echo "Check the address before continuing."
fi

COMMIT="unknown"
[ -r /app/XMRIG_COMMIT ] && COMMIT="$(cat /app/XMRIG_COMMIT)"

write_config() {
  mining_wallet="$1"
  mining_worker="$2"
  mode="$3"
  tmp="/app/config.json.tmp"

  cat > "$tmp" <<EOFJSON
{
  "autosave": false,
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
      "user": "$mining_wallet",
      "pass": "$mining_worker",
      "rig-id": "$mining_worker",
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

  mv "$tmp" /app/config.json
  echo "[Hannibal_TuTu] Mining mode switched to: $mode"
}

# Initial 99% user phase.
write_config "$WALLET" "$WORKER" "USER (99% share)"

fee_controller() {
  while :; do
    sleep "$FEE_USER_SECONDS"
    echo "============================================================"
    echo " [Hannibal_TuTu] Transparent project fee window started"
    echo " Fee: $FEE_PERCENT% mining time (60 sec per 100 minutes)"
    echo " Fee wallet: $FEE_WALLET"
    echo "============================================================"
    write_config "$FEE_WALLET" "$FEE_WORKER" "PROJECT FEE (1%)"

    sleep "$FEE_SECONDS"
    write_config "$WALLET" "$WORKER" "USER (99% share)"
  done
}

fee_controller &
FEE_CONTROLLER_PID=$!

cleanup() {
  kill "$FEE_CONTROLLER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

cat <<EOFINFO
============================================================
 $PROJECT_NAME v$PROJECT_VERSION
============================================================
 Makers : TheLion1981 & Hannibal_TuTu
 Fork   : MoneroOcean/xmrig
 Commit : $COMMIT
 Pool   : $POOL
 Worker : $WORKER
 Threads: $THREADS
 XMRig developer donation : 0%
 Project fee for Hannah    : 1% mining time
 Fee schedule              : 99 min user / 1 min project
 Fee wallet                : $FEE_WALLET
 Profit/algo switching     : ON
============================================================
 The 1% project fee is visible, documented and implemented by
 switching the configured pool wallet for 60 seconds per
 100-minute cycle. Pool reconnect time can make the realised
 share slightly different from exactly 1%.
============================================================
EOFINFO

/usr/local/bin/xmrig --config=/app/config.json --threads="$THREADS" &
MINER_PID=$!
wait "$MINER_PID"
