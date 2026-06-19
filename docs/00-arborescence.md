## Arborescence ciblée Ansible et Terraform

Cette vue est correspond au déploiment du projet via Ansible et Terraform.
Elle oblitère volontairement la partie uniquement Bash.

```
kubernetes_template/
├── ansible/                                  # Préparation de l'environnement local
│   ├── inventory/
│   │   ├── group_vars/                       # Variables d'inventaire
│   │   └── local.ini                         # Inventaire local
│   │
│   ├── playbooks/
│   │   ├── configure_docker.yml              # Configuration Docker
│   │   ├── configure_kubernetes.yml          # Configuration des outils Kubernetes
│   │   ├── install_tools.yml                 # Installation des outils nécessaires
│   │   ├── setup_environment.yml             # Préparation globale de l'environnement
│   │   └── validate_environment.yml          # Validation de l'environnement local
│   │
│   ├── roles/
│   │   ├── common/                           # Tâches communes
│   │   ├── docker/                           # Installation et configuration Docker
│   │   ├── helm/                             # Installation et validation Helm
│   │   ├── kubectl/                          # Installation et validation kubectl
│   │   ├── minikube/                         # Installation et validation Minikube
│   │   └── validation/                       # Contrôles de validation
│   │
│   └── requirements.yml
│
├── terraform/                                # Déploiement du socle Kubernetes
│   ├── environments/
│   │   └── dev/
│   │       ├── 00-platform/                  # Socle Kubernetes principal
│   │       │   ├── values/                   # Fichiers de valeurs Helm
│   │       │   ├── main.tf                   # Déclaration principale
│   │       │   ├── outputs.tf                # Sorties Terraform
│   │       │   ├── providers.tf              # Providers Terraform
│   │       │   ├── terraform.tfvars          # Variables de l'environnement dev
│   │       │   ├── variables.tf              # Variables attendues
│   │       │   └── versions.tf               # Versions Terraform/providers
│   │       │
│   │       └── 00-platform-objects/          # Objets applicatifs déployés sur le socle
│   │           ├── README.md                 # Validation Ingress locale avec Minikube
│   │           ├── main.tf
│   │           ├── outputs.tf
│   │           ├── providers.tf
│   │           ├── terraform.tfvars
│   │           ├── variables.tf
│   │           └── versions.tf
│   │
│   ├── modules/
│   │   ├── app/                              # Module applicatif générique
│   │   ├── argocd-application/               # Déclaration d'applications Argo CD
│   │   ├── argocd/                           # Installation Argo CD
│   │   ├── cert-manager/                     # Gestion des certificats
│   │   ├── ingress-controller/               # Contrôleur Ingress
│   │   ├── kong/                             # Module Kong, conservé mais non prioritaire
│   │   ├── modules_template/                 # Template de module Terraform
│   │   ├── monitoring/                       # Monitoring Prometheus/Grafana
│   │   ├── namespace/                        # Gestion des namespaces
│   │   ├── nginx-demo/                       # Exemple applicatif NGINX
│   │   ├── postgresql/                       # Base PostgreSQL via Helm
│   │   ├── secrets/                          # Secrets Kubernetes
│   │   └── storage/                          # Stockage Kubernetes
│   │
│   ├── script/
│   │   └── terraform_exec.sh                 # Script/notes d'exécution Terraform
│   │
│   └── README.md
│
├── scripts/
│   ├── ansible/                              # Scripts d'orchestration Ansible
│   ├── diagnostics/                          # Vérifications lecture seule du cluster
│   └── terraform/                            # Scripts d'orchestration Terraform
│
├── ansible.cfg
├── ansible.sh
└── terraform.sh
```