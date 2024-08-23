#!/bin/sh

run_proxy() {
  sudo -u squid /usr/lib64/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
  sudo -u squid touch /var/log/squid/{cache,access}.log

  tail -f /var/log/squid/*.log &
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

print_version() {
  source /etc/os-release

  echo "$PRETTY_NAME"
  squid --version | grep "Squid Cache"
  openssl version
}

usage() {
  squid_vsn_prefix="Squid Cache"

  echo "Squid Docker Container is a containerized version of Squid."
  echo
  echo "Usage:"
  echo
  echo "    $0 <command>"
  echo
  echo "The commands are:"
  echo
  echo "    gen-cert  generate ca certificates for "
  echo "    proxy     run the squid proxy service"
  echo "    version   print the version of squid and openssl"
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

  version|--version|-v)
    print_version
    break
    ;;

  *)
    usage
    break
    ;;
esac
