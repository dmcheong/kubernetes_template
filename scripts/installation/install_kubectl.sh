#!/usr/bin/env bash

# This script check or update last version (set in the script) of kubectl
# Install with curl

# check if kubectl exist if not install, version above 1.34.0
echo "==> Vérification de l installation du service kubectl."

# required kubectl version
KUBECTL_VERSION="1.35.0"

# check if kubectl exists or install it
if ! command -v kubectl > /dev/null 2>&1; then
    echo "==> kubectl n est pas installé."
    echo "==> Installation de la dernière version stable de kubectl ..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    CURRENT_KUBECTL_VERSION="$(kubectl version --client 2>/dev/null | awk -F': ' '/Client Version/ {gsub(/^v/,"",$2); print $2; exit}')"
    echo "==> Kubectl est maintenant installé en version: $CURRENT_KUBECTL_VERSION"

    if [ -z "$CURRENT_KUBECTL_VERSION" ]; then
        echo "==> Impossible de déterminer la version de kubectl (error)."
    elif  version_lt "$CURRENT_KUBECTL_VERSION" "$KUBECTL_VERSION" ; then
        echo "==> kubectl n est pas à jour (actuelle: $CURRENT_KUBECTL_VERSION, min: $KUBECTL_VERSION)"
        echo "==> Mise à jour de la dernière version stable de kubectl ..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    else
        echo "==> La version actuelle de kubectl est bien à jour: $CURRENT_KUBECTL_VERSION"
    fi
fi