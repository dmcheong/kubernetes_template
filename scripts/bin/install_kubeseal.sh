#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_kubeseal.sh
# Description  : Configure le partage NFS et installe kubeseal via asdf
# Dépendances  : core.sh, global.env, asdf
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
# log date time file
log_timestamp=$(date '+%Y-%m-%d_%H_%M_%S')
# log file path
log_file="${root_path}/log/build_all_${log_timestamp}.log"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

if [[ ${core_functions_loaded} -ne 1 ]]
  then
    . "${root_path}/lib/core.sh"
fi

# add asdf in path to use installed tools
export PATH="${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

function install_nfs()
{
  # ---- 1) package nfs-kernel-server ----
  set_message "check" "0" "Vérification du package nfs-kernel-server"
  if ! dpkg -s nfs-kernel-server >/dev/null 2>&1; then
    set_message "info" "0" "Le package nfs-kernel-server n'est pas installé - installation en cours"
    sudo apt update
    sudo apt install -y nfs-kernel-server
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Le package nfs-kernel-server est déjà installé"
  fi

  # ---- 2) dossier partagé ----
  # permissions larges pour environnement dev uniquement
  set_message "check" "0" "Préparation du dossier partagé NFS: ${NFS_SHARE_DIR}"
  sudo mkdir -p "${NFS_SHARE_DIR}"
  error_CTRL "${?}" ""

  sudo chmod 777 "${NFS_SHARE_DIR}"
  error_CTRL "${?}" ""

  # ---- 3) configuration exports ----
  # *  -> autorise all clients | rw -> read/write | sync -> synchro écriture
  # no_subtree_check -> évite vérif sous-dossiers | no_root_squash -> env dev uniquement
  EXPORT_LINE="${NFS_SHARE_DIR} *(rw,sync,no_subtree_check,no_root_squash)"

  set_message "check" "0" "Création du dossier ${NFS_EXPORT_DIR} si absent"
  sudo mkdir -p "${NFS_EXPORT_DIR}"
  error_CTRL "${?}" ""

  set_message "check" "0" "Nettoyage des anciennes entrées /data dans /etc/exports"
  if sudo grep -qE "^[[:space:]]*/data([[:space:]]+|$)" /etc/exports 2>/dev/null; then
    sudo cp /etc/exports "/etc/exports.bak.$(date +%Y%m%d-%H%M%S)"
    sudo sed -i -E "/^[[:space:]]*\/data([[:space:]]+|$)/d" /etc/exports
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Aucune ancienne ligne /data trouvée dans /etc/exports"
  fi

  set_message "check" "0" "Ecriture des exports NFS dans ${NFS_EXPORT_FILE}"
  echo "${EXPORT_LINE}" | sudo tee "${NFS_EXPORT_FILE}" >/dev/null
  error_CTRL "${?}" ""

  # ---- 4) rechargement du service NFS ----
  set_message "check" "0" "Rechargement des exports NFS et redémarrage du service"
  sudo exportfs -rav
  error_CTRL "${?}" ""

  # le nom du service dépend de la distribution Linux
  sudo systemctl restart nfs-server 2>/dev/null || sudo systemctl restart nfs-kernel-server

  # ---- 5) vérification ----
  set_message "info" "0" "Listes des exports actifs:"
  sudo exportfs -v
  set_message "EdSMessage" "0" "Le serveur NFS est prêt"
}

function install_kubeseal_tool()
{
  set_message "check" "0" "Vérification de la présence de asdf"
  command -v asdf > /dev/null 2>&1
  if [[ ! ${?} == "0" ]]
    then
      set_message "EdEMessage" "1" "L'outil asdf est requis pour l'installation de kubeseal"
  fi

  set_message "check" "0" "Ajout du plugin kubeseal à asdf (idempotent)"
  asdf plugin add kubeseal https://github.com/crainte/asdf-kubeseal >/dev/null 2>&1 || true

  set_message "check" "0" "Vérification de la présence de kubeseal dans asdf"
  if ! asdf list kubeseal 2>/dev/null | grep -q .; then
    set_message "info" "0" "Installation de kubeseal latest via asdf"
    asdf install kubeseal latest >/dev/null
    error_CTRL "${?}" ""
  fi

  set_message "check" "0" "Activation de la version globale kubeseal latest"
  asdf set -u kubeseal latest >/dev/null
  error_CTRL "${?}" ""

  set_message "check" "0" "Reconstruction des shims asdf"
  asdf reshim kubeseal >/dev/null 2>&1 || true
}


# ---- Flux principal ----
set_message "check" "0" "Vérification de la configuration NFS"
if ! dpkg -s nfs-kernel-server >/dev/null 2>&1; then
  set_message "EdWMessage" "0" "NFS non configuré - configuration en cours"
  install_nfs
  if [[ ! ${?} == "0" ]]
    then
      set_message "EdEMessage" "5" "Echec de la configuration NFS"
    else
      set_message "EdSMessage" "0" "NFS configuré avec succès"
  fi
else
  set_message "EdSMessage" "0" "NFS déjà configuré"
fi

set_message "check" "0" "Vérification de l'installation de l'outil kubeseal"
command -v kubeseal > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "kubeseal absent - installation nécessaire"
    install_kubeseal_tool
    set_message "check" "0" "Vérification de l'installation de l'outil kubeseal"
    command -v kubeseal > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l'installation de kubeseal"
      else
        set_message "EdSMessage" "0" "kubeseal installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "kubeseal présent"
    set_message "info" "0" "version kubeseal active: $(kubeseal --version 2>/dev/null || true)"
fi
