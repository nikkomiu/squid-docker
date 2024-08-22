#!/bin/sh

run_proxy() {
  sudo -u squid /usr/lib64/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
  squid --foreground
}

gen_cert() {
  base_dir=$1
  if [ -z ${base_dir} ]; then
    base_dir="/etc/squid/cert"
  fi

  mkdir -p ${base_dir}
  openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout ${base_dir}/bump.key -out ${base_dir}/bump.crt
  openssl dhparam -outform PEM -out ${base_dir}/bump_dhparam.pem 2048
}

usage() {
  echo "Usage..."
}

case $1 in
  proxy)
    run_proxy
    break
    ;;

  gen-cert)
    gen_cert $2
    break
    ;;

  *)
    usage
    break
    ;;
esac
