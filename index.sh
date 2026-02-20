#!/usr/bin/env bash
# automation entrypoint
# the code work with include script_test_files.sh 
# deployment -> namespaces -> pods
# deployement -> services ->

# check all tools version for automation or install or update last version
# source ./scripts/installation/check_installation.sh

# start minikube service
echo "==> Démarrage de Minikube."
# minikube start
echo

# launch all script_test_file.sh for automation
# no include for 
echo "==> Exécution global des scripts de déploiement du cluster:"
source ./test/namespaces/script_test_namespaces.sh
source ./test/pods/script_test_pods.sh
source ./test/deployment/script_test_deployment.sh
soucre ./test/services/script_test_services.sh
source ./test/storageclass/script_test_storageclass.sh
source ./test/sealed-secrets/script_sealed_secret.sh
source ./test/gateway/script_kong_gateway.
source ./test/monitoring/test_prometheus.sh
source ./test/monitoring/test_grafana.sh
echo 
echo "==> Fin des scripts de déploiement."
echo

# delete 
echo "==> Suppression de l environnement de dev via le namespace -> dev:"
# source ./scripts/delete/clean_env_dev.sh
echo

# stop minikube service
echo "==> Arrêt de Minikube."
# minikube stop
echo

echo "==> Fin du script d automatisation."