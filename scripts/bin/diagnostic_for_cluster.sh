#!/usr/bin/env bash
#===============================================================================
# Fichier      : diagnostic_for_cluster.sh
# Description  : Vérification de l état de snaté du cluster
# Dépendances  : core.sh, global.env
#===============================================================================

#===============================================================================
# Etape 1 : Etat du noeud
#===============================================================================
# 
kubectl get nodes -o wide

#===============================================================================
# Etape 2 : Inspecter les conditions du noeud
#===============================================================================

# if
# kubectl describe node $node-name

#===============================================================================
# Etape 3 : Vérifiez la santé du plan de controle
#===============================================================================

# kubectl get --raw='/readyz?verbose' | head -20
# kubectl get --raw='/livez?verbose' | head -20

# 
kubectl get pods -n kube-system -o wide


#===============================================================================
# Etape 4 : Surveiller la consommation avec metrics-server
#===============================================================================

# Vérifiez l installation de metrics-server 

# Lire la consommation des noeuds
kubectl top nodes

# Lire la consommation des pods
kubectl top pods -A --sort-by=cpu | head -15

# Avec un namespace spéficique
kubectl top pods -n kube-system


#===============================================================================
# Etape 5 : Lire les events du cluster
#===============================================================================

# 
kubectl events -A --types=Warning

# 
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -20

# Filtrage avancé pour une ressource spécifique
# kubectl events -A --for=node/ks-worker1
# kubectl events -n default --for=pod/mon-pod

#===============================================================================
# Etape 6 : Interroger les metrics internes
#===============================================================================

# Metrics du kube-apiserver (Métriques globales du plan de contrôle)
kubectl get --raw /metrics | grep -E "^# HELP (apiserver|etcd_)" | head

###
# Métriques du kubelet et de cAdvisor
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Métriques propres au kubelet
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics" | grep -E "^# HELP" | head

# Métriques cAdvisor (par conteneur)
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics/cadvisor" | grep -E "^# HELP" | head
###

# Pression sur les nœuds avec PSI (GA en 1.36)
kubectl get --raw "/api/v1/nodes/${NODE}/proxy/metrics/cadvisor" \
  | grep -E "^container_pressure_(cpu|memory|io)_(stalled|waiting)"

  
