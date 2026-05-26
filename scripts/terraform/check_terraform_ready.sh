#!/usr/bin/env bash

set -euo pipefail

#########################################
# PATHS
#########################################

ROOT_DIR="$(
cd "$(dirname "${BASH_SOURCE[0]}")/../.." \
&& pwd
)"

TF_DIR="${ROOT_DIR}/terraform"

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
# VALIDATION
#########################################

require_binary() {

    if ! command -v "$1" >/dev/null
    then

        log ERROR "$1 absent"

        exit 1

    fi

}

require_file() {

    if [[ ! -f "$1" ]]
    then

        log ERROR "Fichier absent : $1"

        exit 1

    fi

}

#########################################
# CHECK
#########################################

check_terraform() {

    require_binary terraform

    terraform version

}

check_structure() {

    require_file "${TF_DIR}/versions.tf"

    require_file "${TF_DIR}/providers.tf"

    require_file "${TF_DIR}/main.tf"

}

validate() {

    cd "${TF_DIR}"

    terraform fmt \
        -check \
        -recursive

}

#########################################
# MAIN
#########################################

main() {

    log INFO "Validation Terraform"

    check_terraform

    check_structure

    validate

    log SUCCESS "Terraform prêt"

}

main "$@"