kubernetes_template/
├── index.sh
├── ansible.sh                         # Nouveau point d’entrée Bash pour Ansible
│
├── scripts/
│   ├── bin/
│   │   ├── install_ansible.sh          # Vérifie / installe Ansible
│   │   ├── install_terraform.sh        # Prévu pour plus tard
│   │   └── check_iac_tools.sh          # Vérifie Ansible + Terraform
│   │
│   └── ansible/
│       ├── run_playbook.sh             # Lance les playbooks Ansible
│       └── check_ansible_ready.sh      # Vérifie ansible, ansible-playbook, collections
│
├── ansible/
│   ├── ansible.cfg                     # Configuration globale Ansible
│   ├── inventory/
│   │   ├── local.ini                   # Inventaire local
│   │   └── group_vars/
│   │       └── all.yml                 # Variables communes
│   │
│   ├── playbooks/
│   │   ├── setup_environment.yml       # Playbook principal environnement
│   │   ├── install_tools.yml           # Installation outils de base
│   │   ├── configure_docker.yml        # Configuration Docker
│   │   ├── configure_kubernetes.yml    # kubectl, minikube, helm
│   │   └── validate_environment.yml    # Vérifications finales
│   │
│   ├── roles/
│   │   ├── common/
│   │   │   ├── tasks/
│   │   │   ├── defaults/
│   │   │   └── handlers/
│   │   │
│   │   ├── docker/
│   │   │   ├── tasks/
│   │   │   ├── defaults/
│   │   │   └── handlers/
│   │   │
│   │   ├── kubectl/
│   │   │   ├── tasks/
│   │   │   └── defaults/
│   │   │
│   │   ├── helm/
│   │   │   ├── tasks/
│   │   │   └── defaults/
│   │   │
│   │   ├── minikube/
│   │   │   ├── tasks/
│   │   │   └── defaults/
│   │   │
│   │   └── validation/
│   │       └── tasks/
│   │
│   └── requirements.yml                # Collections Ansible nécessaires
│
└── terraform/
    └── README.md                       # Placeholder pour la suite