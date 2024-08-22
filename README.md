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
scripts/gen_ca.sh
```

> **Note:** There may be cases where the OpenSSL version you have installed on your machine doesn't work properly for generating the certificates.
> If this is the case, you can run the commands within the script from the Docker container instaed of locally.

Run the Squid proxy exposing the ports as well as mounting the config and CA certs:

```bash
docker run \
    -it --rm -p 3128:3128 -p 3129:3129 \
    -v $(pwd)/config/squid.conf:/etc/squid/squid.conf \
    -v $(pwd)/config/allowlist.txt:/etc/squid/allowlist.txt \
    -v $(pwd)/bump.crt:/etc/squid/bump.crt \
    -v $(pwd)/bump.key:/etc/squid/bump.key \
    -v $(pwd)/bump_dhparam.pem:/etc/squid/bump_dhparam.pem \
    ghcr.io/nikkomiu/squid-docker
```
