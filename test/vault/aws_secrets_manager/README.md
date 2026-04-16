# AWS Secrets Manager + Kubernetes (base de travail)

## Objectif

Ce dossier fournit une **base de configuration** pour intégrer **AWS Secrets Manager** avec **Kubernetes**.

> **Important**
> - Cette base est fournie **sans compte AWS** et **sans EKS réel**.
> - Elle est donc **non testée dans ce contexte local Minikube**.
> - Le code est présent comme **base de départ** pour un environnement AWS réel.

---

## 1. Contexte de ce dépôt

### Sans compte AWS

Cette base a été préparée pour servir de **référence de configuration** lorsque l'on souhaite brancher Kubernetes à AWS Secrets Manager, mais **sans disposer d'un compte AWS pour exécuter les tests**.

Conséquence :
- les manifestes Kubernetes sont fournis ;
- les emplacements des ARN, noms de cluster, régions et secrets sont à remplacer ;
- la partie AWS (IAM, OIDC, Secrets Manager, EKS) doit être réalisée sur un vrai environnement AWS avant de pouvoir valider le fonctionnement.

En particulier, **Minikube seul ne reproduit pas fidèlement** :
- l'OIDC provider EKS ;
- IRSA ou Pod Identity ;
- l'authentification IAM native d'un Pod vers AWS Secrets Manager.  
  AWS recommande justement d'utiliser l'**AWS Secrets and Configuration Provider (ASCP)** avec le **Secrets Store CSI Driver** pour récupérer les secrets dans des Pods EKS, en s'appuyant sur l'identité IAM du Pod.

---

## 2. Simulation LocalStack : piste écartée ici

La simulation avec **LocalStack** a été **écartée dans cette base**.

Raison : la documentation LocalStack indique désormais un fonctionnement par **plans / licences**, avec un modèle d'abonnement défini par workspace et par utilisateur. La doc mentionne notamment des plans `Base`, `Ultimate`, `Enterprise` pour un usage commercial, ainsi qu'un plan `Hobby` pour un usage non commercial.

Comme l'objectif ici est de fournir une base simple, stable et réutilisable, la solution LocalStack est considérée **abrogée pour ce document**.

---

## 3. Approche AWS recommandée

La voie recommandée côté AWS/EKS consiste à :

1. stocker le secret dans **AWS Secrets Manager** ;
2. installer le **Secrets Store CSI Driver** et l'**AWS Secrets and Configuration Provider (ASCP)** sur EKS ;
3. donner à un **ServiceAccount Kubernetes** un rôle IAM autorisé à lire le secret ;
4. monter le secret dans le Pod via un **SecretProviderClass**.

AWS documente explicitement cette approche pour **monter les secrets comme fichiers dans les Pods** et limiter l'accès via IAM à des Pods précis.

AWS recommande aussi l'usage d'un **secret store externe** plutôt qu'un simple `Secret` Kubernetes, notamment pour bénéficier d'un contrôle d'accès fin et de la rotation. AWS rappelle également que les secrets montés en volume sont préférables aux variables d'environnement quand c'est possible.

---

## 4. Ce qui est fourni ici

### Manifests principaux

- `manifests/00-namespace.yaml` : namespace applicatif
- `manifests/01-serviceaccount.yaml` : ServiceAccount annoté avec un rôle IAM
- `manifests/02-secretproviderclass.yaml` : déclaration du secret AWS à monter
- `manifests/03-pod.yaml` : Pod de test qui consomme le secret monté

### Manifests optionnels

- `optional/10-eso-secretstore.yaml`
- `optional/11-eso-externalsecret.yaml`

Ces deux manifestes optionnels montrent la variante **External Secrets Operator (ESO)**, qui **copie** un secret depuis AWS Secrets Manager vers un `Secret` Kubernetes. AWS distingue bien cette approche de l'approche CSI : ESO synchronise vers Kubernetes, alors que le CSI Driver lit depuis le secret store externe.

---

## 5. Procédure côté AWS pour la gestion du secret

### Étape 1 — Créer le secret dans AWS Secrets Manager

Exemple avec AWS CLI :

```bash
aws secretsmanager create-secret \
  --name demo/app-config \
  --description "Secret applicatif" \
  --secret-string '{"username":"demo-user","password":"demo-pass","url":"jdbc:mysql://db.example.internal:3306/app"}' \
  --region eu-west-3
```

Exemple de lecture :

```bash
aws secretsmanager get-secret-value \
  --secret-id demo/app-config \
  --region eu-west-3
```

Secrets Manager crée une nouvelle version à chaque mise à jour d'un secret, et les versions peuvent être référencées via `AWSCURRENT`, `AWSPREVIOUS` ou un `VersionId`.

### Étape 2 — Créer une policy IAM minimale

Exemple de policy à adapter :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:eu-west-3:123456789012:secret:demo/app-config-*"
    }
  ]
}
```

### Étape 3 — Associer l'accès IAM au Pod

Dans EKS, AWS supporte l'accès aux secrets via l'identité du Pod en s'appuyant sur **Pod Identity** ou **IRSA**, selon la version et le mode choisi. Les prérequis officiels mentionnent notamment EKS, AWS CLI, kubectl et Helm.

### Étape 4 — Installer les composants Kubernetes côté EKS

AWS documente l'installation de l'ASCP soit comme add-on EKS, soit via Helm. L'installation Helm documentée par AWS pour le provider inclut :

```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

AWS documente aussi l'installation Helm du provider AWS depuis le chart `aws-secrets-manager/secrets-store-csi-driver-provider-aws`.

### Étape 5 — Déployer le `SecretProviderClass`

Le `SecretProviderClass` décrit quel secret AWS monter dans le Pod et sous quel nom de fichier.

### Étape 6 — Déployer le Pod applicatif

Le Pod montera le secret sous `/mnt/secrets-store`.

---

## 6. Limites de Minikube pour cette base

Tu peux stocker et appliquer ces YAML dans **Minikube** pour te familiariser avec les objets Kubernetes, mais **le flux complet ne sera pas validable sans AWS** car l'authentification réelle vers Secrets Manager dépend d'AWS/EKS.  
Cette base sert donc surtout de **squelette prêt à compléter**.

---

## 7. Remplacements à faire

Avant usage réel, remplace au minimum :

- `eu-west-3` par ta région AWS ;
- `123456789012` par ton AWS Account ID ;
- `my-eks-cluster` par ton cluster EKS ;
- `arn:aws:iam::123456789012:role/eks-app-secrets-role` par ton vrai rôle IAM ;
- `demo/app-config` par le nom réel de ton secret ;
- les namespaces, noms d'application et chemins de montage si besoin.

---

## 8. Déploiement des manifests fournis

```bash
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-serviceaccount.yaml
kubectl apply -f manifests/02-secretproviderclass.yaml
kubectl apply -f manifests/03-pod.yaml
```

Pour la variante ESO :

```bash
kubectl apply -f optional/10-eso-secretstore.yaml
kubectl apply -f optional/11-eso-externalsecret.yaml
```

---

## 9. Rappel architectural

### Option recommandée AWS
- **Secrets Manager** reste la source de vérité
- **ASCP + Secrets Store CSI Driver** montent le secret dans le Pod
- pas besoin de dupliquer systématiquement le secret dans un `Secret` Kubernetes.

### Option alternative
- **External Secrets Operator** lit AWS Secrets Manager
- puis crée / met à jour un `Secret` Kubernetes
- utile si une application exige un `Secret` Kubernetes natif.

## 10. Note de AWS (official)

### Intégration AWS Secrets Manager avec Kubernetes

Il est tout à fait possible d’intégrer AWS Secrets Manager avec Kubernetes afin d’externaliser la gestion des secrets et d’éviter de les stocker directement dans les objets natifs Secret du cluster. L’approche présentée par AWS repose sur l’utilisation de mécanismes Kubernetes standards (comme les ServiceAccounts, annotations ou webhooks) pour permettre aux pods de récupérer dynamiquement leurs secrets depuis un gestionnaire externe. Cette intégration apporte plusieurs avantages majeurs : une gestion centralisée des secrets, une rotation automatique des identifiants, ainsi qu’un contrôle d’accès fin et auditable via les politiques IAM.

Cependant, AWS met également en avant certaines mises en garde importantes. Tout d’abord, cette intégration introduit une complexité supplémentaire dans l’architecture, notamment en raison de la dépendance à des composants intermédiaires (injecteurs, contrôleurs, ou drivers CSI). Ensuite, la sécurité repose fortement sur la bonne configuration des identités (ServiceAccounts, IAM roles), ce qui peut devenir un point de fragilité en cas de mauvaise gestion des permissions. Mais il faut également prendre en compte le calcul des coût sde stockage (voir la grille tarifaire), la limite de taille de Secrets Manager et la limite de lectures par secondes. Enfin, même si cette approche améliore la gestion du cycle de vie des secrets, elle nécessite une bonne compréhension des mécanismes Kubernetes et AWS pour éviter les erreurs de configuration ou d’exposition involontaire des données sensibles.

En résumé, cette solution est recommandée pour des environnements nécessitant un haut niveau de sécurité et de centralisation des secrets, mais elle doit être mise en œuvre avec rigueur et accompagnée de bonnes pratiques en matière d’authentification, de gestion des accès et de rotation des secrets. 

- source: https://aws.amazon.com/fr/blogs/france/aws-secrets-controller-comment-integrer-aws-secrets-manager-avec-kubernetes/