#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_pods.sh
# Description  : Déploie deux pods de test (nginx + alpine) dans le namespace dev
#                et vérifie leur état et leurs logs.
# Prérequis    : namespace dev créé, kubectl disponible
# Note         : le pod alpine démarre mais reste en CrashLoopBackOff (normal —
#                il n'a pas de commande de maintien en vie)
#===============================================================================

# chemin absolu pour référencer les templates indépendamment du répertoire courant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Déploiement des pods depuis les templates YAML
# pod-nginx.yml  → pod "mon-pod"        (nginx, port 80, namespace dev)
# pod-alpine.yml → pod "mon-pod-alpine" (alpine, namespace dev)
# Note : alpine ne reste pas en Running par défaut (pas de processus long)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Application d un pod nginx:"
kubectl apply -f "$SCRIPT_DIR/../template/pods/pod-nginx.yml"

# attendre 3 secondes que le pod soit prêt (timeout court, ajuster si lent)
kubectl wait --for=condition=Ready pod/mon-pod --timeout=3s

echo "==> Application d un pod alpine (default not running)"
kubectl apply -f "$SCRIPT_DIR/../template/pods/pod-alpine.yml"

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'état des pods
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérification de tous les pods."
kubectl get pods

#─────────────────────────────────────────────────────────────────────────────
# Récupération des logs
#─────────────────────────────────────────────────────────────────────────────
# correction : "ehco" → "echo"
echo "==> Logs du pod: mon-pod:"
kubectl logs mon-pod

echo "==> Logs du pod: mon-pod-alpine:"
kubectl logs mon-pod-alpine

# vérification dans le namespace dev
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# commandes de nettoyage (décommenter si nécessaire) :
# kubectl delete pod mon-pod
# kubectl delete pod mon-pod-alpine
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-nginx.yml"
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-alpine.yml"
