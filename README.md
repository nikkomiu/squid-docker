# Squid Docker

This repo is a simple Docker container for running Squid. It contains a "default" configuration that can be loaded into the proxy and
can always be extended to do more complex proxy environments.

## Build Locally

Build the Docker image for squid:

```bash
make build
```

## Running Locally

Run the squid proxy in the foreground showing the logs and allowing for `Ctrl` + `C` to exit the running container:

```bash
make run
```

If you would rather start and stop the proxy in the background run:

```bash
make start
```

Then you can run the following to stop it:

```bash
make stop
```

Either way you start the container the stdout will show the output from the:

- Squid process - will show start and stop messages for the service-level process management.
- `access.log` - requests coming into the service with their status will come in here.
- `cache.log` - where service-level runtime logs will appear.

While the container is running (in either foreground or background) you can also use the following to get a shell within the container:

```bash
make exec
```

> **Note:** If the container is running in the foreground, you will need to use another terminal session to exec into the running container.

## Testing the Proxy

With the proxy running, we can test it via both the "simple" forwarding proxy as well as the SSL bump proxy (where we will need to specifiy our CA certificate).

### Testing Forwarding Proxy

To test the forwarding proxy (without SSL bump):

```bash
curl -v -x http://localhost:3128 https://microsoft.com
```

You should expect the following at the end of the output:

```text
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
< HTTP/1.1 301 Moved Permanently
< Content-Length: 0
< Date: Fri, 23 Aug 2024 14:27:57 GMT
< Server: Kestrel
< Location: https://www.microsoft.com/
< Strict-Transport-Security: max-age=31536000
< Cache-Status: 3cfdbfa6f472;detail=mismatch
< Via: 1.1 3cfdbfa6f472 (squid/6.10)
< Connection: keep-alive
< 
* Connection #0 to host localhost left intact
```

Take note of the status code (`HTTP/1.1 301 Moved Permanently`), the `Location` header, and the `Server` header.
If your response with those three parameters is different, there is likely something wrong with your proxy.

### Testing SSL Bump Proxy

Testing the SSL bump will use a different port (`3129`) and will require you to either load your `cert/bump.crt` into your OS certificate trust store
or specifiy the `--cacert` parameter for cURL.

```bash
curl -v -x http://localhost:3129 --cacert ./cert/bump.crt https://microsoft.com
```

Because this proxy endpoint rewrites SSL certificates, on top of looking for the parameters of the previous test we should
take note of the SSL certificate that was returned in the response:

```text
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN: server did not agree on a protocol. Uses default.
* Server certificate:
*  subject: C=US; ST=WA; L=Redmond; O=Microsoft Corporation; CN=microsoft.com
*  start date: Jun 19 10:37:41 2024 GMT
*  expire date: Jun 14 10:37:41 2025 GMT
*  subjectAltName: host "microsoft.com" matched cert's "microsoft.com"
*  issuer: C=US; ST=Washington; L=Seattle; O=Microsoft; OU=Azure; CN=proxy
*  SSL certificate verify ok.
* using HTTP/1.x
> GET / HTTP/1.1
> Host: microsoft.com
> User-Agent: curl/7.88.1
> Accept: */*
> 
...
```

In this case, the CA certificate used is the `issuer: C=US; ST=Washington; L=Seattle; O=Microsoft; OU=Azure; CN=proxy`. You should see
your root certificate within the `Server certificate` section of the response.

> **Note:** This is the information that you filled out when the certificate was created the first time you ran the proxy.

## Clean Up

The proxy certificates can be removed (to generate new certificates) using the following:

```bash
make clean
```

Then the next time you `run` or `start` the proxy, you will be promoted to generate new certificates.
