# Services Kubernetes

Un Service expose un groupe de Pods via une adresse stable, indépendante du cycle de vie des Pods.

## Pourquoi un Service ?

Les Pods ont une IP éphémère : leur IP change à chaque redémarrage.
Un Service offre une adresse DNS/IP fixe et fait office de load balancer interne.

## Types de Services

| Type | Accessibilité | Usage |
|---|---|---|
| **ClusterIP** (défaut) | Interne au cluster uniquement | Communication microservices |
| **NodePort** | Externe via `<IP_Node>:<NodePort>` (30000–32767) | Tests locaux sans cloud |
| **LoadBalancer** | Externe via load balancer cloud (AWS, Azure…) | Production cloud |

## Architecture

```
Internet
   ↓
Ingress Controller (NGINX / Kong / Traefik)
   ↓
Ingress Rules
   ↓
Service  ←  stable DNS + IP
   ↓
Pods  (éphémères, IP variable)
```

> Un Service fonctionne **sans** Ingress. L'Ingress ajoute le routage HTTP/HTTPS avancé.

## Fichiers

| Fichier | Rôle |
|---|---|
| `script_test_services.sh` | Test automatisé : ClusterIP + NodePort |
| `manual_test_services.sh` | Guide de test manuel complet |
| `script_test_services_monitoring.sh` | Déploiement services de monitoring |
| `manual_test_monitor.sh` | Test manuel ServiceMonitor |

## Templates associés

| Template | Type | Description |
|---|---|---|
| `template/service/nginx-clusterip-service.yml` | ClusterIP | Expose nginx en interne (port 80) |
| `template/service/nginx-nodeport-service.yml` | NodePort | Expose nginx sur le port 30007 du node |
| `template/service/service-kubernetes.yml` | ClusterIP | Service avec port métriques 8080 |
| `template/service/service-monitor.yml` | ServiceMonitor | Scraping Prometheus de demo-api |

## Test de connectivité interne (ClusterIP)

```bash
# Créer un pod temporaire busybox
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
kubectl wait --for=condition=Ready pod/test-pod --timeout=30s

# Tester l'accès au service ClusterIP
kubectl exec -it test-pod -- sh -c "wget -qO- http://nginx-clusterip-service"

# Nettoyer
kubectl delete pod test-pod
```

## Test d'accès externe (NodePort)

```bash
# Obtenir l'IP du nœud Minikube
minikube ip
# ou
kubectl get nodes -o wide

# Tester l'accès
curl http://<IP_NODE>:30007
```
