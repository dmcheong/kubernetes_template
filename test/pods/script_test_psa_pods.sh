#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_psa_pods.sh
# Description  : Déploie deux pods de test (nginx) dans le namespace developpement et production
#                et vérifie leur état et leurs logs.
#                Cela doit servir d'exemple pour le test de mise en place de pod respectant la politique de Pods Security Admission
# Prérequis    : namespace developpement et production créé, kubectl disponible
# Source       : https://blog.teknews.cloud/kubernetes/aks/security/2026/04/16/Playing_with_Pod_Security_Admission.html
#===============================================================================
set_message "info" "0" "Gestion des pods avec la mise en place de la politique de Pods Security Admission et test."
printf "%b\n"

# Utilisation du paramètre set_message "debug" "0" ""
DEBUG_MODE="1"

# chemin absolu pour référencer les templates indépendamment du répertoire courant
POD_PSA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Vérification des labels PSA
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Vérification des labels Pods Security Admission"
kubectl get ns developpement --show-labels
printf "%b\n"
kubectl get ns production --show-labels
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# Déploiement des pods depuis les templates YAML
# pod-dev-psa.yml  → pod "nginx-dev"        (nginx, port 80, namespace developpement)
# pod-prod-psa.yml → pod "nginx-prod" (alpine, namespace production)
# Note : alpine ne reste pas en Running par défaut (pas de processus long)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Application d un pod nginx avec restriction de developpement:"
if kubectl get pod nginx-dev -n developpement >/dev/null 2>&1; then
    set_message "info" "0" "Le pod existe déjà on continue"
else
    kubectl apply -f "$POD_PSA_DIR/../template/pods/pod-dev-psa.yml"
    error_CTRL "${?}" "Operation completed"

    # attendre 30 secondes que le pod soit prêt (timeout court, ajuster si lent)
    set_message "info" "0" "Temps d attente avec latence volontaire pour le pod pour éviter des erreurs sur la suite des commandes; jusqu à 40s."
    sleep 30
    kubectl wait --for=jsonpath='{.status.phase}'=Active ns/developpement --timeout=10s
    error_CTRL "${?}" "Operation completed"
fi

set_message "info" "0" "Application d un pod nginx avec restriction de production:"
if kubectl get pod nginx-prod -n production >/dev/null 2>&1; then
    set_message "info" "0" "Le pod existe déjà on continue"
else
    kubectl apply -f "$POD_PSA_DIR/../template/pods/pod-prod-psa.yml"
    error_CTRL "${?}" "Operation completed"

    # attendre 30 secondes que le pod soit prêt (timeout court, ajuster si lent)
    set_message "info" "0" "Temps d attente avec latence volontaire pour le pod pour éviter des erreurs sur la suite des commandes; jusqu à 40s."
    sleep 30
    kubectl wait --for=jsonpath='{.status.phase}'=Active ns/developpement --timeout=10s
    error_CTRL "${?}" "Operation completed"
fi
#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'état des pods
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de tous les pods."
kubectl get pods -n developpement
error_CTRL "${?}" "Operation completed"
kubectl get pods -n production
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Récupération des logs
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Logs du pod: nginx-dev:"
kubectl logs nginx-dev -n developpement
error_CTRL "${?}" "Operation completed"

# vérification dans le namespace developpement
set_message "check" "0" "Liste des pods dans l environnement namespaces -> developpement:"
kubectl get pods -n developpement
error_CTRL "${?}" "Operation completed"

set_message "debug" "0" "Logs du pod: nginx-prod:"
kubectl logs nginx-prod -n production
error_CTRL "${?}" "Operation completed"

# vérification dans le namespace production
set_message "check" "0" "Liste des pods dans l environnement namespaces -> production:"
kubectl get pods -n production
error_CTRL "${?}" "Operation completed"

# commandes de nettoyage (décommenter si nécessaire) :
# set_message "info" "0" "Nettoyage des pods de test"
# kubectl delete pod nginx-dev
# kubectl delete pod nginx-prod
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-dev-psa.yml"
# kubectl delete -f "$SCRIPT_DIR/../template/pods/pod-prod-psa.yml"

#─────────────────────────────────────────────────────────────────────────────
# test avec un pod non conforme
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Test volontaire d un pod non conforme dans developpement et production"

set_message "info" "0" "retour de l application dans le namespace developpement:"
OUTPUT_DEV=$(kubectl apply -f "$POD_PSA_DIR/../template/pods/dangerous-pod.yml" -n developpement)
printf "%b\n"

set_message "info" "0" "retour de l application dans le namespace production:"
OUTPUT_PROD=$(kubectl apply -f "$POD_PSA_DIR/../template/pods/dangerous-pod.yml" -n production)
printf "%b\n"