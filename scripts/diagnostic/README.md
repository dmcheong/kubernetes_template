
# Kubernetes Diagnostic Toolkit

## Description

Ce toolkit Bash regroupe plusieurs scripts de diagnostic Kubernetes avec des rôles séparés.

L’objectif n’est pas de créer un seul script qui fait tout, mais de distinguer clairement :

- la collecte automatique des problèmes visibles
- la surveillance live des événements
- le diagnostic manuel du contenu du cluster
- le diagnostic manuel de la santé du cluster

Cette séparation permet de garder une approche lisible, progressive et adaptée au troubleshooting Kubernetes réel.

---

# Contenu

## Scripts disponibles

| Script | Type | Description |
|---|---|---|
| `diagnostic_for_cluster.sh` | Manuel / runbook | Diagnostic de la santé globale du cluster |
| `watch_events.sh` | Automatique / live | Surveille les événements Kubernetes non normaux en temps réel |
| `diagnostic_test_cluster.sh` | Automatique | Collecte les informations des pods problématiques |
| `diagnostic_in_cluster.sh` | Manuel / runbook | Diagnostic du contenu du cluster |

---

# Ordre recommandé d’exécution

L’ordre conseillé pour diagnostiquer correctement un environnement Kubernetes est :

```text
1. Santé du cluster
2. Surveillance des événements
3. Collecte automatique
4. Diagnostic interne ciblé
```

Pourquoi ?

Un pod peut être en erreur à cause d’un problème plus global :

- node NotReady
- CoreDNS cassé
- kube-system dégradé
- pression mémoire/disque
- problème réseau
- problème stockage

Il est donc préférable de commencer par vérifier le socle Kubernetes avant les applications.

---

# Workflow recommandé

## 1. Vérifier la santé globale du cluster

```bash
./diagnostic_for_cluster.sh
```

---

## 2. Surveiller les événements Kubernetes

```bash
./watch_events.sh
```

---

## 3. Générer une collecte automatique

```bash
./diagnostic_test_cluster.sh all
```

---

## 4. Diagnostiquer le contenu du cluster

```bash
./diagnostic_in_cluster.sh
```

---

# Installation

```bash
chmod +x diagnostic_for_cluster.sh
chmod +x watch_events.sh
chmod +x diagnostic_test_cluster.sh
chmod +x diagnostic_in_cluster.sh
```

---

# 1. Script `diagnostic_for_cluster.sh`

## Rôle

Runbook manuel pour diagnostiquer :

- nodes
- kube-system
- control plane
- API server
- metrics-server
- kubelet
- cAdvisor
- réseau système
- CNI

---

# 2. Script `watch_events.sh`

## Rôle

Surveille les warnings Kubernetes en temps réel.

Commande utilisée :

```bash
kubectl get events -A -w | grep -v "Normal"
```

## Utilisation

```bash
./watch_events.sh
```

---

# 3. Script `diagnostic_test_cluster.sh`

## Rôle

Collecte automatiquement :

- describe
- logs
- logs précédents
- warnings
- état des nodes
- état des namespaces

## Utilisation

```bash
./diagnostic_test_cluster.sh [MODE]
```

## Modes disponibles

| Mode | Description |
|---|---|
| `all` | Tout le cluster |
| `app` | Namespaces applicatifs |
| `system` | Namespaces système |
| `platform` | Namespaces plateforme |

## Exemple

```bash
./diagnostic_test_cluster.sh all
```

## Détection des pods problématiques

Le script considère comme problématique tout pod dont le statut est différent de :

```text
Running
Completed
```

Exemples de statuts détectés :

```text
CrashLoopBackOff
Error
ImagePullBackOff
Pending
ContainerCreating
Evicted
Failed
Unknown
```
---
## Résultats générés

Les diagnostics automatiques sont stockés dans :

```text
./logs/${TIMESTAMP}_by_diagnostic_script/
```

Avec un dossier horodaté à chaque exécution :

```text
*_by_diagnostic_script/
├── latest -> 2026-05-20_18-44-11
├── 2026-05-20_18-44-11/
├── 2026-05-20_19-12-03/
└── 2026-05-20_20-05-49/
```

Cela permet de conserver une vraie traçabilité des diagnostics.

## Traçabilité

Chaque exécution peut créer :

- un dossier horodaté
- un fichier `RUN_INFO.txt`

```text
RUN_INFO.txt
```

Ce fichier indique :

- date du diagnostic
- heure du diagnostic
- mode utilisé
- commande lancée
- contexte Kubernetes
- cluster ciblé
- utilisateur kubeconfig
- dossier de sortie
- nombre de pods analysés
- liste des fichiers générés

---

# 4. Script `diagnostic_in_cluster.sh`

## Rôle

Runbook manuel pour diagnostiquer :

- pods
- services
- DNS
- CoreDNS
- EndpointSlices
- stockage
- RBAC

---

# Sécurité

Les scripts automatiques utilisent principalement :

```text
kubectl get
kubectl describe
kubectl logs
kubectl events
```

Les scripts manuels peuvent aussi utiliser :

```text
kubectl run
kubectl exec
kubectl debug
```

Ces commandes doivent être utilisées volontairement.

---

# Bonnes pratiques

- Vérifier le contexte Kubernetes avant toute action.
- Commencer par la santé du cluster avant les pods.
- Garder les diagnostics horodatés.
- Considérer les erreurs RBAC comme des informations utiles.
- Garder les scripts simples et spécialisés.
