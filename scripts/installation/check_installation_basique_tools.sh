#!/usr/bin/env bash
# list of all scripts about basique tools => check install or upgrade tools

# function to comparison tools, use like this:
# version_lt "CURRENT_VERSION_TOOL" "TOOL_MINIMUM_VERSION"
version_lt() {
  # true (0) si $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

echo "==> Exécution du script de vérification des outils minimum:"
echo

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# docker
source "$SCRIPT_DIR/install_docker_engine.sh"

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
echo "==> Les services helm, kubectl, minikube, asdf, kube-score et kubeseal+sealedsecret sont à jour."
echo "==> La vérification de tous les outils est terminée (installation + mise à jour)."
echo