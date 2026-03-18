#!/usr/bin/env bash

# This script check or update last version (set in the script) of kubescore
# Install with asdf

# set path for asdf librairy
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# check if kube-score exist if not install
echo "==> Vérification de l installation de kube-score."

# required kubescore version
KUBESCORE_MIN_VERSION="1.20.0"
KUBESCORE_TARGET_VERSION="1.20.0"

# plugin (Silent if already Hill)
asdf plugin add kube-score https://github.com/bageljp/asdf-kube-score.git >/dev/null 2>&1 || true

# install set version if not
if ! asdf list kube-score 2>/dev/null | tr -d ' '; then
  echo "==> Kube-Score n est pas installé."
  echo "==> Installation de kube-score version $KUBESCORE_TARGET_VERSION via asdf..."
  asdf install kube-score "$KUBESCORE_TARGET_VERSION" >/dev/null
fi

# set version for this repertorie (create/write .tool-versions)
asdf set kube-score "$KUBESCORE_TARGET_VERSION" >/dev/null
asdf reshim kube-score >/dev/null 2>&1 || true

# get version (silent + parsing)
CURRENT_KUBESCORE_VERSION="$(
  kube-score version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
)"
echo "==> Kube-Score est maintenant installé en version: $CURRENT_KUBESCORE_VERSION"

# exit if error
if [ -z "$CURRENT_KUBESCORE_VERSION" ]; then
  echo "==> Impossible de déterminer la version kube-score."
fi

if version_lt "$CURRENT_KUBESCORE_VERSION" "$KUBESCORE_MIN_VERSION"; then
  echo "==> kube-score n est pas à jour (actuelle: $CURRENT_KUBESCORE_VERSION, min: $KUBESCORE_MIN_VERSION)"
else
  echo "==> La version actuelle de kube-score est à jour: $CURRENT_KUBESCORE_VERSION"
fi