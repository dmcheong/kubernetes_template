#!/usr/bin/env bash

#

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm repo list | grep grafana

helm upgrade --install grafana grafana/grafana \
  -n observability \
  -f 03-grafana/helm-values/grafana.yaml \
  --wait

  kubectl get pods -n observability -l app.kubernetes.io/name=grafana

kubectl get secret grafana -n observability \
  -o jsonpath="{.data.admin-password}" | base64 -d ; echo

##
get into prometheus interface
# by NodePort
minikube service grafana -n observability --url

# by Port-forward: http://localhost:3000
kubectl port-forward svc/grafana 3000:80 -n observability

