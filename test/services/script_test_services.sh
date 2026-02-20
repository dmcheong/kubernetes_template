#!usr/bin/env bash
# script testing services in local
# services : clusterip
# need deployement up

# check deployment is up
echo "==> Vérification du déploiement avant la mise en place des services:"
kubectl get deployment.app

# check pods in relationship with deployment
echo "==> Liste des pods dans le déploiement spécifique:"
kubectl get pods -o wide

##
# create cluster service clusterip

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set cluster service
echo "==> Création du service clusterip:"
kubectl apply -f "$SCRIPT_DIR/../template/nginx-clusterip-service.yml"

# get services
echo "==> Vérification de la liste des services:"
kubectl get services

# test temporary 
echo "==> Cette section est un test de connexion sur un pod temporaire:"

# create temporary pods
echo "==> Création d un pod temporaire:"
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
echo "==> Temps d attente avec latence volontaire pour le pode temporaire pour éviter des erreurs."
kubectl wait --for=condition=Ready pod/test-pod --timeout=30s

# open terminal 
echo "==> Ouverture du terminal du pod pour exécuté un test de connexion au cluster via le pod:"
kubectl exec -it test-pod -- sh -c "wget -qO- http://nginx-clusterip-service"

# delete temporary/test 
echo "==> Suppression du pod temporaire:"
kubectl delete pod test-pod

##
# expose outside cluster (NodePort)

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set service
echo "==> Application du service NodePort:"
kubectl apply -f "$SCRIPT_DIR/../template/nginx-nodeport-service.yml"

# get node ip
echo "==> Vérifier l IP du noeud:"
kubectl get nodes -o wide

# to get minikue IP
# minikube ip

# attendre que le endpoint soit montée sinon erreur de connexion
echo "==> Obtention des endpoints du service NodePort:"
until kubectl get endpoints nginx-nodeport-service -n dev \
  -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null | grep -q .; do
  echo "Waiting for service endpoints..."
  sleep 1
done

# test access app 
echo "==> Test de (from node minikube->localhost):"
minikube ssh -- curl -v http://127.0.0.1:30007

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##
# check with kube-score
echo "==> Score du fichier.yml du service NodePort:"
kube-score score "$SCRIPT_DIR/../template/nginx-nodeport-service.yml"