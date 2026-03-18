#!usr/bin/env bash
# purge dev environnement for automatisation test by deletion namespace dev

# deleting namespace will delete pods inside and more
kubectl delete namespace dev monitoring

# or
# kubectl delete namespace --all

# prévoire la liste des outils à supprimer pour essayer le script d installation
# faire attention à bien être à la racine c'est à dire ./user/ ou ./$USER/
# minikube delete --all --purge
# rm -rf ~/.asdf
