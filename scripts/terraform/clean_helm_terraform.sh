#!/bin/sh

# clean helm for terraform script
helm uninstall postgresql -n database
helm uninstall ingress-nginx -n ingress-nginx
helm uninstall monitoring -n monitoring

# terraform destroy -target=module.ingress_controller
# kubectl delete namespace monitoring
# terraform state rm module.monitoring.helm_release.this
# terraform state rm module.grafana_secret.kubernetes_secret_v1.this
# terraform apply -target=module.argocd
# terraform apply

# terraform -chdir=./terraform apply -target=module.argocd
