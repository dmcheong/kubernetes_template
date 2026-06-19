# Modes d’exécution

## Objectif

Le projet peut être exécuté de plusieurs manières selon le besoin : préparation de la machine, déploiement Terraform, diagnostic ou test local.

L’objectif est de garder des modes simples, lisibles et séparés.

## 0. Mode orchestration globale

Le mode global passe par Bash. Cette orchestration exécute et met en place l'ensemble de l'environnement via des scripts Bash uniquement.

```bash
bash index.sh
```

Ce mode est uniquement à titre démonstratif sans les outils spécifiques que sont Ansible et Terraform.

## 1. Mode Ansible

- Prérequis: lancer docker ET Minikube. Vérifiez avec les commandes comme ``docker ps`` ou ``docker info`` et ``minikube start``

Le mode Ansible prépare ou vérifie la machine locale. Le script ``ansible.sh`` orchestre tous les scripts concernants l'installation d'Ansible et l'exécution des playbooks.

Exemple (rapide mode lab) :

```bash
bash ansible.sh
```

Ou vous pouvez exécuter les scripts pour voir les retours d'exécution dans le terminal. Pensez à vous donner les droits ``chmod +x fichier.sh``

```bash
./scripts/ansible/check_ansible_ready.sh
```

Puis directement depuis le dossier Ansible si nécessaire :

```bash
cd ansible
ansible all -m ping
ansible-playbook playbooks/<playbook>.yml --syntax-check
```

Ansible doit être utilisé avant Terraform lorsque la machine n’est pas encore prête.

## 2. Mode Terraform

Le mode Terraform déploie ou vérifie le socle Kubernetes.

Exemple pour l’environnement de développement :

```bash
cd terraform/environments/dev/00-platform
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Pour les objets dépendants du socle :

```bash
cd terraform/environments/dev/00-platform-objects
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

- note: Ne pas exécuter ces commandes pour les modules terraform.

## 3. Mode diagnostic

Les diagnostics servent à vérifier l’état du cluster.

```bash
cd scripts/diagnostics
./diagnostic_for_cluster.sh
./watch_events.sh
./diagnostic_test_cluster.sh all
./diagnostic_in_cluster.sh
```

Ces scripts ne doivent pas remplacer Terraform ou Ansible.

## 4. Test Ingress local avec Minikube

Dans l’environnement local actuel, Minikube utilise Docker. L’accès direct via `minikube ip` ou NodePort peut ne pas être fiable selon la configuration réseau.

La méthode validée est le port-forward du contrôleur Ingress.

Terminal 1 :

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

Terminal 2 :

```bash
curl -H "Host: nginx-demo.local" http://127.0.0.1:8080
```

Résultat attendu :

```text
Welcome to nginx!
```

## Ordre recommandé

```text
1. Lancer docker et Minikube
2. Préparer la machine avec Ansible
3. Déployer le socle avec Terraform 00-platform
4. Vérifier Kubernetes avec diagnostics
5. Déployer les objets 00-platform-objects
6. Tester l’accès local
```
