# Kong Gateway – API Management

## 🎯 Rôle

Kong est utilisé comme API Gateway pour :

* router les APIs métier
* appliquer des politiques (rate limiting, auth…)
* exporter des métriques
* envoyer des traces OpenTelemetry

---

## ⚙️ Configuration

Fichiers :

* `kong-values.yml`
* `kong-observability.yml`

---

## 🔁 Flux

Traefik → Kong → Services backend

---

## 📊 Observabilité

* plugin Prometheus
* plugin OpenTelemetry
* métriques scrapées par Prometheus
