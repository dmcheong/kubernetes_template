#!/usr/bin/env bash

set -euo pipefail

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
# HELPERS
#########################################

command_exists() {

    command -v "$1" >/dev/null 2>&1

}

#########################################
# INSTALL
#########################################

install_terraform_debian() {

    sudo apt update

    sudo apt install \
        -y \
        gpg \
        wget \
        curl

    wget -qO- \
        https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee \
        /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        >/dev/null

    echo \
        "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com \
        $(lsb_release -cs) main" \
    | sudo tee \
        /etc/apt/sources.list.d/hashicorp.list

    sudo apt update

    sudo apt install \
        -y \
        terraform

}

#########################################
# MAIN
#########################################

main() {

    if command_exists terraform
    then

        log SUCCESS "Terraform déjà installé"

        terraform version

        exit 0

    fi

    log INFO "Installation Terraform"

    if command_exists apt
    then

        install_terraform_debian

    else

        log ERROR "Distribution non supportée"

        exit 1

    fi

    log SUCCESS "Terraform installé"

}

main "$@"