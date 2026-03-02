#!/usr/bin/env bash

# This script check or update last version (set in the script) of asdf
# Install with wget

# for binairy user, here for asdf
LOCAL_BIN="$HOME/.local/bin"

mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# check if asdf exist if not install for kube-score, version 0.14.0
ASDF_MIN_VERSION="0.18.0"

echo "==> Vérification de l installation de l outil asdf."

export PATH="$HOME/.local/bin:$PATH"

if ! command -v asdf >/dev/null 2>&1; then
    echo "==> asdf n est pas installé."
    echo "==> Installation de asdf..."
    wget -q https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz
    tar -xzf asdf-v0.18.0-linux-amd64.tar.gz -C "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/asdf"
    rm -f asdf-v0.18.0-linux-amd64.tar.gz
else
      CURRENT_ASDF_VERSION="$(
        asdf version 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
        | head -n1
      )"

    if [ -z "$CURRENT_ASDF_VERSION" ]; then
        echo "==> Impossible de déterminer la version de asdf."
    elif version_lt "$CURRENT_ASDF_VERSION" "$ASDF_MIN_VERSION"; then
        echo "==> asdf n est pas à jour (actuelle: $CURRENT_ASDF_VERSION, min: $ASDF_MIN_VERSION)"
        echo "==> Mise à jour de asdf..."
        wget -q https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz
        tar -xzf asdf-v0.18.0-linux-amd64.tar.gz -C "$HOME/.local/bin"
        chmod +x "$HOME/.local/bin/asdf"
        rm -f asdf-v0.18.0-linux-amd64.tar.gz
    else
        echo "==> La version actuelle de asdf est à jour: $CURRENT_ASDF_VERSION"
    fi
fi