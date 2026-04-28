# OpenTelemetry Collector

## 🎯 Rôle

Le Collector centralise la télémétrie :

* reçoit les traces OTLP
* reçoit éventuellement métriques OTLP
* redistribue vers backends (Grafana Tempo, etc.)

---

## ⚙️ Configuration

Fichier : `otel-values.yml`

* receivers : OTLP
* processors : batch, memory limiter
* exporters : debug (lab)

---

## 🔁 Flux

Traefik / Kong → OTel Collector → backend
