# Squid Docker

This repo is a simple Docker container for running Squid. It contains a "default" configuration that can be loaded into the proxy and
can always be extended to do more complex proxy environments.

## Build Locally

Build the Docker image for squid:

```bash
make build
```

## Running Locally

Run the Squid proxy exposing the ports as well as mounting the config and CA certs:

```bash
make run
```
