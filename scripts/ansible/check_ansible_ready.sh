#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ANSIBLE_DIR="${ROOT_DIR}/ansible"

CONFIG_FILE="${ANSIBLE_DIR}/ansible.cfg"

INVENTORY_FILE="${ANSIBLE_DIR}/inventory/local.ini"

#########################################
# LOGGING
#########################################

log() {

    local level="$1"
    shift

    case "$level" in
        INFO)
            echo "[INFO] $*"
            ;;
        SUCCESS)
            echo "[SUCCESS] $*"
            ;;
        ERROR)
            echo "[ERROR] $*"
            ;;
    esac

}

#########################################
# CHECKS
#########################################

require_binary() {

    local binary="$1"

    if ! command -v "$binary" >/dev/null
    then

        log ERROR "$binary absent"

        exit 1

    fi

}

require_file() {

    local file="$1"

    if [[ ! -f "$file" ]]
    then

        log ERROR "Fichier manquant : $file"

        exit 1

    fi

}

#########################################
# VALIDATION
#########################################

validate_ansible() {

    require_binary ansible

    require_binary ansible-playbook

    require_binary ansible-galaxy

    require_binary python3

}

validate_structure() {

    require_file "${CONFIG_FILE}"

    require_file "${INVENTORY_FILE}"

}

validate_execution() {

    export ANSIBLE_CONFIG="${CONFIG_FILE}"

    ansible localhost \
        -i "${INVENTORY_FILE}" \
        -m ping \
        >/dev/null

}

#########################################
# MAIN
#########################################

main() {

    log INFO "Validation environnement Ansible"

    validate_ansible

    validate_structure

    validate_execution

    log SUCCESS "Environnement Ansible prêt"

}

main "$@"