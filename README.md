# Squid Docker

## Installation

First, generate the CA certificate to be used by Squid:

```bash
scripts/gen_ca.sh
```

Build the Docker image for squid:

```bash
docker build -t squid .
```

Run the Squid proxy exposing the ports as well as mounting the config and CA certs:

```bash
docker run \
    -it --rm -p 3128:3128 -p 3129:3129 \
    -v $(pwd)/config/squid.conf:/etc/squid/squid.conf \
    -v $(pwd)/config/allowlist.txt:/etc/squid/allowlist.txt \
    -v $(pwd)/bump.crt:/etc/squid/bump.crt \
    -v $(pwd)/bump.key:/etc/squid/bump.key \
    -v $(pwd)/bump_dhparam.pem:/etc/squid/bump_dhparam.pem \
    squid
```
