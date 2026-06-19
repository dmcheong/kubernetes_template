# Architecture du projet

## Vue d’ensemble

`kubernetes_template` est organisé autour de quatre blocs principaux :

```text
kubernetes_template/
├── ansible/        # Préparation de la machine locale
├── scripts/        # Orchestration Bash et scripts utilitaires
├── terraform/      # Déploiement du socle Kubernetes
└── test/           # A ignorer pour la partie Ansible & Terraform
```

## Rôle de Bash

Bash sert d’orchestrateur.

Il peut lancer :

- les scripts Ansible ;
- les commandes Terraform ;
- les diagnostics ;
- les vérifications globales.

Bash ne doit pas devenir le responsable principal de la création des ressources Kubernetes. Cette responsabilité appartient à Terraform.

## Rôle d’Ansible

Ansible prépare la machine locale.

Il est utilisé pour gérer l’installation ou la vérification d’outils comme :

- Docker ;
- kubectl ;
- Helm ;
- Minikube ;
- les dépendances système utiles au projet.

Ansible ne doit pas créer les ressources Kubernetes du socle applicatif. Son rôle est de préparer l’environnement d’exécution.

## Rôle de Terraform

Terraform déploie le socle Kubernetes.

Il gère notamment :

- les namespaces ;
- les charts Helm ;
- l’ingress controller ;
- PostgreSQL ;
- le monitoring ;
- les secrets nécessaires au socle ;
- les objets de démonstration simples.

La séparation retenue est :

```text
00-platform          # socle technique Kubernetes
00-platform-objects  # objets applicatifs ou démonstratifs dépendants du socle
```

## Rôle des diagnostics

Le dossier `scripts/diagnostics` contient des scripts de vérification.

Ils doivent servir à observer l’état du cluster, collecter des informations et aider au troubleshooting.

Principe important :

```text
diagnostics vérifie, mais ne corrige pas et ne déploie pas.
```

Cette règle évite qu’un script de diagnostic modifie l’état réel du cluster.

## Architecture cible simplifiée

```text
Utilisateur
   │
   ▼
index.sh / scripts Bash
   │
   ├── Ansible
   │     └── prépare la machine
   │
   ├── Terraform
   │     └── déploie Kubernetes
   │
   └── diagnostics
         └── vérifie l’état du cluster
```
