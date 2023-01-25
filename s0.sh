#!/usr/bin/env bash
set -x
set -euo pipefail

set -o allexport; source .env; set +o allexport

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out aks-ingress-tls.crt \
    -keyout aks-ingress-tls.key \
    -subj "/CN=demo.azure.com/O=aks-ingress-tls"

openssl pkcs12 -export -in aks-ingress-tls.crt -inkey aks-ingress-tls.key  -out $CERT_NAME.pfx
# skip Password prompt

az keyvault certificate import --vault-name $KEYVAULT_NAME -n $CERT_NAME -f $CERT_NAME.pfx