Prise en main grafana sur les metrics récolté par prometheus

moyen d'ouvrir les interfaces de Prometheus et Grafana
dans un navigateur, entrez les commandes suivantes:
minikube service list
ou
kubectl get svc -n namespace

minikube service service_name -n namespace_name
ou
kubectl port-forward svc/service service_name 3000:80 _n namespace

http://localhost:3000

# Créer un dashboard vide
étape 1
Dashboard->New->New Dashboard

étape 2
Start your new dashboard by adding a visualization

étape 3
Save
Dashboard name:
Folder
Save

#