#!usr/bin/env bash
# script testing sealedsecret in local
# description: set a secret first and after crypte it
# do not push secret.yaml in repository or use vault for production

# get abolute path
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get active 
echo "==> Liste des cluster actifs:"
kubectl config get-contexts

# set default dev env
echo "==> Définir le namespace -> dev comme actif par défaut:"
kubectl config set-context --current --namespace=dev

# check if controller is up
echo "==> Vérifier que le controller est démarrer:"
kubectl get pods -n kube-system | grep sealed-secrets

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set sealed-secret
echo "==> Application du secret:"
kubectl apply -f "$SCRIPT_DIR/../template/secret/my-secrets.yaml"

# check content
echo "==> Vérification du contenu:"
kubectl get secret monsecret -o yaml -n dev
# set a .gitignore for secret as usual

# get desciption
# kubectl describe secret monsecret

# test kubeseal version
echo "==> la version de kubeseal est:"
cat ./../../.tool-versions

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# export public key in controller sealedsecrets
echo "==> Export de la clé publique du contrôleur SealedSecrets:"
kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=kube-system > sealed-secrets.pem
# kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=kube-system > sealed-secrets.pem

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# generate seleadsecret from existing secret
echo "==> Généreration un SealedSecret à partir du Secret existant:"
kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format=yaml < "$SCRIPT_DIR/../template/secret/my-secrets.yaml" > "$SCRIPT_DIR/../template/secret/monsealedsecret.yaml"


##

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# use and deployment seleadsecret
echo "==> Utilisation du secret:"
kubectl apply -f "$SCRIPT_DIR/../template/secret/monsealedsecret.yaml"

# check sealedsecret
echo "==> Vérifier que le sealedsecret a été créer:"
kubectl get sealedsecrets -n dev

# check if keberenets create a standard secret
echo "==> Vérifier que Kubernetes a généré un Secret standard:"
kubectl get secret monsecret -o jsonpath="{.data.password}" | base64 --decode
echo
