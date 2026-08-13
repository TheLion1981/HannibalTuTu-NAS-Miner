# 🐔 Hannibal_TuTu NAS Miner v1.1

**Beginner-friendly MoneroOcean CPU mining for Synology NAS.**  
Created by **TheLion1981 & Hannibal_TuTu**.

Turn spare NAS CPU time into XMR without manually downloading XMRig, creating `config.json`, or learning Docker command lines.

## Why use it?

- 🚀 **MoneroOcean profit/algo switching**
- 🔄 **Fresh upstream builds** from the current MoneroOcean XMRig fork
- 🐳 Built for **Synology Container Manager** on `amd64/x86-64`
- ⚙️ Only three beginner settings: **wallet, worker name, threads**
- ❤️ **0% original XMRig developer donation**
- 👧 **Transparent 1% Hannibal_TuTu project fee**
- 🔓 Open source: the fee wallet and implementation are visible in this repository
- ♻️ `restart: unless-stopped` and `pull_policy: always`

> Mining uses CPU time and electricity. Profit is not guaranteed. Only mine on hardware and electricity you are allowed to use.

---

## 👧 What is the 1% project fee?

v1.1 includes a **transparent project fee of approximately 1% of mining time** for Hannibal_TuTu.

The miner runs:

- **99 minutes** to your own wallet
- **1 minute** to the Hannibal_TuTu project wallet
- then repeats the cycle

Project fee wallet:

```text
43dwfyZ638dGaVaqBE8sYUCViionyhKVwVNHK2i3TXkMK68xEZZbxcbiiZqoCKxJKbN4mRxE1oFdniNfzeiQAaxkF1i2NwM
```

The fee is announced in the container log at startup and whenever the fee window starts. XMRig's original developer donation remains **0%**.

Because switching wallets requires a pool reconnect, actual accepted-share percentage can differ slightly from exactly 1%.

---

## 🚀 Synology quick start — mining for beginners

### 1. Install Container Manager

Open Synology **Package Center** and install **Container Manager**.

### 2. Create a project

Go to:

**Container Manager → Project → Create**

Recommended values:

- Project name: `hannibaltutu-nas-miner`
- Path: `/docker/hannibaltutu-nas-miner`
- Source: **Create docker-compose.yml**

### 3. Paste this

```yaml
services:
  hannibaltutu-miner:
    image: ghcr.io/thelion1981/hannibaltutu-nas-miner:latest
    container_name: hannibaltutu-miner
    restart: unless-stopped
    pull_policy: always
    environment:
      WALLET: "YOUR_MONERO_WALLET_HERE"
      WORKER: "My-NAS"
      THREADS: "3"
      POOL: "gulf.moneroocean.stream:10128"
      PRINT_TIME: "60"
```

Change only:

```yaml
WALLET: "your own Monero wallet"
WORKER: "a name for your NAS"
THREADS: "3"
```

For a **Synology DS224+ / Intel J4125**, 3 threads has been a good real-world starting point in our testing while normal photo/NAS use remained responsive. Your NAS may differ.

### 4. Create the project

Click **Next → Create**. No Web Station/web portal is required.

### 5. Check the log

Open:

**Container → hannibaltutu-miner → Log**

A healthy startup shows information similar to:

```text
Makers : TheLion1981 & Hannibal_TuTu
XMRig developer donation : 0%
Project fee for Hannah    : 1% mining time
Profit/algo switching     : ON
```

MoneroOcean may benchmark multiple algorithms during initial calibration. That is expected.

---

## 🔄 Updates

The GitHub Action rebuilds the `latest` image **daily** from the current `MoneroOcean/xmrig` `master` branch. A cache-busting build argument forces the upstream source to be fetched again.

This means **new installations using `:latest` receive the most recently built image**.

Existing running Docker containers cannot replace their own image. To update an existing Synology installation, use Container Manager to stop/recreate or update the project so `pull_policy: always` pulls the current `latest` image.

For stability-conscious users, GitHub release/version tags remain available so a deployment can be pinned instead of following `latest`.

---

## Huge Pages and MSR

The miner requests Huge Pages and RandomX MSR optimisations, but Synology DSM kernels do not always expose those facilities to containers. This project deliberately does **not** force kernel modifications: NAS stability comes first.

---

## Build it yourself

The image is built directly from:

```text
https://github.com/MoneroOcean/xmrig.git
```

For a local build:

```bash
docker compose -f docker-compose.build.yml build --no-cache
docker compose -f docker-compose.build.yml up -d
```

The upstream MoneroOcean commit used for the build is stored inside the image and shown in the startup log.

---

## Transparency

The Dockerfile:

1. fetches MoneroOcean/XMRig directly from the upstream GitHub repository;
2. records the exact upstream commit;
3. compiles XMRig with its original developer donation set to 0%;
4. packages only the compiled miner and required runtime libraries.

`entrypoint.sh` contains the complete 1% project-fee implementation. There is no hidden wallet or hidden process.

---

## License and upstream projects

This repository is GPL-3.0 licensed and builds the MoneroOcean fork of XMRig. Upstream copyright and license terms remain applicable.

**TheLion1981 & Hannibal_TuTu are not affiliated with or representatives of MoneroOcean or the official XMRig project.**
