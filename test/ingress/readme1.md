# Traefik – Ingress Controller

## 🎯 Rôle

Traefik est le point d’entrée HTTP/HTTPS du cluster.

Il :

* reçoit le trafic externe
* route vers les services internes
* expose des métriques Prometheus
* envoie des traces vers OpenTelemetry

---

## ⚙️ Configuration

Fichier : `traefik.yml`

Points clés :

* NodePort (lab Minikube)
* métriques Prometheus activées
* tracing OTLP activé
* CRD Traefik activées

---

## 🔁 Flux

Client → Traefik → Kong ou services directs

---

## 📊 Observabilité

* endpoint `/metrics`
* ServiceMonitor actif
* traces envoyées vers OpenTelemetry
