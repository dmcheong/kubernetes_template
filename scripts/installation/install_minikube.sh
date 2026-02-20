#!/usr/bin/env bash

# ce script permet la vérification de la dernire version de Minikube
# ou l'installe
# ou met à jour la dernière version indiquée
# installation via curl et bash

# check if minikube exist if not install, version above 1.37.0
MINIKUBE_VERSION="1.37.0"

echo "==> Vérification de l installation du cluster minikube."

if ! command -v minikube > /dev/null 2>&1; then
    echo "==> Minikube n est pas installé."
    echo "==> Installation de la dernière version stable de minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    CURRENT_MINIKUBE_VERSION="$(minikube version --short 2>/dev/null | sed 's/^v//')"

    if version_lt "$CURRENT_MINIKUBE_VERSION" "$MINIKUBE_VERSION"; then
        echo "==> Minikube n est pas à jour:"
        echo "==> Mise à jour de la version stable de Minikube..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    else
        echo "==> La version actuelle de Minikube est à jour:"
        minikube version
    fi
fi