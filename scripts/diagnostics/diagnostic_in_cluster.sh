#!/usr/bin/env bash
#===============================================================================
# Fichier      : diagnostic_in_cluster.sh
# Description  : Runbook manuel de diagnostic Kubernetes
# Objectif     : Guider le diagnostic cluster → node → pod → réseau
# Dépendances  : kubectl, accès kubeconfig valide
# Remarque     : Ce script est une checklist exécutable/commentée.
#===============================================================================

#===============================================================================
# MÉTHODOLOGIE DE DIAGNOSTIC
#===============================================================================
# Niveau 1 : Cluster
# Niveau 2 : Nodes
# Niveau 3 : Pods / Workloads
# Niveau 4 : Réseau / Services / DNS
#
# Commandes essentielles :
# - kubectl get
# - kubectl describe
# - kubectl logs
# - kubectl events
#
# Commandes avancées :
# - kubectl exec
# - kubectl debug
# - kubectl top
# - kubectl get --raw='/readyz?verbose'
#===============================================================================


#===============================================================================
# ÉTAPE 1 — ÉTAT GLOBAL DU CLUSTER
#===============================================================================

# Vérifier l'accès au cluster
kubectl cluster-info

# Vérifier le contexte Kubernetes courant
kubectl config current-context

# Vérifier les nodes
kubectl get nodes -o wide

# Vérifier les namespaces
kubectl get namespaces

# Vérifier les composants système Kubernetes
kubectl get pods -n kube-system -o wide

# Vérifier les events globaux récents
kubectl get events -A --sort-by=.lastTimestamp

# Filtrer uniquement les warnings
kubectl get events -A --sort-by=.lastTimestamp | grep -v "Normal"

# Vérifier la santé interne de l'API server
# Toutes les lignes doivent idéalement être en [+]
kubectl get --raw='/readyz?verbose' | grep -E '\[(\+|\-)\]'


#===============================================================================
# ÉTAPE 2 — ÉTAT DES NODES
#===============================================================================

# Voir l'état global des nodes
kubectl get nodes -o wide

# Décrire un node précis
# À surveiller :
# - Ready
# - MemoryPressure
# - DiskPressure
# - PIDPressure
# - NetworkUnavailable
#
# Remplacer <node_name>
# kubectl describe node <node_name>

# Voir les ressources consommées par les nodes
# Nécessite metrics-server
kubectl top nodes

# Voir les events liés à un node précis
# Remplacer <node_name>
# kubectl events --for node/<node_name> --types=Warning

# Alternative compatible avec plus de versions kubectl
# kubectl get events -A --sort-by=.lastTimestamp | grep <node_name>


#===============================================================================
# ÉTAPE 3 — ÉTAT DES PODS / WORKLOADS
#===============================================================================

# Voir tous les pods du cluster
kubectl get pods -A -o wide

# Voir uniquement les pods non Running / non Completed
kubectl get pods -A --no-headers | awk '$4!="Running" && $4!="Completed"'

# Voir les pods d'un namespace précis
# Remplacer <namespace>
# kubectl get pods -n <namespace> -o wide

# Décrire un pod précis
# Remplacer <pod> et <namespace>
# kubectl describe pod <pod> -n <namespace>

# Voir les logs actuels d'un pod
# kubectl logs <pod> -n <namespace>

# Voir les logs précédents après restart / CrashLoopBackOff
# kubectl logs <pod> -n <namespace> --previous

# Voir les logs d'un conteneur précis dans un pod multi-container
# kubectl logs <pod> -n <namespace> -c <container>

# Voir les logs précédents d'un conteneur précis
# kubectl logs <pod> -n <namespace> -c <container> --previous

# Limiter les logs aux dernières lignes
# kubectl logs <pod> -n <namespace> --tail=50

# Suivre les logs en temps réel
# kubectl logs <pod> -n <namespace> -f

# Voir les events liés à un pod précis
# kubectl events --for pod/<pod> -n <namespace>

# Voir les warnings d'un namespace
# kubectl events -n <namespace> --types=Warning

# Alternative si kubectl events n'est pas disponible
# kubectl get events -n <namespace> --sort-by=.lastTimestamp

# Entrer dans un pod pour inspection légère
# Attention : nécessite qu'un shell soit disponible dans l'image
# kubectl exec -it <pod> -n <namespace> -- /bin/sh

# Alternative si bash existe
# kubectl exec -it <pod> -n <namespace> -- /bin/bash

# Debug avancé avec conteneur éphémère
# Utile si l'image du pod ne contient pas d'outils de debug
# kubectl debug -it <pod> -n <namespace> --image=busybox:1.37 --target=<container>


#===============================================================================
# ÉTAPE 4 — WORKLOADS : DEPLOYMENTS / REPLICASETS / DAEMONSETS / STATEFULSETS
#===============================================================================

# Voir les deployments
kubectl get deployments -A

# Voir les replicasets
kubectl get replicasets -A

# Voir les daemonsets
kubectl get daemonsets -A

# Voir les statefulsets
kubectl get statefulsets -A

# Décrire un deployment précis
# kubectl describe deployment <deployment> -n <namespace>

# Vérifier l'historique de rollout
# kubectl rollout history deployment/<deployment> -n <namespace>

# Vérifier l'état du rollout
# kubectl rollout status deployment/<deployment> -n <namespace>


#===============================================================================
# ÉTAPE 5 — RÉSEAU / SERVICES / ENDPOINTS / DNS
#===============================================================================

# Voir tous les services
kubectl get svc -A -o wide

# Voir les services d'un namespace
# kubectl get svc -n <namespace> -o wide

# Décrire un service précis
# kubectl describe svc <service> -n <namespace>

# Vérifier les endpoints classiques
kubectl get endpoints -A

# Vérifier les EndpointSlices
kubectl get endpointslices -A

# Vérifier les EndpointSlices d'un service précis
# kubectl get endpointslices -n <namespace> -l kubernetes.io/service-name=<service>

# Vérifier les ingress
kubectl get ingress -A

# Décrire un ingress précis
# kubectl describe ingress <ingress> -n <namespace>


#===============================================================================
# ÉTAPE 6 — DNS / COREDNS
#===============================================================================

# Vérifier que CoreDNS fonctionne
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide

# Voir les logs récents de CoreDNS
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50

# Voir les events kube-system liés à DNS/CoreDNS
kubectl get events -n kube-system --sort-by=.lastTimestamp | grep -i dns

# Tester la résolution DNS depuis un pod temporaire
# Attention : cette commande crée temporairement un pod.
# Remplacer <service> et <namespace>
# kubectl run dnstest \
#   --image=busybox:1.37 \
#   --rm -it \
#   --restart=Never \
#   -- nslookup <service>.<namespace>.svc.cluster.local


#===============================================================================
# ÉTAPE 7 — TEST CONNECTIVITÉ SERVICE
#===============================================================================

# Tester un service HTTP depuis un pod temporaire
# Attention : cette commande crée temporairement un pod.
# Remplacer <service>, <namespace> et <port>
# kubectl run curltest \
#   --image=curlimages/curl:8.14.1 \
#   --rm -it \
#   --restart=Never \
#   -- curl -v http://<service>.<namespace>.svc.cluster.local:<port>/

# Tester directement un ClusterIP
# kubectl run curltest \
#   --image=curlimages/curl:8.14.1 \
#   --rm -it \
#   --restart=Never \
#   -- curl -v http://<cluster-ip>:<port>/


#===============================================================================
# ÉTAPE 8 — STOCKAGE / PVC / PV
#===============================================================================

# Voir les PVC
kubectl get pvc -A

# Voir les PV
kubectl get pv

# Décrire un PVC bloqué
# kubectl describe pvc <pvc> -n <namespace>

# Décrire un PV
# kubectl describe pv <pv>


#===============================================================================
# ÉTAPE 9 — CONFIGURATION / SECRETS / CONFIGMAPS
#===============================================================================

# Voir les ConfigMaps
kubectl get configmaps -A

# Voir les Secrets
kubectl get secrets -A

# Décrire une ConfigMap
# kubectl describe configmap <configmap> -n <namespace>

# Décrire un Secret
# kubectl describe secret <secret> -n <namespace>


#===============================================================================
# ÉTAPE 10 — RBAC / SERVICE ACCOUNTS
#===============================================================================

# Voir les ServiceAccounts
kubectl get serviceaccounts -A

# Voir les Roles et RoleBindings
kubectl get roles,rolebindings -A

# Voir les ClusterRoles et ClusterRoleBindings
kubectl get clusterroles,clusterrolebindings

# Tester une permission
# Remplacer <verb>, <resource>, <namespace>
# Exemple : kubectl auth can-i get pods -n default
# kubectl auth can-i <verb> <resource> -n <namespace>


#===============================================================================
# ÉTAPE 11 — COMMANDES DE TRIAGE RAPIDE
#===============================================================================

# Pods problématiques
kubectl get pods -A --no-headers | awk '$4!="Running" && $4!="Completed"'

# Events warnings
kubectl get events -A --sort-by=.lastTimestamp | grep -v "Normal"

# Nodes non Ready
kubectl get nodes --no-headers | awk '$2!="Ready"'

# PVC non Bound
kubectl get pvc -A --no-headers | awk '$3!="Bound"'

# Services sans endpoints
kubectl get endpoints -A

# Redémarrages de pods
kubectl get pods -A --sort-by='.status.containerStatuses[0].restartCount'