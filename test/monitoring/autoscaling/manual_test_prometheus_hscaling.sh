#!usr/bin/env bash
# test deployment in kubernetes
# this file.sh is a training for deployment not use for automation

# get prometheus adpater for horizental scaling
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# update helm in monitoring namespace for prometheus-adapter
helm install prometheus-adapter prometheus-community/prometheus-adapter \
  -n monitoring \
  --create-namespace \
  -f ./../../template/alerting/rules/adapter-values.yml

# check
kubectl get apiservices | grep metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq

# apply horizental prometheus autoscaling rules
kubectl apply -f ./../../template/alerting/rules/hpa.yml