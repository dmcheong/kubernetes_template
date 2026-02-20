note:
Service = expose un Pod à l’intérieur (ou parfois à l’extérieur) du cluster

Le Service Kubernetes

Un Service est un objet qui permet de donner une adresse stable à des Pods.

Pourquoi ?

Parce que les Pods changent d’IP tout le temps.

Le Service sert donc de point d’accès fixe.

Il peut être :

Types principaux

ClusterIP (par défaut)

Accessible uniquement dans le cluster

Communication interne microservices

NodePort

Ouvre un port sur chaque nœud

Accessible depuis l’extérieur via IP du node

LoadBalancer

Demande un load balancer cloud (Azure, AWS, etc.)

Exposition externe propre

👉 Exemple simple :

Frontend → Service Backend → Pods Backend

Le frontend ne parle jamais directement aux Pods.

Internet
   ↓
Ingress Controller (NGINX, Kong, Traefik…)
   ↓
Ingress Rules
   ↓
Service
   ↓
Pods

Services fonctionne sans Ingress