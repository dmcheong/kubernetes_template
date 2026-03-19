# Ordre d'application des fichiers YAML pour le monitoring

Lors d'une installation manuelle, appliquer dans cet ordre :

1. `deployment.yaml`       — Deployment de l'application à monitorer
2. `service.yaml`          — Service exposant les métriques
3. `servicemonitor.yaml`   — ServiceMonitor pour la découverte Prometheus
4. `adapter-values.yaml`   — Helm values Prometheus Adapter (métriques custom)
5. `hpa.yaml`              — HorizontalPodAutoscaler (autoscaling)

> Les fichiers se trouvent dans `test/template/monitoring/` et `test/template/alerting/rules/`.
