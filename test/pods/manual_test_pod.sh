#!/usr/bin/env bash
# test in local not recommand for production
# file.sh not use for automation but for manual training

# create new pod with image nginx
kubectl run mon-pod --image=nginx

# check state pod
kubectl get pods

# get all details from pod
kubectl describe pod mon-pod

# delete pod
kubectl delete pod mon-pod