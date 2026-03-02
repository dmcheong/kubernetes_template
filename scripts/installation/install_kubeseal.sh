#!/usr/bin/env bash

# This script check or update last version (set in the script) of kubeseal
# Install with asdf 

# check if NFS exist if not install
echo "==> Vérification / installation du serveur NFS"

# ---- 1) check package ----
if ! dpkg -s nfs-kernel-server >/dev/null 2>&1; then
  echo "==> nfs-kernel-server non installé -> installation"
  sudo apt update
  sudo apt install -y nfs-kernel-server
else
  echo "==> nfs-kernel-server déjà installé"
fi

# ---- 2) shared repertorie ----
SHARE_DIR="/data"
echo "==> Préparation du dossier partagé: $SHARE_DIR"
sudo mkdir -p "$SHARE_DIR"
# set permission for TP/lab. To hardenning in prod.
sudo chmod 777 "$SHARE_DIR"

# ---- 3) Exports source ----
EXPORT_DIR="/etc/exports.d"
EXPORT_FILE="$EXPORT_DIR/k8s-nfs.exports"
EXPORT_LINE="$SHARE_DIR *(rw,sync,no_subtree_check,no_root_squash)"

echo "==> Création du dossier $EXPORT_DIR si absent"
sudo mkdir -p "$EXPORT_DIR"

echo "==> Nettoyage des anciennes entrées /data dans /etc/exports (si présentes)"
# delete only lines beginnig by "/data " (or "/data<TAB>")
# keep the other entry in file intact.
if sudo grep -qE "^[[:space:]]*/data([[:space:]]+|$)" /etc/exports 2>/dev/null; then
  sudo cp /etc/exports "/etc/exports.bak.$(date +%Y%m%d-%H%M%S)"
  sudo sed -i -E "/^[[:space:]]*\/data([[:space:]]+|$)/d" /etc/exports
  echo "==> Anciennes lignes /data supprimées de /etc/exports (backup créé)"
else
  echo "==> Aucune ancienne ligne /data trouvée dans /etc/exports"
fi

echo "==> Écriture export dans $EXPORT_FILE"
echo "$EXPORT_LINE" | sudo tee "$EXPORT_FILE" >/dev/null

# ---- 4) Reload / restart ----
echo "==> Rechargement exports + redémarrage NFS"
sudo exportfs -rav

# wich distro, existing one of the name service
sudo systemctl restart nfs-server 2>/dev/null || sudo systemctl restart nfs-kernel-server

# ---- 5) checking ----
echo
echo "==> Exports actifs :"
sudo exportfs -v

echo "==> Serveur NFS prêt."

# check if kubeseal exist if not install
echo "==> Vérification de kubeseal"

export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

if ! command -v asdf >/dev/null 2>&1; then
  echo "ERREUR: asdf requis pour kubeseal"
  exit 1
fi

# plugin kubeseal (idempotent)
asdf plugin add kubeseal https://github.com/crainte/asdf-kubeseal >/dev/null 2>&1 || true

# install latest si absent
if ! asdf list kubeseal 2>/dev/null | grep -q .; then
  echo "==> Installation kubeseal via asdf"
  asdf install kubeseal latest >/dev/null
fi

# set version globale (ou enlève -u pour projet local)
asdf set -u kubeseal latest >/dev/null
asdf reshim kubeseal >/dev/null 2>&1 || true

# vérification
if ! command -v kubeseal >/dev/null 2>&1; then
  echo "ERREUR: kubeseal introuvable après installation"
  exit 1
fi

kubeseal --version