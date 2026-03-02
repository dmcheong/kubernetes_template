#!/usr/bin/env bash
# automation entrypoint

# check all tools version for automation or install or update last
# source ./scripts/installation/check_installation.sh

# start minikube service
echo "==> Démarrage de Minikube."
# minikube start
echo

# launch all script_test_file.sh for automation
# no included files, here liste of scripts to understand order of automation
echo "==> Exécution global des scripts de déploiement du cluster:"
# source ./test/namespaces/script_test_namespaces.sh
# source ./test/pods/script_test_pods.sh
# source ./test/deployment/script_test_deployment.sh
# soucre ./test/services/script_test_services.sh
# source ./test/storageclass/script_test_storageclass.sh
# source ./test/sealed-secrets/script_sealed_secret.sh
# source ./test/gateway/script_kong_gateway.
echo 
echo "==> Fin des scripts de déploiement."
echo

# launch all scripts for monitoring and namespace -> monitoring
# Prometheus + Grafana
echo "==> Exécution des scripts de l environnement de monitoring:"
source ./scripts/installation/install_prometheus.sh
source ./scripts/installation/install_grafana.sh
echo "==> Mise en place des services de monitoring:"
source ./test/services/script_test_service_monitor.sh
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