# Gateway — Kong API Gateway

Kong Gateway est un ingress controller avancé qui fait office de point d'entrée HTTP/HTTPS pour le cluster.

## Architecture

```
Internet → Kong Gateway → Service → Pods
```

Kong joue le même rôle qu'un Ingress controller classique (Traefik, NGINX), mais offre en plus :
- gestion des plugins (authentification, limitation de débit, logging…)
- tableau de bord Kong Manager (port 8002)
- API Admin REST (port 8001)

## Prérequis

- `kubeseal` installé (`install_kubeseal.sh`)
- Helm repos `bitnami` et `kong` ajoutés
- Namespace `kong` créé

## Fichiers

| Fichier | Rôle |
|---|---|
| `script_kong_gateway.sh` | Script d'installation automatisé |
| `kong-gateway-secret.yaml` | Secret PostgreSQL en clair (**dev uniquement**) |
| `kong-gateway-sealed-secret.yaml` | Secret chiffré généré par kubeseal (gitignore-safe) |
| `kong-values.yml` | Values Helm pour Kong (connexion PostgreSQL) |
| `postgres-values.yml` | Values Helm pour PostgreSQL Bitnami |

## Lancement

```bash
bash test/gateway/script_kong_gateway.sh
```

## Vérification

```bash
# Toutes les ressources du namespace kong
kubectl get all -n dev

# Mot de passe PostgreSQL (sans TLS)
kubectl get secret kong-ingress-controller-postgresql \
  -o jsonpath="{.data.postgresql-password}" | base64 -d

# Connexion directe à PostgreSQL
kubectl exec -it kong-postgresql-0 -- psql -U kong -d kong -c "SELECT now();"
```

## Sécurité

> `kong-gateway-secret.yaml` contient le mot de passe `motdepassefort` en clair.
> Toujours chiffrer avec `kubeseal` avant de committer : la version chiffrée est `kong-gateway-sealed-secret.yaml`.
