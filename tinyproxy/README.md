# tinyproxy

Tinyproxy is a super simple way to setup an HTTP proxy. If just used as an HTTP proxy, the main use-case would be to hide your original IP from the server you're connecting to.

However, we can also put stunnel in front of it, to create an HTTPS proxy. This has the benefit of hiding the website you are trying to connect to, from anyone between you and the proxy server (e.g. your ISP). Since this is basically TLS traffic, it is very unlikely to be blocked, especially if you choose common ports.

## Installing tinyproxy

(TODO: Actual install steps)

An example config is available at [tinyproxy.conf](./tinyproxy.conf). Place this at `/etc/tinyproxy/tinyproxy.conf`. The most important lines are:

```
Port 8888
(....)
BasicAuth plaintext_username_here plaintext_password_here
```

* `Port` is the TCP port the HTTP proxy listens at (no TLS)
* `BasicAuth` is the username & password to authenticate with the proxy

## Installing stunnel

(TODO: Actual install steps)

To use stunnel with tinyproxy, you need to generate TLS certificates for the actual TLS connection from a client to the proxy server.

* [Guide to generate self-signed certificates](https://ckcr4lyf.github.io/tech-notes/crypto/openssl/tls.html)
* [Guide to generate CA signed certificates](https://ckcr4lyf.github.io/tech-notes/services/nginx/signed.cert.html)

An example config is available at [stunnel.conf](./stunnel.conf).

The `accept = 0.0.0.0:port` line tels stunnel which port to offer the TLS connection with the specified cert & key at. A good idea is to use common ports to have a higher chance to pass through a firewall.

Port 443 would be the best, but some others are: 465 (SMTPS), 587 (SMTPS), 993 (IMAPS), 995 (POP3S), 3306 (MySQL), 5432 (PostgreSQL).

## Testing the proxy

### Testing the HTTP proxy

```
curl -v -x http://username:password@domain.com:tinyproxy_http_port https://icanhazip.com
```

### Testing the HTTPS proxy

```
curl -v -x https://username:password@domain.com:stunnel_https_port https://icanhazip.com
```

If you're using a self-signed cert for `stunnel` , you'll also need the flag `--proxy-insecure`.