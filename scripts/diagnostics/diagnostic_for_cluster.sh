#!/usr/bin/env bash
#===============================================================================
# Fichier      : diagnostic_for_cluster.sh
# Description  : Runbook manuel de vérification de santé du cluster Kubernetes
# Objectif     : Diagnostiquer le socle cluster, pas le contenu applicatif
# Dépendances  : kubectl, kubeconfig valide, metrics-server optionnel
#===============================================================================

#===============================================================================
# ÉTAPE 0 — CONTEXTE KUBERNETES
#===============================================================================

kubectl config current-context

kubectl cluster-info

kubectl version


#===============================================================================
# ÉTAPE 1 — ÉTAT GLOBAL DES NODES
#===============================================================================

kubectl get nodes -o wide

# Nodes non Ready
kubectl get nodes --no-headers | awk '$2!="Ready"'

# Conditions importantes à vérifier avec describe :
# - Ready
# - MemoryPressure
# - DiskPressure
# - PIDPressure
# - NetworkUnavailable
#
# Exemple :
# kubectl describe node <node_name>


#===============================================================================
# ÉTAPE 2 — INSPECTION DÉTAILLÉE DES NODES
#===============================================================================

# Décrire tous les nodes manuellement si besoin :
# kubectl describe node <node_name>

# Lister les noms des nodes
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Vérifier les events liés aux nodes
kubectl get events -A --sort-by=.lastTimestamp | grep -i node

# Avec kubectl events si disponible :
# kubectl events -A --types=Warning --for=node/<node_name>


#===============================================================================
# ÉTAPE 3 — SANTÉ DU PLAN DE CONTRÔLE
#===============================================================================

# Vérifie la disponibilité interne de l'API server.
# Les lignes doivent idéalement être en [+].
kubectl get --raw='/readyz?verbose' | grep -E '\[(\+|\-)\]'

# Vérifie si l'API server est vivant.
kubectl get --raw='/livez?verbose' | grep -E '\[(\+|\-)\]'

# Ancienne commande, parfois disponible selon les clusters.
# Peut être dépréciée ou absente.
# kubectl get componentstatuses


#===============================================================================
# ÉTAPE 4 — ÉTAT DU NAMESPACE kube-system
#===============================================================================

# Voir les pods système
kubectl get pods -n kube-system -o wide

# Voir les pods kube-system qui ne sont pas Running / Completed
kubectl get pods -n kube-system --no-headers | awk '$3!="Running" && $3!="Completed"'

# Voir les events kube-system
kubectl get events -n kube-system --sort-by=.lastTimestamp

# Voir les warnings kube-system
kubectl get events -n kube-system --sort-by=.lastTimestamp | grep -v "Normal"


#===============================================================================
# ÉTAPE 5 — MÉTRIQUES VIA metrics-server
#===============================================================================

# Vérifier si metrics-server semble présent
kubectl get pods -A | grep -i metrics-server

# Lire la consommation des nodes
# Peut échouer si metrics-server n'est pas installé ou pas prêt.
kubectl top nodes

# Lire les pods les plus consommateurs CPU
kubectl top pods -A --sort-by=cpu | head -15

# Lire les pods les plus consommateurs mémoire
kubectl top pods -A --sort-by=memory | head -15

# Lire la consommation des pods système
kubectl top pods -n kube-system


#===============================================================================
# ÉTAPE 6 — EVENTS CLUSTER
#===============================================================================

# Warnings du cluster
kubectl events -A --types=Warning

# Alternative plus compatible
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -30

# Events non normaux
kubectl get events -A --sort-by=.lastTimestamp | grep -v "Normal"

# Filtrage avancé :
# kubectl events -A --for=node/<node_name>
# kubectl events -n kube-system --for=pod/<pod_name>


#===============================================================================
# ÉTAPE 7 — MÉTRIQUES INTERNES API SERVER
#===============================================================================

# Métriques globales exposées par l'API server.
# Peut échouer selon les permissions RBAC ou le type de cluster managé.
kubectl get --raw /metrics | grep -E "^# HELP (apiserver|etcd_|rest_client)" | head -30

# Requêtes API server utiles à surveiller :
# - apiserver_request_total
# - apiserver_request_duration_seconds
# - apiserver_current_inflight_requests
#
# Exemples :
# kubectl get --raw /metrics | grep "^apiserver_request_total" | head
# kubectl get --raw /metrics | grep "^apiserver_current_inflight_requests" | head


#===============================================================================
# ÉTAPE 8 — MÉTRIQUES KUBELET / CADVISOR PAR NODE
#===============================================================================

# Lister les nodes
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Choisir un node à inspecter :
# NODE="<node_name>"

# Exemple automatique sur le premier node :
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

echo "Node inspecté : ${NODE}"

# Métriques kubelet
# Peut échouer selon RBAC, cluster managé, proxy kubelet ou configuration sécurité.
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics" | grep -E "^# HELP" | head -20

# Métriques cAdvisor
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics/cadvisor" | grep -E "^# HELP" | head -20

# Pression CPU / mémoire / IO via PSI.
# Peut ne rien retourner selon la version Kubernetes, le kernel ou cAdvisor.
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics/cadvisor" \
  | grep -E "^container_pressure_(cpu|memory|io)_(stalled|waiting)"


#===============================================================================
# ÉTAPE 9 — STOCKAGE GLOBAL DU CLUSTER
#===============================================================================

# Vérifier les StorageClasses
kubectl get storageclass

# Vérifier les volumes persistants
kubectl get pv

# PVC non Bound dans tout le cluster
kubectl get pvc -A --no-headers | awk '$3!="Bound"'


#===============================================================================
# ÉTAPE 10 — RÉSEAU SYSTÈME / DNS / CNI
#===============================================================================

# Vérifier CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide

# Logs CoreDNS récents
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50

# Events DNS
kubectl get events -n kube-system --sort-by=.lastTimestamp | grep -i dns

# Repérer les pods réseau courants selon distributions :
kubectl get pods -A -o wide | grep -Ei 'coredns|calico|cilium|flannel|weave|kube-proxy'


#===============================================================================
# ÉTAPE 11 — RÉSUMÉ RAPIDE DE SANTÉ CLUSTER
#===============================================================================

# Nodes non Ready
kubectl get nodes --no-headers | awk '$2!="Ready"'

# Pods système problématiques
kubectl get pods -n kube-system --no-headers | awk '$3!="Running" && $3!="Completed"'

# Warnings récents
kubectl get events -A --sort-by=.lastTimestamp | grep -v "Normal" | tail -30

# PVC non Bound
kubectl get pvc -A --no-headers | awk '$3!="Bound"'

# Top nodes
kubectl top nodes