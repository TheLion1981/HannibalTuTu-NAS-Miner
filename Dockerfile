# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder

ARG XMRIG_REF=master
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       git \
       build-essential \
       cmake \
       libuv1-dev \
       libssl-dev \
       libhwloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Build directly from the official MoneroOcean XMRig fork.
RUN git clone https://github.com/MoneroOcean/xmrig.git xmrig \
    && cd xmrig \
    && git fetch --tags --force \
    && git checkout "${XMRIG_REF}" \
    && git rev-parse HEAD > /tmp/xmrig-commit

# The project deliberately ships with 0% XMRig developer donation.
# Verify/force that setting at source level so a future upstream default
# cannot silently change the behavior of this image.
RUN cd /src/xmrig \
    && sed -ri 's/(kDefaultDonateLevel[[:space:]]*=[[:space:]]*)[0-9]+/\10/' src/donate.h \
    && sed -ri 's/(kMinimumDonateLevel[[:space:]]*=[[:space:]]*)[0-9]+/\10/' src/donate.h \
    && grep -Eq 'kDefaultDonateLevel[[:space:]]*=[[:space:]]*0' src/donate.h \
    && grep -Eq 'kMinimumDonateLevel[[:space:]]*=[[:space:]]*0' src/donate.h

RUN cd /src/xmrig \
    && cmake -S . -B build \
       -DCMAKE_BUILD_TYPE=Release \
       -DWITH_OPENCL=OFF \
       -DWITH_CUDA=OFF \
       -DWITH_HTTP=OFF \
    && cmake --build build --parallel "$(nproc)" \
    && strip build/xmrig

FROM debian:bookworm-slim AS runtime

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       libuv1 \
       libssl3 \
       libhwloc15 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /src/xmrig/build/xmrig /usr/local/bin/xmrig
COPY --from=builder /tmp/xmrig-commit /app/XMRIG_COMMIT
COPY entrypoint.sh /usr/local/bin/hannibaltutu-entrypoint

RUN chmod +x /usr/local/bin/hannibaltutu-entrypoint

ENV POOL=gulf.moneroocean.stream:10128 \
    WORKER=Synology-NAS \
    THREADS=3 \
    PRINT_TIME=60

ENTRYPOINT ["/usr/local/bin/hannibaltutu-entrypoint"]
