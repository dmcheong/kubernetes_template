#!usr/bin/env bash
# script testing scaling with prometheus in local
# use namespace monitoring

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# update helm in monitoring namespace for prometheus-adapter
# prometheus adapter is already in prometheus-community.github
# no need to update helm repo, just install specifiq tool
echo "==> A cette étape, le repo helm devrait déjà être à jour sur le github: prometheus-community."
echo "==> Installation de l outil prometheus-adapter depuis le github: prometheus-community"
echo "==> installation dans le namespace monitoring en prenant en compte un fichier.yml spécifique pour la configuration."
helm install prometheus-adapter prometheus-community/prometheus-adapter \
  -n monitoring \
  -f "$SCRIPT_DIR/../../template/alerting/rules/adapter-values.yml"

# check
echo "==> Vérification des metrics spécifiques."
kubectl get apiservices | grep metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# apply horizental prometheus autoscaling rules
echo "Application des règles pour l autoscaling horizentale."
kubectl apply -f "$SCRIPT_DIR/../../template/alerting/rules/hpa.yml"