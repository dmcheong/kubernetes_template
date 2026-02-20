#!/usr/bin/env bash

# 

kubectl create namespace observability

kubectl get ns observability

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm repo list | grep 

# own prometheus exposed metrics
kubectl port-forward svc/prometheus-server 9090:80 -n observability

# in others terminal
curl http://localhost:9090/metrics 2>/dev/null | head -30

##
# install by helm with yml file
# check file.yml
helm upgrade --install prometheus prometheus-community/prometheus \
  -n observability \
  -f 02-prometheus/helm-values/prometheus-minimal.yaml \
  --wait

# check prometheus
kubectl get pods -n observability | grep -E 'prometheus-server|kube-state-metrics|node-exporter'

# to check logs
kubectl logs -n observability -l app.kubernetes.io/name=prometheus -c prometheus-server --tail=50

##
get into prometheus interface
# by NodePort
minikube service prometheus-server -n observability --url

# by Port-forward: http://localhost:9090
kubectl port-forward svc/prometheus-server 9090:80 -n observability

## here: example for fichier.yml to get scraped by prometheus
apiVersion: v1
kind: Pod
metadata:
  name: mon-app
  annotations:
    prometheus.io/scrape: "true"    # Active le scraping
    prometheus.io/port: "8080"       # Port de l'endpoint /metrics
    prometheus.io/path: "/metrics"   # Chemin (par défaut /metrics)