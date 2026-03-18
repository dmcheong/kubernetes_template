#!/usr/bin/env bash
# automation entrypoint

# start minikube service
echo "==> Démarrage de Minikube."
# minikube start
echo

# check all tools version for automation: install or update lasted
source ./scripts/installation/check_installation_basique_tools.sh

# launch all script_test_file.sh for automation
# no included files, below here list of scripts to understand order of automation
echo "==> Exécution global des scripts de déploiement du cluster:"
source ./test/namespaces/script_test_namespaces.sh
source ./test/pods/script_test_pods.sh
source ./test/deployment/script_test_deployment.sh
source ./test/services/script_test_services.sh
source ./test/storageclass/script_test_storageclass.sh
source ./test/sealed-secrets/script_sealed_secret.sh
source ./test/gateway/script_kong_gateway.sh

# launch all scripts for metrics/monitoring/alert in namespace -> monitoring
# Prometheus + Grafana + OpenTelemetry
echo "==> Exécution des scripts de l environnement de monitoring:"
source ./scripts/installation/check_installation_monitoring_tools.sh
echo "==> Mise en place des services de monitoring:"
source ./test/namespaces/script_test_namespaces_monitoring.sh
source ./test/services/script_test_services_monitoring.sh

# launch all scripts for reverse proxy in namespace -> traefik
# traefik
echo "==> Mise en place du reverse proxy:"
source ./test/namespaces/script_test_namespaces_traefik.sh
source ./test/ingress/reverse_proxy/install_traefik.sh
source ./test/ingress/reverse_proxy/script_test_traefik_deploy.sh

echo 
echo "==> Fin global des scripts de déploiement."
echo

# delete 
# echo "==> Suppression de tous les environnements de test via le namespace -> dev/monitoring:"
# source ./scripts/delete/clean_env_dev.sh
# echo

# stop minikube service
# echo "==> Arrêt de Minikube."
# minikube stop
# echo

echo "==> Fin du script d automatisation."