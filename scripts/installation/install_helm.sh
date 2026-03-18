#!/usr/bin/env bash

# This script check or update last version (set in the script) of helm
# Install with bash

# check if helm exist if not install, version above 3.14.0
echo "==> Vérification de l installation du service Helm."

# required helm version
HELM_MIN_VERSION="3.14.0"

# check if helm exists or install it
if ! command -v helm >/dev/null 2>&1; then
  echo "==> Helm n est pas installé."
  echo "==> Installation de la dernière version stable de helm ..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  CURRENT_HELM_VERSION="$(
    helm version --short 2>/dev/null \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | head -n1
  )"
  echo "==> Helm est maintenant installé en version: $CURRENT_HELM_VERSION"

# check helm version and upgrade if necessary
  if [ -z "$CURRENT_HELM_VERSION" ]; then
    echo "==> Impossible de déterminer la version de Helm (error)."
  elif version_lt "$CURRENT_HELM_VERSION" "$HELM_MIN_VERSION"; then
    echo "==> Helm n est pas à jour (actuelle: $CURRENT_HELM_VERSION, min: $HELM_MIN_VERSION)"
    echo "==> Mise à jour de la dernière version stable de Helm ..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  else
    echo "==> La version actuelle de helm est bien à jour: $CURRENT_HELM_VERSION"
  fi
fi