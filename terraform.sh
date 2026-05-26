#!/usr/bin/env bash

set -euo pipefail

#########################################
# VARIABLES
#########################################

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${ROOT_DIR}/scripts/bin"

TF_SCRIPT_DIR="${ROOT_DIR}/scripts/terraform"

TF_DIR="${ROOT_DIR}/terraform"

INSTALL_SCRIPT="${BIN_DIR}/install_terraform.sh"

CHECK_SCRIPT="${TF_SCRIPT_DIR}/check_terraform_ready.sh"

RUN_SCRIPT="${TF_SCRIPT_DIR}/run_terraform.sh"

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

check_project_structure() {

    local required=(

        "${INSTALL_SCRIPT}"

        "${CHECK_SCRIPT}"

        "${RUN_SCRIPT}"

        "${TF_DIR}"

    )

    for item in "${required[@]}"
    do

        if [[ ! -e "$item" ]]
        then

            log ERROR "Introuvable : $item"

            exit 1

        fi

    done

}

#########################################
# PREPARE
#########################################

prepare_terraform() {

    log INFO "Installation Terraform"

    bash "${INSTALL_SCRIPT}"

    log INFO "Validation Terraform"

    bash "${CHECK_SCRIPT}"

}

#########################################
# EXECUTION
#########################################

execute() {

    log INFO "Exécution Terraform"

    bash "${RUN_SCRIPT}" "$@"

}

#########################################
# MAIN
#########################################

main() {

    log INFO "Initialisation Terraform"

    check_project_structure

    prepare_terraform

    execute "$@"

    log SUCCESS "Terraform terminé"

}

main "$@"