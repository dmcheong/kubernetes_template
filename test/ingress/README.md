# Ingress — Reverse Proxy Traefik

Un Ingress Kubernetes gère l'accès HTTP/HTTPS externe avec routage intelligent.

## Rôle d'un Ingress

```
Internet
   ↓
Ingress Controller (Traefik ici)
   ↓
Ingress Rules / IngressRoute
   ↓
Service
   ↓
Pods
```

L'Ingress controller écoute sur les ports 80/443 et route les requêtes vers les Services selon des règles (hostname, chemin, …).

## Capacités Traefik

| Fonctionnalité | Support |
|---|---|
| HTTP / HTTPS | ✅ |
| Domaines multiples | ✅ |
| Routing URL | ✅ |
| TLS automatique | ✅ (Let's Encrypt) |
| Tableau de bord | ✅ (port 9000) |
| Métriques Prometheus | ✅ |
| Traces OpenTelemetry | ✅ |
| Middleware (rate-limit, auth…) | ✅ |

## Fichiers

| Fichier | Rôle |
|---|---|
| `reverse_proxy/install_traefik.sh` | Installation Traefik via Helm + namespace `traefik` |
| `reverse_proxy/script_test_traefik_deploy.sh` | Déploiement de l'application de test `whoami` |
| `reverse_proxy/traefik.yml` | Values Helm Traefik (ports, métriques, OTLP, ServiceMonitor) |
| `reverse_proxy/whoami.yml` | Deployment + Service de l'app de test `whoami` dans `traefik` |
| `reverse_proxy/whoami-ingressroute.yml` | IngressRoute CRD Traefik vers `whoami.local` |

## Lancement

```bash
# Installer Traefik
bash test/ingress/reverse_proxy/install_traefik.sh

# Déployer l'application de test whoami
bash test/ingress/reverse_proxy/script_test_traefik_deploy.sh
```

## Test de bout en bout

```bash
# 1. Récupérer l'URL Minikube de Traefik
minikube service traefik -n traefik --url

# 2. Ajouter whoami.local dans /etc/hosts (pointer vers l'IP Minikube)
echo "$(minikube ip) whoami.local" | sudo tee -a /etc/hosts

# 3. Tester
curl -H "Host: whoami.local" http://<IP_MINIKUBE>

# 4. Tableau de bord Traefik
kubectl -n traefik port-forward svc/traefik 9000:9000
# puis ouvrir http://localhost:9000/dashboard/
```

## Intégration Monitoring

`traefik.yml` configure automatiquement :
- Export des métriques vers Prometheus (`entryPoint: metrics`, port 9100)
- Export des traces OTLP vers OpenTelemetry Collector (`monitoring.svc.cluster.local:4318`)
- `ServiceMonitor` pour la découverte automatique par kube-prometheus-stack
