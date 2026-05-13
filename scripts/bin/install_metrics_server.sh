#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_metrics_server.sh
# Description  : Vérifie et installe/met à jour metrcis-server
# Dépendances  : core.sh, global.env, asdf
#===============================================================================

# Télécharger le manifeste officiel
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Sur un serve sans certificat TLS
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Attendre que metrics-server soit prêt
kubectl -n kube-system rollout status deployment/metrics-server --timeout=90s

# Vérifiez que l API Metrics est disponible 
kubectl get apiservices | grep metrics
