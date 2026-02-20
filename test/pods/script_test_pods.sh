#!/usr/bin/env bash
# script testing pod in local

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set s by template.yml
# temps d attente pour le déploiement correct des images
kubectl apply -f "$SCRIPT_DIR/../template/pod-nginx.yml"
kubectl wait --for=condition=Ready pod/mon-pod --timeout=3s
kubectl apply -f "$SCRIPT_DIR/../template/pod-alpine.yml"

# check stats pods
kubectl get pods

# check logs
kubectl logs mon-pod
kubectl logs mon-pod-alpine

# check pods in namespaces
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# delete pods
# kubectl delete mon-pod
# kubectl delete mon-pod-alpine
# kubectl delete -f "$SCRIPT_DIR/../template/pod-nginx.yml"
# kubectl delete -f "$SCRIPT_DIR/../template/pod-alpine.yml"