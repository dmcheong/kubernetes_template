# État actuel du projet

## Arborescence générale

L’arborescence visible est documentée à partir de la racine du projet uniquement :

```text
kubernetes_template/
├── ansible/
├── pipelines/
├── scripts/
├── terraform/
├── test/
├── .gitignore
├── .tool-versions
├── README.md
├── Readme1.md
├── ansible.sh
├── index.sh
└── terraform.sh
```


## État fonctionnel

À ce stade, la stabilisation principale concerne l’environnement `dev`.

Les points suivants sont considérés comme validés :

- Ansible charge correctement sa configuration.
- Les rôles Ansible sont bien détectés.
- Les playbooks Ansible passent les vérifications de syntaxe.
- Terraform est utilisé pour déployer le socle Kubernetes.
- Le socle `dev/00-platform` est stabilisé.
- Les composants Kubernetes principaux sont vérifiés après déploiement.
- Les diagnostics Kubernetes existent et sont séparés par rôle.
- Le test Ingress local avec Minikube est validé via port-forward.

## Structure Terraform actuelle

```text
terraform/
├── environments/
│   └── dev/
│       ├── 00-platform/
│       └── 00-platform-objects/
├── modules/
└── script/
```

La structure retenue pour les environnements est :

```text
environments/<env>/00-platform
environments/<env>/00-platform-objects
```

Cette convention doit être conservée pour les futurs environnements comme `staging` ou `prod`.

## Points d’attention

Certains fichiers générés par Terraform peuvent encore être présents dans l’arborescence de travail, par exemple `.terraform`, `terraform.tfstate`, `terraform.tfstate.backup` ou `tfplan`.

À terme, il faudra vérifier que les fichiers locaux sensibles ou générés ne sont pas versionnés inutilement.
