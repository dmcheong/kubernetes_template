#!/usr/bin/env bash

# ce script regroupe la liste des outils/scripts qui permettront le bon déroulement
# automatique du déploiement du cluster Minikube
# si un script ne détecte pas l'outil, il sera installé ou mis à jour 

# fonction de comparaison des outils à utiliser avec cette syntaxe
# version_lt "CURRENT_VERSION_TOOL" "TOOL_MINIMUM_VERSION"
version_lt() {
  # true (0) si $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

echo "==> Exécution du script de vérification des outils minimum:"
echo

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# helm
source "$SCRIPT_DIR/install_helm.sh"

# kubectl
source "$SCRIPT_DIR/install_kubectl.sh"

# Minikube
source "$SCRIPT_DIR/install_minikube.sh"

# asdf
source "$SCRIPT_DIR/install_asdf.sh"

# kube-score
source "$SCRIPT_DIR/install_kubescore.sh"

# kubeseal
source "$SCRIPT_DIR/install_kubeseal.sh"

# sealedsecret
source "$SCRIPT_DIR/install_sealedsecret.sh"

echo
echo "==> Les services kubectl, minikube, asdf, helm, kube-score et kubeseal+sealedsecret sont à jour."
echo "==> Toutes les vérifications sont terminées."
echo