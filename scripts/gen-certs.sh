#!/usr/bin/env bash
# Genera un self-signed cert para uso on-premise en LAN.
#
# Cobertura base: *.nip.io + localhost + 127.0.0.1.
#
# IMPORTANTE: un wildcard `*.nip.io` cubre UN solo nivel (ej. `172-16-10-121.nip.io`)
# pero NO subdominios de dos niveles como `nethub.172-16-10-121.nip.io`. Si accedés
# por un host así, pasá la IP del servidor (argumento o env SERVER_IP) para agregar
# cobertura de `*.<ip-con-guiones>.nip.io` y del acceso directo por IP. Sin esto, los
# móviles (sobre todo iOS) no pueden saltear el error de "nombre no coincide".
#
#   ./scripts/gen-certs.sh 10.0.0.5          # ejemplo
#   SERVER_IP=10.0.0.5 ./scripts/gen-certs.sh
#
# Validez: 825 días (límite máx que Apple acepta sin warning extra).
set -euo pipefail

CERT_DIR="$(dirname "$0")/../nginx/certs"
mkdir -p "$CERT_DIR"

if [[ -f "$CERT_DIR/server.crt" && -f "$CERT_DIR/server.key" ]]; then
  echo "⚠  Ya existen certs en $CERT_DIR."
  echo "   Para regenerar (ej. aplicar cobertura por IP): rm $CERT_DIR/server.{crt,key} y volvé a correr."
  exit 0
fi

SERVER_IP="${1:-${SERVER_IP:-}}"
if [[ -n "$SERVER_IP" && ! "$SERVER_IP" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "✗ SERVER_IP inválida: '$SERVER_IP'. Esperado formato IPv4 (ej. 10.0.0.5)." >&2
  exit 1
fi
SAN="DNS:*.nip.io,DNS:localhost,IP:127.0.0.1,IP:0.0.0.0"
if [[ -n "$SERVER_IP" ]]; then
  DASHED="${SERVER_IP//./-}"
  SAN="${SAN},DNS:*.${DASHED}.nip.io,IP:${SERVER_IP}"
  echo "→ Cobertura extra: *.${DASHED}.nip.io + acceso por IP ${SERVER_IP}"
else
  echo "→ Sin IP del servidor. Para cubrir hosts <algo>.<ip>.nip.io y el acceso por IP,"
  echo "  regenerá pasando la IP: SERVER_IP=<ip> ./scripts/gen-certs.sh"
fi

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$CERT_DIR/server.key" \
  -out    "$CERT_DIR/server.crt" \
  -days 825 \
  -subj "/C=PY/ST=Alto Parana/L=Hernandarias/O=Penguin Infrastructure/CN=*.nip.io" \
  -addext "subjectAltName=${SAN}"

echo "Certs generados en $CERT_DIR/"
ls -la "$CERT_DIR"
