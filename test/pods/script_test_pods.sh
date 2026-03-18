#!/usr/bin/env bash
# script testing pod in local

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set s by template.yml
# temps d attente pour le déploiement correct des images
echo "==> Application d un pod nginx:"
kubectl apply -f "$SCRIPT_DIR/../template/pods/pod-nginx.yml"
kubectl wait --for=condition=Ready pod/mon-pod --timeout=3s
echo "==> Application d un pod alpine (default not running)"
kubectl apply -f "$SCRIPT_DIR/../template/pods/pod-alpine.yml"

# check stats pods
echo "==> Vérification de tous les pods."
kubectl get pods

# check logs
ehco "==> Logs du pod: mon-pod:"
kubectl logs mon-pod
echo "==> Logs du pod: mon-pod-alpine:"
kubectl logs mon-pod-alpine

# check pods in namespaces
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# delete pods
# kubectl delete mon-pod
# kubectl delete mon-pod-alpine
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-nginx.yml"
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-alpine.yml"