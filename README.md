# Squid Docker

This repo is a simple Docker container for running Squid. It contains a "default" configuration that can be loaded into the proxy and
can always be extended to do more complex proxy environments.

## Build Locally

Build the Docker image for squid:

```bash
docker build -t ghcr.io/nikkomiu/squid-docker .
```

## Running Locally

First, generate the CA certificate to be used by Squid:

```bash
docker run \
    -it --rm \
    -v $(pwd)/cert:/etc/squid/cert \
    ghcr.io/nikkomiu/squid-docker gen-cert
```

Run the Squid proxy exposing the ports as well as mounting the config and CA certs:

```bash
docker run \
    -it --rm -p 3128:3128 -p 3129:3129 \
    -v $(pwd)/config/squid.conf:/etc/squid/squid.conf \
    -v $(pwd)/config/allowlist.txt:/etc/squid/allowlist.txt \
    -v $(pwd)/cert:/etc/squid/cert \
    ghcr.io/nikkomiu/squid-docker
```
