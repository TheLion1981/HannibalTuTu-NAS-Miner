# Hannibal_TuTu NAS Miner v1.0

**Een eenvoudige MoneroOcean CPU-miner voor Synology NAS, gemaakt door TheLion81 & Hannibal_TuTu.**

Doel: *minen voor beginners*. Geen losse XMRig-downloads, geen handmatig `config.json` bouwen en geen ingewikkelde commandoregels.

## Wat doet v1.0?

- Gebruikt de **MoneroOcean XMRig-fork** voor profit/algo switching.
- Bouwt de image vanuit de MoneroOcean-broncode.
- **0% XMRig developer donation** in v1.0.
- Uitbetaling blijft naar jouw eigen **Monero XMR-wallet** gaan.
- Wallet, workernaam en aantal threads zijn de enige belangrijke instellingen.
- Container herstart automatisch na een NAS/container-restart.
- De GHCR-image wordt door GitHub Actions opnieuw opgebouwd vanuit de actuele MoneroOcean-fork.

> Dit project garandeert geen winst. Mining gebruikt extra stroom en belast de CPU. Gebruik het alleen op hardware en stroom waarvoor je toestemming hebt.

## Voor wie?

v1.0 is gericht op **Synology Container Manager op amd64/x86-64 NAS-systemen**, zoals de DS224+ met Intel Celeron J4125.

## Super simpele installatie op Synology

### 1. Installeer Container Manager

Open **Package Center** en installeer **Container Manager** als dat nog niet aanwezig is.

### 2. Open Container Manager

Ga naar:

**Project → Maken**

Gebruik bijvoorbeeld:

- Projectnaam: `hannibaltutu-miner`
- Pad: `/docker/hannibaltutu-miner`
- Bron: **docker-compose.yml aanmaken**

### 3. Plak deze compose

```yaml
services:
  hannibaltutu-miner:
    image: ghcr.io/thelion81/hannibaltutu-nas-miner:1.0.0
    container_name: hannibaltutu-miner
    restart: unless-stopped
    pull_policy: always
    environment:
      WALLET: "VUL_HIER_JE_MONERO_WALLET_IN"
      WORKER: "Mijn-NAS"
      THREADS: "3"
      POOL: "gulf.moneroocean.stream:10128"
      PRINT_TIME: "60"
```

Pas alleen deze drie regels aan:

```yaml
WALLET: "jouw eigen Monero-wallet"
WORKER: "naam-van-je-nas"
THREADS: "3"
```

### 4. Klik Volgende → Aanmaken

Webportaal/Web Station is **niet nodig**.

Container Manager haalt de image op en start de miner.

### 5. Controleren

Ga naar:

**Container → hannibaltutu-miner → Logboek**

Bij een goede start zie je onder andere:

```text
XMRig developer donation: 0%
Profit/algo switching    : aan
```

Daarna voert MoneroOcean bij een nieuwe installatie/calibratie benchmarks uit en kiest automatisch een geschikt algoritme.

## Hoeveel threads?

Meer threads is niet automatisch beter. Begin rustig en controleer of DSM soepel blijft werken.

Voor onze test-DS224+ bleek **3 threads** een goede balans: de NAS bleef normaal bruikbaar voor foto's en dagelijks gebruik. Dat is een praktijkervaring, geen garantie voor iedere NAS.

## Updaten

De compose gebruikt `pull_policy: always`. Wanneer je het project opnieuw laat maken/updaten, probeert Container Manager de nieuwste gepubliceerde image te gebruiken.

De GitHub Action bouwt de `latest` image periodiek opnieuw vanuit de actuele MoneroOcean-fork. De versie-tag `1.0.0` blijft bedoeld als stabiele v1.0-release.

Voor absolute reproduceerbaarheid kan een maintainer de build vastzetten op een specifieke MoneroOcean commit via `XMRIG_REF`.

## Waarom 0% donation?

Officiële XMRig gebruikt standaard een developer donation. Dit project compileert uit broncode en verifieert tijdens de build dat de XMRig-donation op **0%** staat.

Dit staat los van eventuele pool- of transactiekosten van MoneroOcean/Monero.

### Toekomstige projectfee

v1.0 bevat **geen fee voor TheLion81 of Hannibal_TuTu**.

Als er later een projectfee komt, willen we die expliciet, zichtbaar en documenteerbaar maken. Geen verborgen wallet en geen stille wijziging. De gebruiker moet kunnen zien wat de fee is en waarvoor die wordt gebruikt.

## Huge Pages / MSR op Synology

XMRig kan op sommige systemen extra prestaties halen uit Huge Pages en MSR. Niet iedere Synology DSM-kernel stelt deze functies beschikbaar aan containers. v1.0 probeert **geen kernelinstellingen te forceren**, omdat stabiliteit van de NAS belangrijker is dan een kleine extra hashrate.

## Zelf lokaal bouwen

Voor ontwikkelaars staat `docker-compose.build.yml` in deze repository.

```bash
docker compose -f docker-compose.build.yml build --no-cache
docker compose -f docker-compose.build.yml up -d
```

`--no-cache` is belangrijk als je `XMRIG_REF=master` gebruikt en echt de actuele upstream-broncode wilt ophalen.

## Transparantie

De Dockerfile:

1. clone't rechtstreeks `https://github.com/MoneroOcean/xmrig.git`;
2. legt de gebruikte upstream Git commit vast in de image;
3. forceert en controleert 0% XMRig donation;
4. compileert XMRig;
5. kopieert alleen de miner en benodigde runtime naar de uiteindelijke image.

In het logboek wordt de gebruikte upstream commit weergegeven.

## Licentie en upstream

Dit project gebruikt en bouwt de MoneroOcean XMRig-fork. XMRig is GPL-3.0 software. Zie de upstream repositories voor hun auteursrechten en licentievoorwaarden.

**TheLion81 & Hannibal_TuTu** zijn niet verbonden aan of vertegenwoordigers van MoneroOcean of het officiële XMRig-project.
