#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(
cd "$(dirname "${BASH_SOURCE[0]}")/../.." \
&& pwd
)"

TF_DIR="${ROOT_DIR}/terraform"

log() {
    local level="$1"
    shift

    case "$level" in
        INFO) echo "[INFO] $*" ;;
        SUCCESS) echo "[SUCCESS] $*" ;;
        ERROR) echo "[ERROR] $*" ;;
    esac
}

main() {
    cd "${TF_DIR}"

    log INFO "Formatage Terraform"
    terraform fmt -recursive

    log INFO "Initialisation Terraform"
    terraform init

    log INFO "Validation Terraform"
    terraform validate

    log INFO "Plan Terraform"
    terraform plan -out=tfplan

    if [[ "${1:-}" == "--apply" ]]; then
        log INFO "Application Terraform"
        terraform apply -auto-approve tfplan
    else
        log INFO "Apply non lancé. Utilise --apply pour appliquer."
    fi

    log SUCCESS "Exécution Terraform terminée"
}

main "$@"