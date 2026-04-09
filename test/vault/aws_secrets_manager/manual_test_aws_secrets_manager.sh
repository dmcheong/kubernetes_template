
# source: https://aws.amazon.com/fr/blogs/france/aws-secrets-controller-comment-integrer-aws-secrets-manager-avec-kubernetes/

# 1. Tout d’abord, ajoutez le dépot de charts Helm contenant les charts du contrôleur d’admission à l’injecteur de secret;
helm repo add secret-inject https://aws-samples.github.io/aws-secret-sidecar-injector/

# 2. Les dépôts Chart sont fréquemment mis à jour. Pour s’assurer que la version locale est à jour également, vous devez exécuter régulièrement la commande de mise à jour de dépôt repo update;
helm repo update

# 3. Installez le contrôleur d’accès à Secrets Manager en utilisant son chart Helm;
helm install secret-inject secret-inject/secret-inject

# 4. Vérifiez que les objets Kubernetes correspondants sont créés.
kubectl get mutatingwebhookconfiguration
# NAME                            WEBHOOKS   AGE
# aws-secret-inject               1          21s
