#!/usr/bin/env bash
#===============================================================================
# Fichier      : diagnostic_in_cluster.sh
# Description  : Vérification de global du cluster et de son contenu
# Dépendances  : core.sh, global.env
#===============================================================================

#===============================================================================
# Rappel de la méthodologie de Diagnostiquer
# Appliquer une méthode de triage en 4 niveaux : cluster → nœud → pod → réseau
# Maîtriser les 4 commandes de diagnostic essentielles : get, describe, logs, events
# Utiliser kubectl debug avec les conteneurs éphémères pour inspecter un pod en cours d'exécution
# Diagnostiquer les problèmes de Service : DNS, EndpointSlices, kube-proxy
#===============================================================================

#===============================================================================
# Etape 1 : Etat du cluster
#===============================================================================

# vérifie l'accès au cluster
kubectl cluster-info

# if network, kubeconfig, VPN, certificat
# cat ~/.kube/config

#
kubectl get nodes

#
kubectl get pods -n kube-system -o wide

# if 
# all lignes have to be [+]
# kubectl get --raw='/readyz?verbose' | grep -E '\[(\+|\-)\]'

#===============================================================================
# Etape 2 : Etat du neud 
#===============================================================================

#
kubectl get nodes

# set in function all nodes with a loop
# check : "Ready", ""MemoryPressure", "DiskPressure", "PIDPressure", "NetworkUnavailable"
# kubectl describe node <$node_name>

# Vérifier la consommation du noeud
kubectl top nodes

# Vérifier les events récents
# kubectl events --for node/<nom-du-noeud> --types=Warning


#===============================================================================
# Etape 3 : Etat du/des pod(s)
#===============================================================================

# create function with loop get all namespace

#
# kubectl get pods -n <namespace> -o wide

# 
kubectl describe pod <pod> -n <namespace>

# all commande to focus diagnostic on one pod
# kubectl logs <pod> -n <namespace>
# kubectl logs <pod> -n <namespace> --previous
# kubectl logs <pod> -n <namespace> -c <conteneur> --previous
# kubectl logs <pod> -n <namespace> --tail=50

# identique pour les events
kubectl events --for pod/<pod> -n <namespace>
kubectl events -n <namespace> --types=Warning

# rappel de commande si besoin d'entrer dans un pod
# kubectl exec -it <pod> -n <namespace> -- /bin/sh

#===============================================================================
# Etape 4 : Etat du réseau
#===============================================================================

#
kubectl get namespaces

# 
kubectl get svc

# 
# kubectl get svc <service> -n <namespace>

# Vérifier les EndpointSlices
# kubectl get endpointslices -n <namespace> -l kubernetes.io/service-name=<service>

# Vérifier la résolution DNS
# kubectl run dnstest --image=busybox:1.37 --rm -it --restart=Never -- nslookup <service>.<namespace>.svc.cluster.local

# Vérifier que CoreDNS fonctionne
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Vérifier les logs de CoreDNS
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=20

# tester la connectivité de bout en bout
kubectl run curltest --image=curlimages/curl:8.14.1 --rm -it --restart=Never -- curl -v http://<service>.<namespace>.svc.cluster.local:<port>/
