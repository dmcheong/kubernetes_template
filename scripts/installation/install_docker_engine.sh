#!/usr/bin/env bash

# This script check the last version (set in the script) of docker engine

MIN_DOCKER_VERSION="24.0.0"

version_lt() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

echo "==> Vérification de Docker Engine:"

if ! command -v docker >/dev/null 2>&1; then
  echo "==> ERREUR: Docker n'est pas installé."
  echo "==> Veuillez installez Docker Engine avant de continuer."
  exit 1
fi

CURRENT_VERSION="$(
  docker version --format '{{.Server.Version}}' 2>/dev/null || true
)"

if [ -z "$CURRENT_VERSION" ]; then
  echo "==> ERREUR: Impossible de déterminer la version de Docker."
  echo "==> Vérifiez que le daemon Docker fonctionne."
  exit 1
fi

echo "==> Version Docker Engine détectée: $CURRENT_VERSION"

if version_lt "$CURRENT_VERSION" "$MIN_DOCKER_VERSION"; then
  echo "==> ERREUR: Version Docker trop ancienne."
  echo "==> Version minimum requise: $MIN_DOCKER_VERSION"
  echo "==> Version installée: $CURRENT_VERSION"
  exit 1
fi

echo "==> La version de Docker Engine est compatible: $CURRENT_VERSION"
