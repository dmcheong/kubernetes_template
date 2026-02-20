#!/usr/bin/env bash

# ce script permet la vérification de la dernire version de kubectl
# ou l'installe
# ou met à jour la dernière version indiquée
# installation via curl

# check if kubectl exist if not install, version above 1.34.0
echo "==> Vérification de l installation du service kubectl."

KUBECTL_VERSION="1.35.0"

if ! command -v kubectl > /dev/null 2>&1; then
    echo "==> kubectl n est pas installé."
    echo "==> Installation de la dernière version stable de kubectl ..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    CURRENT_KUBECTL_VERSION="$(kubectl version --client 2>/dev/null | awk -F': ' '/Client Version/ {gsub(/^v/,"",$2); print $2; exit}')"

    if [ -z "$CURRENT_KUBECTL_VERSION" ]; then
        echo "==> Impossible de récupérer la version kubectl (sortie inattendue)."
    elif  version_lt "$CURRENT_KUBECTL_VERSION" "$KUBECTL_VERSION" ; then
        echo "==> kubectl n est pas à jour."
        echo "==> Mise à jour de la dernière version stable de kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    else
        echo "==> La version actuelle de kubectl est à jour:"
        kubectl version --client
    fi
fi