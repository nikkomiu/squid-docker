#!/bin/bash

script_dir=$(dirname $0)

openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout ${script_dir}/../bump.key -out ${script_dir}/../bump.crt

openssl dhparam -outform PEM -out ${script_dir}/../bump_dhparam.pem 2048
