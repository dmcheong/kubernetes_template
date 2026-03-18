#!usr/bin/env bash
# script testing alert manager in local
# use namespace monitoring

# update helm 
# Update helm repo prometheus-community with alert-manager 
echo "==> Mise à jour de prometheus avec la configuration d alert-manager dans le namespace monitoring."
helm upgrade prometheus prometheus-community/prometheus \
  -n monitoring \
  -f ./../../template/rules/helm-values/alert-manager.yml \
  --wait

# check pods
echo "==> Vérification des pods dans le namespace monitoring"
kubectl get pods -n monitoring | grep alertmanager

# check services
echo "==> Vérification des services dans le namespace monitoring."
kubectl get services -n monitoring

# open browser dashboard
echo "==> Pour ouvrir le tableau de bord pour prometheux-alertmanager:"
kubectl port-forward svc/prometheus-alertmanager 9093:9093 -n monitoring

