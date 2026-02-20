note:
Ingress = gère l’accès HTTP/HTTPS externe avec du routage intelligent

L’Ingress Kubernetes

Un Ingress sert à gérer :

✅ HTTP
✅ HTTPS
✅ Domaines
✅ Routing URL
✅ TLS
✅ Reverse proxy

Il permet de faire :

https://monapp.com/api  → service backend
https://monapp.com      → service frontend


Donc :

L’Ingress route vers des Services, pas vers des Pods directement.

Internet
   ↓
Ingress Controller (NGINX, Kong, Traefik…)
   ↓
Ingress Rules
   ↓
Service
   ↓
Pods

Ingress utilise des Services