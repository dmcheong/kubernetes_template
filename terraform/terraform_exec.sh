#!/bin/bash

set -e

terraform -chdir=./terraform init
terraform -chdir=./terraform fmt -recursive
terraform -chdir=./terraform validate
terraform -chdir=./terraform plan
terraform -chdir=./terraform apply