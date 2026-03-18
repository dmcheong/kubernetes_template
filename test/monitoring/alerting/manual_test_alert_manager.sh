#!/usr/bin/env bash
# test setting alert manager associate with monitoring tools
# this file.sh is a training for deployment not use for automation

# update helm 
# files.yml with -f are not update with this project, this file.sh is just a template
helm upgrade prometheus prometheus-community/prometheus \
  -n observability \
  -f 02-prometheus/helm-values/prometheus-minimal.yaml \
  -f 04-alerting/helm-values/alertmanager.yaml \
  --wait

# check pods
kubectl get pods -n observability | grep alertmanager

# check services 
kubectl get services -n observability

# open browser dashboard
kubectl port-forward svc/prometheus-alertmanager 9093:9093 -n observability

## example rules
groups:
  - name: nom_du_groupe     # Groupe logique de règles
    interval: 30s           # Fréquence d'évaluation (optionnel)
    rules:
      - alert: NomAlerte    # ① Nom unique de l'alerte
        expr: up == 0       # ② Expression PromQL (condition)
        for: 2m             # ③ Durée avant firing
        labels:             # ④ Labels ajoutés à l'alerte
          severity: critical
          team: platform
        annotations:        # ⑤ Informations humaines
          summary: "Target {{ $labels.instance }} is down"
          description: "The target {{ $labels.job }}/{{ $labels.instance }} has been down for more than 2 minutes."
          runbook: "https://wiki.example.com/runbooks/target-down"
