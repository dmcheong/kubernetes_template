#!/usr/bin/env bash

# This script check or update last version (set in the script) of minikube
# Install with curl adn bash

# check if minikube exist if not install, version above 1.37.0
echo "==> Vérification de l installation du cluster minikube."

# required minikube version
MINIKUBE_MIN_VERSION="1.37.0"

# check if minikube exists or install it
if ! command -v minikube > /dev/null 2>&1; then
    echo "==> Minikube n est pas installé."
    echo "==> Installation de la dernière version stable de minikube ..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    CURRENT_MINIKUBE_VERSION="$(minikube version --short 2>/dev/null | sed 's/^v//')"
    echo "==> Minikube est maintenant installé en version: $CURRENT_MINIKUBE_VERSION"

# check helm version and upgrade if necessary
    if [ -z "$CURRENT_MINIKUBE_VERSION" ]; then
        echo "==> Impossible de déterminer la version de Minikube (error)."
    elif version_lt "$CURRENT_MINIKUBE_VERSION" "$MINIKUBE_MIN_VERSION"; then
        echo "==> Minikube n est pas à jour (actuelle: $CURRENT_MINIKUBE_VERSION, min: $MINIKUBE_MIN_VERSION)"
        echo "==> Mise à jour de la version stable de Minikube ..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    else
        echo "==> La version actuelle de Minikube est à jour: $CURRENT_MINIKUBE_VERSION"
    fi
fi