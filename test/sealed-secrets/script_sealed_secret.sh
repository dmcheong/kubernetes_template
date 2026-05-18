#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_sealed_secret.sh
# Description  : Teste le workflow complet SealedSecrets :
#                1) appliquer un Secret en clair (dev uniquement)
#                2) chiffrer avec kubeseal → SealedSecret commitable
#                3) vérifier que le controller déchiffre en Secret standard
# Prérequis    : controller sealed-secrets-controller dans kube-system,
#                kubeseal installé, namespace dev créé
# Sécurité     : ne jamais committer my-secrets.yaml en production — utiliser
#                un vault (HashiCorp Vault) ou injecter via CI/CD
#===============================================================================
set_message "info" "0" "Gestion des secrets via SealedSecret."
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# État du cluster et configuration du contexte
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Liste des cluster actifs:"
kubectl config get-contexts
error_CTRL "${?}" "Operation completed"

# s'assurer que les ressources seront créées dans dev
set_message "info" "0" "Définir le namespace -> dev comme actif par défaut:"
kubectl config set-context --current --namespace=dev
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Vérification du controller SealedSecrets
# Le controller tourne dans kube-system et surveille les ressources SealedSecret
# Il possède la clé privée permettant de déchiffrer les SealedSecrets
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérifier que le controller est démarrer dans le namespace kube-system:"
kubectl get pods -n kube-system | grep sealed-secrets
error_CTRL "${?}" "Operation completed"

# chemin absolu pour les templates
SEAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Application du Secret en clair (valeurs base64 — dev uniquement)
# my-secrets.yaml contient username=admin et password=SuperSecret123 en base64
# IMPORTANT : ce fichier ne doit jamais être poussé dans un dépôt public
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Application du secret dans le namespace dev:"
kubectl apply -f "$SEAL_DIR/../template/secret/my-secrets.yaml"
error_CTRL "${?}" "Operation completed"

# vérification du contenu (les données sont en base64 dans l'objet Secret)
set_message "check" "0" "Vérification du contenu du secret depuis le namespace dev:"
kubectl get secret monsecret -o yaml -n dev
error_CTRL "${?}" "Operation completed"
# conseil : ajouter my-secrets.yaml dans .gitignore

#─────────────────────────────────────────────────────────────────────────────
# Export de la clé publique du controller
# La clé publique est utilisée par kubeseal pour chiffrer le Secret
# Elle peut être partagée librement (seul le controller a la clé privée)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Export de la clé publique du contrôleur SealedSecrets:"
if [-f "./sealed-secrets.pem"]; then
    set_message "info" "0" "La clé a déjà été exportée, on continue"
else
    kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=kube-system > sealed-secrets.pem
    error_CTRL "${?}" "Operation completed"
fi

#─────────────────────────────────────────────────────────────────────────────
# Génération du SealedSecret
# kubeseal chiffre my-secrets.yaml avec la clé publique du controller
# Le résultat monsealedsecret.yaml peut être committé en toute sécurité
# Le controller le déchiffre automatiquement en Secret Kubernetes standard
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Génération d un SealedSecret à partir du Secret existant:"
if [-f "$SEAL_DIR/../template/secret/monsealedsecret.yaml"]; then
    set_message "info" "0" "La clé a déjà été générée, on continue"
else
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format=yaml < "$SEAL_DIR/../template/secret/my-secrets.yaml" > "$SEAL_DIR/../template/secret/monsealedsecret.yaml"
    error_CTRL "${?}" "Operation completed"
fi

##
#─────────────────────────────────────────────────────────────────────────────
# Déploiement et vérification du SealedSecret
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Utilisation du secret:"
kubectl apply -f "$SEAL_DIR/../template/secret/monsealedsecret.yaml"
error_CTRL "${?}" "Operation completed"

# le controller crée automatiquement un Secret standard correspondant
set_message "check" "0" "Vérifier que le sealedsecret a été créer:"
kubectl get sealedsecrets -n dev
error_CTRL "${?}" "Operation completed"

# vérifier que le Secret a bien été déchiffré et créé par le controller
set_message "warn" "0" "Ne pas afficher les spécificités des secret dans code en production. Ceci est pour l'entrainement."
set_message "check" "0" "Vérifier que Kubernetes a généré un Secret standard:"
kubectl get secret monsecret -o jsonpath="{.data.password}" | base64 --decode
error_CTRL "${?}" "Operation completed"

printf "%b\n"
printf "%b\n"
