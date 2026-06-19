# Vision du projet `kubernetes_template`

## Objectif

`kubernetes_template` est un projet personnel destiné à construire un template DevOps/Kubernetes local, reproductible et progressivement industrialisable.

L’objectif n’est pas seulement de lancer un cluster Kubernetes local, mais de mettre en place une base propre permettant de comprendre, tester et stabiliser une architecture proche des pratiques DevOps utilisées en entreprise.

## Orientation générale

Le projet repose sur une séparation claire des responsabilités :

- **Bash** orchestre les étapes.
- **Ansible** prépare la machine locale.
- **Terraform** déploie le socle Kubernetes.
- **diagnostics** vérifie l’état du cluster sans modifier les ressources.

Cette séparation permet d’éviter que les scripts Bash deviennent responsables de tout. Bash reste un point d’entrée pratique, mais la logique technique est déplacée vers les outils adaptés.

## Ambition du projet

À terme, le projet doit permettre de :

- préparer une machine de travail avec les bons outils ;
- déployer un socle Kubernetes local stable ;
- organiser les ressources par environnement ;
- tester des composants applicatifs simples ;
- ajouter progressivement des outils DevOps comme le monitoring, l’ingress, GitOps ou la CI/CD ;
- conserver une documentation claire de l’évolution du projet.

## Principe important

Le projet doit rester progressif. L’objectif actuel est la stabilisation de la base avant d’ajouter de nouvelles couches.

Il faut donc éviter de refaire inutilement ce qui fonctionne déjà. Les évolutions doivent enrichir l’existant sans casser les logiques validées.
