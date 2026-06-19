#!/bin/bash

# note des commande à entrer dans chaque dossier terraform avec des fichiers.tf sauf modules
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# terraform -chdir=../terraform/environments/dev/00-platform init
# terraform -chdir=../terraform/environments/dev/00-platform fmt -recursive
# terraform -chdir=../terraform/environments/dev/00-platform validate
# terraform -chdir=../terraform/environments/dev/00-platform plan -out=tfplan
# terraform -chdir=../terraform/environments/dev/00-platform apply tfplan