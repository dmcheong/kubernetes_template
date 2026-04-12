# kubernetes_template

Environnement d'apprentissage Kubernetes automatisé avec Minikube.

> Source pédagogique : <https://github.com/stephrobert/containers-training>
> Blog : <https://blog.stephane-robert.info>

---

## Prérequis

| Outil | Version min | Notes |
|---|---|---|
| Docker Engine | 24.0.0 | doit être installé et démarré avant tout |
| Bash | 5.x | scripts POSIX |

---

## Structure du projet

```
kubernetes_template/
├── index.sh                       # Point d'entrée principal (orchestrateur global)
├── scripts/
│   ├── bin/                       # Scripts d'installation des outils
│   │   ├── check_installation_basique_tools.sh    # Orchestre les outils de base
│   │   ├── check_installation_monitoring_tools.sh # Orchestre les outils de monitoring
│   │   ├── install_asdf.sh        # Gestionnaire de versions d'outils (asdf)
│   │   ├── install_docker_engine.sh # Vérification Docker Engine
│   │   ├── install_helm.sh        # Gestionnaire de packages Kubernetes (Helm)
│   │   ├── install_kubectl.sh     # CLI Kubernetes (kubectl)
│   │   ├── install_kubescore.sh   # Analyseur de manifestes YAML (kube-score)
│   │   ├── install_kubeseal.sh    # Chiffrement des secrets + serveur NFS
│   │   ├── install_minikube.sh    # Cluster Kubernetes local (Minikube)
│   │   ├── install_opentelemetry.sh # Collecteur de télémétrie (OpenTelemetry)
│   │   ├── install_prometheus.sh  # Monitoring + dashboards (Prometheus + Grafana)
│   │   ├── install_sealedsecret.sh  # Controller SealedSecrets
│   │   └── clean_env_dev.sh       # Nettoyage de l'environnement de développement
│   ├── config/
│   │   └── global.env             # Versions et variables partagées par tous les scripts
│   └── lib/
│       └── core.sh                # Fonctions communes (set_message, error_CTRL, …)
└── test/                          # Scénarios de test et templates Kubernetes
    ├── deployment/                # Tests de déploiements
    ├── gateway/                   # Kong API Gateway
    ├── ingress/reverse_proxy/     # Traefik ingress controller
    ├── monitoring/                # Prometheus, Grafana, OpenTelemetry, alerting, autoscaling
    ├── namespaces/                # Création et gestion des namespaces
    ├── pods/                      # Tests de pods
    ├── replicasets/               # Tests de ReplicaSets
    ├── sealed-secrets/            # Tests SealedSecrets
    ├── services/                  # Tests de services (ClusterIP, NodePort)
    ├── storageclass/              # Tests de volumes persistants (NFS, PVC)
    ├── template/                  # Manifestes YAML réutilisables
    └── vault/                     # HashiCorp Vault (skeleton)
```

---

## Lancement rapide

```bash
# 1. Démarrer Minikube
minikube start

# 2. Lancer l'orchestrateur complet
bash index.sh
```

L'orchestrateur exécute dans l'ordre :

1. Vérification/installation des outils de base (Docker, Helm, kubectl, Minikube, asdf, kube-score, kubeseal)
2. Déploiement du cluster de test : namespaces → pods → deployments → services → storage → secrets → gateway
3. Vérification/installation des outils de monitoring (Prometheus + Grafana, OpenTelemetry)
4. Déploiement des services de monitoring et du reverse proxy Traefik

---

## Configuration

Toutes les versions et variables sont centralisées dans [scripts/config/global.env](scripts/config/global.env).

```bash
# Exemple — changer la version cible de kubectl
KUBECTL_VERSION="1.35.0"
```

---

## Namespaces utilisés

| Namespace | Usage |
|---|---|
| `dev` | Ressources de test (pods, déploiements, services) |
| `monitoring` | Prometheus, Grafana, OpenTelemetry Collector |
| `traefik` | Ingress controller Traefik |
| `kong` | API Gateway Kong |
| `kube-system` | Controller SealedSecrets |

---

## Nettoyage

```bash
# Supprimer les namespaces dev et monitoring
bash scripts/bin/clean_env_dev.sh

# Supprimer complètement Minikube et asdf
minikube delete --all --purge
rm -rf ~/.asdf
```

---

## Notes de sécurité

- `kong-gateway-secret.yaml` contient un mot de passe fictif (`motdepassefort`) — **ne pas pousser en production sans chiffrement SealedSecrets**.
- `my-secrets.yaml` contient des valeurs base64 d'exemple — à remplacer ou chiffrer avec `kubeseal`.
- Le partage NFS est configuré avec `no_root_squash` et permissions `777` — **environnement de développement uniquement**.


## Intégration partiel du Framework CAST

- CAST est un framework BASH de ARNAUD CRAMPET
- Intégration de la partie sur l'affichage des logs dans le terminal

```
lib
└── core.sh`
```