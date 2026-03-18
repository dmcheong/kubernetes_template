#!/usr/bin/env bash

# This script check or update last version (set in the script) of kubeseal
# Install with asdf 

# ---- 1) check package ----
# Check if package nfs-kernel-server is already existing
# dpkg -s return 0 if existing package
# >/dev/null 2>&1 hide standard exit and error
if ! dpkg -s nfs-kernel-server >/dev/null 2>&1; then
  echo "==> Le package nfs-kernel-server n est pas installé."
  echo "==> Installation de la dernière version stable du package nfs-kernel-server."
  
  # update packages
  sudo apt update
  
  # install nfs package without yes confirmation (-y)
  sudo apt install -y nfs-kernel-server
else
  
  # echo if nfs package is already installed
  echo "==> Le package nfs-kernel-server déjà installé."
fi


# ---- 2) shared repertorie ----
# setshared folder for NFS
SHARE_DIR="/data"
echo "==> Préparation du dossier partagé: $SHARE_DIR"

# Create folder if not exists (-p avoid error if already create)
sudo mkdir -p "$SHARE_DIR"

# give permission for all (rwx)
# use for dev environnement. To hardenning in production
sudo chmod 777 "$SHARE_DIR"


# ---- 3) Exports source ----
# /etc/exports.d is a folder for adding exports NFS 
# with some separeted folders (better than update /etc/exports directly)
EXPORT_DIR="/etc/exports.d"

# configuration NFS folder name
EXPORT_FILE="$EXPORT_DIR/k8s-nfs.exports"

# Ligne NFS configuration
# *  -> autorise all clients
# rw -> read / write
# sync -> writing synchronisation (better)
# no_subtree_check -> avoid some check for sub-folders
# no_root_squash -> client root is server root (do not do taht in prod)
EXPORT_LINE="$SHARE_DIR *(rw,sync,no_subtree_check,no_root_squash)"

echo "==> Création du dossier $EXPORT_DIR si absent."

# create folder exports.d if necessaire
sudo mkdir -p "$EXPORT_DIR"

# cleaning
echo "==> Nettoyage des anciennes entrées /data dans /etc/exports (si présentes)."

# delete only lignes beginning with "/data" without deleting existing exports 
# check if ligne /data exists in /etc/exports
if sudo grep -qE "^[[:space:]]*/data([[:space:]]+|$)" /etc/exports 2>/dev/null; then

  # Save file before update
  sudo cp /etc/exports "/etc/exports.bak.$(date +%Y%m%d-%H%M%S)"

  # Delete lignes about /data
  sudo sed -i -E "/^[[:space:]]*\/data([[:space:]]+|$)/d" /etc/exports

  echo "==> Anciennes lignes /data supprimées de /etc/exports (backup créé)."
else
  echo "==> Aucune ancienne ligne /data trouvée dans /etc/exports."
fi

echo "==> Écriture des exports dans $EXPORT_FILE"

# write NFS configuration in specific file
# tee can write with sudo permission
echo "$EXPORT_LINE" | sudo tee "$EXPORT_FILE" >/dev/null


# ---- 4) Reload / restart ----
echo "==> Rechargement des exports et redémarrage NFS"

# Reload NFS configuration configuration
# -r = reload
# -a = all exports
# -v = verbose
sudo exportfs -rav


# Reload NFS service
# service name depend on Linux distribution
sudo systemctl restart nfs-server 2>/dev/null || sudo systemctl restart nfs-kernel-server


# ---- 5) checking ----
echo
echo "==> Listes des exports actifs :"

# show actual actifs exports
sudo exportfs -v

echo "==> Le serveur NFS est prêt."

##
# check if kubeseal exist if not install
echo "==> Vérification de l installation de l outil: kubeseal"

# add asdf in path to use installed tools
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# check if asdf exists
if ! command -v asdf >/dev/null 2>&1; then
  echo "==> ERREUR: l outil asdf est requis pour l installation de kubeseal."
  exit 1
fi

# add kubeseal plugin to asdf
# || true avoid error if plugin already exists
asdf plugin add kubeseal https://github.com/crainte/asdf-kubeseal >/dev/null 2>&1 || true

# install kubeseal if none exists
if ! asdf list kubeseal 2>/dev/null | grep -q .; then
  echo "==> Installation de l outil de kubeseal via asdf."
  asdf install kubeseal latest >/dev/null
fi

#Define kubeseal latest for global version (-u) 
# without -u, this will be in local project
asdf set -u kubeseal latest >/dev/null

# Rebuild shims asdf to get kubeseal access
asdf reshim kubeseal >/dev/null 2>&1 || true

# check if kubeseal now exists
if ! command -v kubeseal >/dev/null 2>&1; then
  echo "==> ERREUR: kubeseal est introuvable après installation."
  exit 1
fi

# show version of kubeseal
# kubeseal version is set in ./tool-versions
echo "==> la version de kubeseal est:"
# you have to set path for execut cmd: kubeseal --
cat ./../../.tool-versions
