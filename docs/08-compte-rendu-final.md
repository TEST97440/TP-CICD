# 08 - Compte rendu final

## 1\. Synthèse

Ce projet met en place une chaîne CI/CD complète pour Catal-Log, permettant de
construire, tester, publier et promouvoir une image Docker Nginx contenant un site
statique, via GitHub Actions et GitHub Container Registry. Chaque étape est
automatisée, traçable et reproductible. L'objectif est d'éliminer les opérations
manuelles répétitives et de garantir que ce qui est testé en recette est exactement
ce qui est déployé en production, sans aucun rebuild.

## 2\. Fonctionnement technique

Le chemin complet d'un commit jusqu'en production simulée est le suivant :

1. **Commit sur main** : déclenche automatiquement le workflow 01-ci.yml.
2. **01-ci.yml** : vérifie la présence des fichiers attendus, valide la syntaxe du
compose.yml, construit l'image Docker sur le runner GitHub, démarre un conteneur
sur le port 8083 et teste HTTP sur / et /version.json. Si un test échoue, le
pipeline s'arrête et rien n'est publié.
3. **02-publish-ghcr.yml** : déclenché sur push sur main. Se connecte à GHCR via le
GITHUB\_TOKEN, construit et publie l'image avec les tags sha-cee92d4 et latest.
Le digest sha256 est affiché dans le résumé du job.
4. **03-promote.yml** : déclenché manuellement via workflow\_dispatch. Le job
validate-recette tire l'image depuis GHCR sans rebuild et reteste HTTP. Si la
validation réussit, le job promote-production-simulee retague l'image vers
production-simulee et la repousse dans GHCR. Aucun docker build n'est exécuté.

## 3\. Conteneurisation C12

Le Dockerfile utilise l'image officielle `nginx:1.27-alpine`. La version est fixée
pour garantir la reproductibilité : chaque build produit la même image de base quelle
que soit la date d'exécution. Alpine est choisi pour sa taille minimale et sa surface
d'attaque réduite.

Les labels OCI (`org.opencontainers.image.\*`) documentent l'image de manière standard,
lisible par les outils de registre. Le HEALTHCHECK permet à Docker de surveiller l'état
du service Nginx sans outil externe, en effectuant une requête wget toutes les 30
secondes.

Le build est entièrement automatisé dans GitHub Actions. L'image produite est
ghcr.io/test97440/tp-cicd, identifiée par le digest
sha256:2fe42ea3b041c63dedb2558dcc5d40dff87935cd1b35e482d78707ed81f884e7.
Le test local a confirmé le bon fonctionnement du conteneur sur le port 8083
(ID 4f29de4e31ac).

## 4\. Orchestration et scaling C13

Le fichier compose.yml décrit deux services sur un réseau bridge cicd\_net :

* **web** : le serveur Nginx qui sert le site statique, construit depuis le Dockerfile
local.
* **tester** : un conteneur curlimages/curl qui exécute automatiquement deux requêtes
HTTP vers web (`/` et `/version.json`) au démarrage puis s'arrête. Il joue le rôle
d'un test d'intégration au niveau de l'orchestration.

La simulation de scaling avec `docker compose up -d --scale web=2` a démarré deux
instances du service web. Le service tester a pu joindre le nom DNS web qui pointe
vers l'une des deux instances via le réseau cicd\_net.

Cette simulation a ses limites : pas de répartition de charge automatique sur un port
externe, pas de failover multi-hôte, pas de gestion d'état distribuée. En production,
une orchestration comme Kubernetes serait nécessaire pour répondre à ces besoins.

## 5\. Automatisation et sécurité C14

Les trois workflows couvrent l'intégralité de la chaîne :

* **01-ci.yml** : intégration continue, tests automatisés à chaque push.
* **02-publish-ghcr.yml** : livraison continue vers GHCR avec identification précise
via tag sha- et digest.
* **03-promote.yml** : déploiement contrôlé avec validation en recette et approbation
manuelle avant production-simulee.

Aucun secret n'est stocké dans le code. Le GITHUB\_TOKEN est le seul mécanisme
d'authentification utilisé : temporaire, automatique, révoqué en fin de run et limité
aux permissions déclarées dans chaque workflow.

Les permissions sont déclarées explicitement dans chaque workflow et limitées au strict
nécessaire : `contents: read` pour le CI, `contents: read, packages: write` pour la
publication et la promotion.

La promotion sans rebuild garantit que l'artefact déployé est identique bit pour bit
à celui qui a été testé. En cas de problème, le rollback s'effectue en déclenchant
le workflow 03-promote.yml avec le tag sha- de l'ancienne version stable.

Le dépôt Git constitue la source principale de vérité pour la sauvegarde : il contient
le code, les workflows, la documentation et l'historique complet. Les images GHCR
permettent de redéployer sans rebuilder depuis les sources.

## 6\. Production réelle

**Gestion des secrets** : en production, les credentials (accès registre privé, base
de données, API tierces) seraient stockés dans GitHub Secrets ou un coffre dédié comme
HashiCorp Vault. Ils seraient injectés au runtime via des variables d'environnement,
jamais au moment du build. Écrire un secret dans un Dockerfile est dangereux car il
reste lisible dans les layers via `docker history` même après suppression.

**Rollback** : grâce aux tags sha- conservés dans GHCR et au digest immuable, le
rollback s'effectue sans rebuild. On déclenche le workflow 03-promote.yml avec le
tag sha- de l'ancienne version stable comme source\_tag. Le pipeline reteste l'image
en recette puis la repromeut. Le digest garantit que l'artefact redéployé est
exactement celui qui avait été validé.

**Sauvegarde / restauration** : le dépôt Git couvre le code, les workflows et la
documentation. Les images GHCR peuvent être sauvegardées via `docker save` et
restaurées via `docker load`. La configuration des environnements GitHub doit être
documentée car elle n'est pas exportable automatiquement.

**Contrôle des vulnérabilités** : un scanner comme Trivy serait intégré dans le
workflow 01-ci.yml après le build. Une CVE critique bloquerait la publication dans
GHCR, évitant de déployer une image exposée à des failles connues.

**Validation manuelle avant production** : l'environnement production-simulee est
configuré avec une approbation manuelle obligatoire dans GitHub. En production réelle,
cette validation serait renforcée par une checklist formelle, un ticket de changement
et une fenêtre de déploiement planifiée.

## 7\. Preuves

* Dépôt GitHub : https://github.com/TEST97440/TP-CICD
* Image GHCR : https://github.com/TEST97440/TP-CICD/pkgs/container/tp-cicd
* Digest : sha256:efe803e5319212a4957c9506f17dc56deccbe3c51a5e85a759c4737d3b2261a8
* Run CI réussi (01-ci.yml) : https://github.com/TEST97440/TP-CICD/actions/runs/28585002134
* Run publication GHCR (02-publish-ghcr.yml) : https://github.com/TEST97440/TP-CICD/actions/runs/28585002065
* Run promotion (03-promote.yml) : https://github.com/TEST97440/TP-CICD/actions/runs/28585192882

<img width="882" height="860" alt="image" src="https://github.com/user-attachments/assets/e6e1f6e3-0fcd-4a66-963b-4daaa4d3c550" />

<img width="842" height="835" alt="image" src="https://github.com/user-attachments/assets/1f0f31b1-d0c5-41a2-86f4-f537dc0869f4" />

<img width="1242" height="565" alt="image" src="https://github.com/user-attachments/assets/ecd2b394-6de3-4854-a7cc-6987ca973535" />

<img width="2172" height="255" alt="ChatGPT Image 2 juil  2026, 15\_59\_22" src="https://github.com/user-attachments/assets/0fb69714-c008-4fbf-89b1-38a08c7e3a1c" />

## 8\. Difficultés et apprentissages

Ce TP a été très intéressant et différent de Jenkins que j'avais déjà utilisé
auparavant. GitHub Actions est plus simple et plus rapide à mettre en place : tout
est directement intégré au dépôt, sans serveur à administrer ni plugin à configurer
séparément.

Quelques erreurs se sont produites lors des premiers builds, notamment au niveau
de la configuration des workflows, mais après corrections le pipeline a fonctionné
correctement.

Sur la différence entre tag et digest, j'ai compris que le tag sert d'indicateur
lisible pour identifier directement une version, comme par exemple `latest` pour
la dernière version ou `sha-785ef17` pour un commit précis. Le digest quant à lui
est une empreinte générée automatiquement qui identifie de manière unique le contenu
de l'image, indépendamment de son nom ou de son tag.

La promotion sans rebuild m'a montré l'importance de la traçabilité : en gardant
le même digest entre recette et production-simulee, on a la certitude que l'image
déployée est exactement celle qui a été testée, sans aucune modification entre les
deux étapes.

