# Monitoring — Prometheus · Grafana · OpenTelemetry · Alerting · Autoscaling

Stack de monitoring complète pour l'environnement Kubernetes de développement.

## Architecture

```
Applications (annotations prometheus.io/scrape)
        ↓
OpenTelemetry Collector  ←  Traces/Métriques OTLP
        ↓
Prometheus Server  ←  Scrape /metrics
        ↓
Grafana Dashboards
        ↓
AlertManager  →  Webhook / Email
```

## Composants

| Composant | Helm Chart | Namespace | Port |
|---|---|---|---|
| Prometheus Server | prometheus-community/kube-prometheus-stack | monitoring | 9090 |
| Grafana | intégré au chart kube-prometheus-stack | monitoring | 3000 |
| AlertManager | intégré au chart kube-prometheus-stack | monitoring | 9093 |
| OpenTelemetry Collector | open-telemetry/opentelemetry-collector | monitoring | 4317/4318/8889 |
| Prometheus Adapter | prometheus-community/prometheus-adapter | monitoring | — |

## Lancement rapide

```bash
# Installer Prometheus + Grafana
bash scripts/bin/install_prometheus.sh

# Installer OpenTelemetry Collector
bash scripts/bin/install_opentelemetry.sh
```

## Accès aux interfaces

```bash
# Prometheus
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring
# http://localhost:9090

# Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
# http://localhost:3000  (admin / voir secret grafana)

# AlertManager
kubectl port-forward svc/prometheus-alertmanager 9093:9093 -n monitoring
# http://localhost:9093

# Minikube (alternative)
minikube service list
minikube service <service_name> -n monitoring
```

## Mot de passe Grafana

```bash
kubectl -n monitoring get secret kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d && echo
```

## Créer un dashboard Grafana

1. Dashboard → New → New Dashboard
2. Add visualization → choisir Prometheus comme datasource
3. Saisir une requête PromQL (ex: `up`, `rate(http_requests_total[5m])`)
4. Save → nommer le dashboard

## Dossiers

| Dossier | Contenu |
|---|---|
| `alerting/` | Scripts de test AlertManager et règles d'alerte |
| `autoscaling/` | Prometheus Adapter + HorizontalPodAutoscaler |
| `tools/` | Scripts de test manuels Prometheus / Grafana / OpenTelemetry |
| `reminder.md` | Ordre des fichiers YAML à appliquer |

## Fichiers de configuration (templates)

| Fichier | Description |
|---|---|
| `template/monitoring/prometheus-minimal.yml` | Règles d'alerte Prometheus minimales |
| `template/monitoring/prometheus-values.yml` | Configuration Prometheus Adapter (métriques custom) |
| `template/monitoring/example-collector-values-opentelemetry.yml` | Configuration complète OTel Collector |
| `template/monitoring/example-opentelemetry-values.yml` | Values Helm OTel Demo (composants activés) |
| `template/monitoring/service-monitor.yml` | ServiceMonitor pour nginx dans namespace dev |
| `template/alerting/rules/alert-manager.yml` | Helm values AlertManager (webhook) |
| `template/alerting/rules/application.yml` | Règles d'alerte application (latence, erreurs, trafic) |
| `template/alerting/rules/infrastructure.yml` | Règles d'alerte infra (CPU, mémoire, disque, targets) |
| `template/alerting/rules/hpa.yml` | HorizontalPodAutoscaler basé sur métriques custom |
| `template/alerting/rules/adapter-values.yml` | Values Prometheus Adapter |
