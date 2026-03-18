#!usr/bin/env bash
# service to expose monitoring

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set kubernetes service
echo "==> Création du service kubernetes pour le monitoring:"
kubectl apply -f "$SCRIPT_DIR/../template/service/service-kubernetes.yml"

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set monitoring service
echo "==> Création du service monitoring:"
kubectl apply -f "$SCRIPT_DIR/../template/service/service-monitor.yml"