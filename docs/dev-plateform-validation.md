# Validation dev/00-platform

## Terraform

- [ ] terraform fmt -recursive
- [ ] terraform init
- [ ] terraform validate
- [ ] terraform plan
- [ ] terraform apply

## Kubernetes

- [ ] kubectl get nodes
- [ ] kubectl get namespaces
- [ ] kubectl get pods -A
- [ ] kubectl get svc -A
- [ ] kubectl get ingress -A
- [ ] kubectl get events -A --sort-by=.lastTimestamp

## Helm

- [ ] helm list -A

## Résultat attendu

- Node Ready
- Pods Running ou Completed
- Releases Helm deployed
- Aucun pod bloqué en Pending, CrashLoopBackOff ou ImagePullBackOff