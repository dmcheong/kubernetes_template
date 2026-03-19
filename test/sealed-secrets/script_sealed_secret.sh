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

#─────────────────────────────────────────────────────────────────────────────
# État du cluster et configuration du contexte
#─────────────────────────────────────────────────────────────────────────────
echo "==> Liste des cluster actifs:"
kubectl config get-contexts

# s'assurer que les ressources seront créées dans dev
echo "==> Définir le namespace -> dev comme actif par défaut:"
kubectl config set-context --current --namespace=dev

#─────────────────────────────────────────────────────────────────────────────
# Vérification du controller SealedSecrets
# Le controller tourne dans kube-system et surveille les ressources SealedSecret
# Il possède la clé privée permettant de déchiffrer les SealedSecrets
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérifier que le controller est démarrer:"
kubectl get pods -n kube-system | grep sealed-secrets

# chemin absolu pour les templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Application du Secret en clair (valeurs base64 — dev uniquement)
# my-secrets.yaml contient username=admin et password=SuperSecret123 en base64
# IMPORTANT : ce fichier ne doit jamais être poussé dans un dépôt public
#─────────────────────────────────────────────────────────────────────────────
echo "==> Application du secret:"
kubectl apply -f "$SCRIPT_DIR/../template/secret/my-secrets.yaml"

# vérification du contenu (les données sont en base64 dans l'objet Secret)
echo "==> Vérification du contenu:"
kubectl get secret monsecret -o yaml -n dev
# conseil : ajouter my-secrets.yaml dans .gitignore

#─────────────────────────────────────────────────────────────────────────────
# Export de la clé publique du controller
# La clé publique est utilisée par kubeseal pour chiffrer le Secret
# Elle peut être partagée librement (seul le controller a la clé privée)
#─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Export de la clé publique du contrôleur SealedSecrets:"
kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system > sealed-secrets.pem

#─────────────────────────────────────────────────────────────────────────────
# Génération du SealedSecret
# kubeseal chiffre my-secrets.yaml avec la clé publique du controller
# Le résultat monsealedsecret.yaml peut être committé en toute sécurité
# Le controller le déchiffre automatiquement en Secret Kubernetes standard
#─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Généreration un SealedSecret à partir du Secret existant:"
kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system \
  --format=yaml \
  < "$SCRIPT_DIR/../template/secret/my-secrets.yaml" \
  > "$SCRIPT_DIR/../template/secret/monsealedsecret.yaml"

##
#─────────────────────────────────────────────────────────────────────────────
# Déploiement et vérification du SealedSecret
#─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Utilisation du secret:"
kubectl apply -f "$SCRIPT_DIR/../template/secret/monsealedsecret.yaml"

# le controller crée automatiquement un Secret standard correspondant
echo "==> Vérifier que le sealedsecret a été créer:"
kubectl get sealedsecrets -n dev

# vérifier que le Secret a bien été déchiffré et créé par le controller
echo "==> Vérifier que Kubernetes a généré un Secret standard:"
kubectl get secret monsecret -o jsonpath="{.data.password}" | base64 --decode
echo
