#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_pods.sh
# Description  : Déploie deux pods de test (nginx + alpine) dans le namespace dev
#                et vérifie leur état et leurs logs.
# Prérequis    : namespace dev créé, kubectl disponible
# Note         : le pod alpine démarre mais reste en CrashLoopBackOff (normal —
#                il n'a pas de commande de maintien en vie)
#===============================================================================
set_message "info" "0" "Gestion des pods."
printf "%b\n"

# Utilisation du paramètre set_message "debug" "0" ""
DEBUG_MODE="1"

# chemin absolu pour référencer les templates indépendamment du répertoire courant
POD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Déploiement des pods depuis les templates YAML
# pod-nginx.yml  → pod "mon-pod"        (nginx, port 80, namespace dev)
# pod-alpine.yml → pod "mon-pod-alpine" (alpine, namespace dev)
# Note : alpine ne reste pas en Running par défaut (pas de processus long)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Application d un pod nginx:"
if kubectl get pod mon-pod -n dev >/dev/null 2>&1; then
    set_message "info" "0" "Le pod existe déjà on continue"
else
    kubectl apply -f "$POD_DIR/../template/pods/pod-nginx.yml"
    error_CTRL "${?}" "Operation completed"

    # attendre 30 secondes que le pod soit prêt (timeout court, ajuster si lent)
    set_message "info" "0" "Temps d attente avec latence volontaire pour le pod pour éviter des erreurs sur la suite des commandes; 30s."
    kubectl wait --for=condition=Ready pod/mon-pod --timeout=30s
    error_CTRL "${?}" "Operation completed"
fi

set_message "info" "0" "Application d un pod alpine (default not running)"
kubectl apply -f "$POD_DIR/../template/pods/pod-alpine.yml"
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'état des pods
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de tous les pods."
kubectl get pods
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Récupération des logs
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Logs du pod: mon-pod:"
kubectl logs mon-pod
error_CTRL "${?}" "Operation completed"

# vérification dans le namespace dev
set_message "check" "0" "Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev
error_CTRL "${?}" "Operation completed"

# commandes de nettoyage (décommenter si nécessaire) :
# set_message "info" "0" "Nettoyage des pods de test"
# kubectl delete pod mon-pod
# kubectl delete pod mon-pod-alpine
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-nginx.yml"
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-alpine.yml"

printf "%b\n"