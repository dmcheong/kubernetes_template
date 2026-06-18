#!/bin/bash

set -e

terraform -chdir=../terraform/00-platform init
terraform -chdir=../terraform/00-platform fmt -recursive
terraform -chdir=../terraform/00-platform validate
terraform -chdir=../terraform/00-platform plan