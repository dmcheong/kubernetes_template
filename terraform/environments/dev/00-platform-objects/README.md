## Validation Ingress locale avec Minikube

Dans cet environnement, Minikube utilise le driver Docker.  
L’accès direct via `minikube ip` ou NodePort peut ne pas fonctionner selon la configuration réseau locale.

La méthode validée pour tester l’Ingress est le port-forward du service `ingress-nginx-controller`.

Terminal 1 :

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

Terminal 2 :

```bash
curl -H "Host: nginx-demo.local" http://127.0.0.1:8080
```

Résultat attendu:

```<HTML>
Welcome to nginx!
```