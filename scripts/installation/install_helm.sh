#!/usr/bin/env bash

# ce script permet la vérification de la dernire version de helm
# ou l'installe
# ou met à jour la dernière version indiquée
# installation via curl et bash

# check if helm exist if not install, version above 3.14.0
echo "==> Vérification de l installation du service Helm."

HELM_MIN_VERSION="3.14.0"

if ! command -v helm >/dev/null 2>&1; then
  echo "==> Helm non installé -> installation..."

  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

else
  CURRENT_HELM_VERSION="$(
    helm version --short 2>/dev/null \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | head -n1
  )"

  if [ -z "$CURRENT_HELM_VERSION" ]; then
    echo "==> Impossible de déterminer la version Helm:"
    helm version
  elif version_lt "$CURRENT_HELM_VERSION" "$HELM_MIN_VERSION"; then
    echo "==> Helm n est pas à jour (actuelle: $CURRENT_HELM_VERSION, min: $HELM_MIN_VERSION)"
    echo "==> Mise à jour de Helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  else
    echo "==> Helm est maintenant à jour: $CURRENT_HELM_VERSION"
  fi
fi