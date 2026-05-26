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
# DETECTION
#########################################

command_exists() {

    command -v "$1" >/dev/null 2>&1

}

#########################################
# INSTALL
#########################################

install_ansible_linux() {

    if command_exists apt; then

        log INFO "Installation via apt"

        sudo apt update

        sudo apt install \
            -y \
            software-properties-common

        sudo apt install \
            -y \
            ansible

        return

    fi

    if command_exists dnf; then

        log INFO "Installation via dnf"

        sudo dnf install \
            -y \
            ansible

        return

    fi

    if command_exists yum; then

        log INFO "Installation via yum"

        sudo yum install \
            -y \
            epel-release

        sudo yum install \
            -y \
            ansible

        return

    fi

    if command_exists pacman; then

        log INFO "Installation via pacman"

        sudo pacman \
            -S \
            --noconfirm \
            ansible

        return

    fi

    log ERROR "Distribution non supportée"

    exit 1

}

#########################################
# MAIN
#########################################

main() {

    if command_exists ansible &&
       command_exists ansible-playbook
    then

        log SUCCESS "Ansible déjà présent"

        exit 0

    fi

    log INFO "Installation Ansible"

    install_ansible_linux

    log SUCCESS "Installation terminée"

}

main "$@"