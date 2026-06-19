#!/usr/bin/env bash

set -euo pipefail

#########################################
# PATHS
#########################################

ROOT_DIR="$(
cd "$(dirname "${BASH_SOURCE[0]}")/../.." \
&& pwd
)"

ANSIBLE_DIR="${ROOT_DIR}/ansible"

CONFIG="${ROOT_DIR}/ansible.cfg"

INVENTORY="${ANSIBLE_DIR}/inventory/local.ini"

PLAYBOOK="${ANSIBLE_DIR}/playbooks/setup_environment.yml"

#########################################
# LOG
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
# VALIDATION
#########################################

require_file() {

    local file="$1"

    if [[ ! -f "$file" ]]
    then

        log ERROR "Introuvable : $file"

        exit 1

    fi

}

#########################################
# EXECUTION
#########################################

run() {

    export ANSIBLE_CONFIG="${CONFIG}"

    log INFO "Exécution playbook"

    ansible-playbook \
        -i "${INVENTORY}" \
        "${PLAYBOOK}" \
        "$@"

}

#########################################
# MAIN
#########################################

main() {

    require_file "${CONFIG}"

    require_file "${INVENTORY}"

    require_file "${PLAYBOOK}"

    run "$@"

    log SUCCESS "Playbook terminé"

}

main "$@"