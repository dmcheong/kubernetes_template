#!/usr/bin/env bash
#===============================================================================
# Fichier      : manual_test_pod.sh
# Description  : Guide de formation sur les Pods Kubernetes via commandes inline.
#                Fichier non utilisé pour l'automatisation — entraînement manuel.
# Note         : en production, créer les pods via des Deployments et non
#                directement avec kubectl run
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Création d'un pod nginx directement via kubectl run (sans fichier YAML)
# --image=nginx : image Docker à utiliser
# Le pod est créé dans le namespace courant (dev par défaut si configuré)
#─────────────────────────────────────────────────────────────────────────────
kubectl run mon-pod --image=nginx

# vérifier l'état du pod (Running / Pending / CrashLoopBackOff)
kubectl get pods

# obtenir tous les détails du pod : IP, nœud, events, état des containers
kubectl describe pod mon-pod

# supprimer le pod
kubectl delete pod mon-pod
