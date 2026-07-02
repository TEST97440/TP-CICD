# 07 - Sécurité minimale

## Permissions GitHub Actions

Les permissions sont déclarées explicitement dans chaque workflow et limitées au strict
nécessaire. Ne pas les déclarer revient à utiliser les permissions par défaut du dépôt,
qui peuvent être trop larges et exposer le projet en cas de compromission d'un workflow.

- **01-ci.yml** : `contents: read` — le workflow lit le dépôt pour construire et
  tester l'image. Il n'écrit rien, ni dans le dépôt ni dans GHCR.
- **02-publish-ghcr.yml** : `contents: read, packages: write` — le workflow lit le
  dépôt et publie l'image dans GHCR. Il n'a pas accès en écriture au code source.
- **03-promote.yml** : `contents: read, packages: write` — le workflow tire et pousse
  des tags dans GHCR. Il n'a pas accès en écriture au code source.
  
<img width="375" height="271" alt="image" src="https://github.com/user-attachments/assets/35661564-8031-4f04-a6ad-dcc7000ad547" />

## Gestion des secrets

Aucun secret n'est stocké dans le code source, dans le Dockerfile ou dans les fichiers
de configuration du dépôt. Stocker un secret dans le code présente deux risques
majeurs : il est visible par toute personne ayant accès au dépôt, et il reste dans
l'historique Git même après suppression.

Le `GITHUB_TOKEN` est un jeton temporaire généré automatiquement par GitHub Actions
au début de chaque exécution de workflow. Dans ce projet, il est utilisé pour
s'authentifier auprès de GHCR et pousser l'image. Il est révoqué automatiquement
à la fin du run et dispose uniquement des permissions déclarées dans le workflow.
Aucun jeton personnel n'a été créé ni stocké.

En production réelle, les éléments suivants devraient être placés dans GitHub Secrets
ou dans un coffre de secrets dédié (HashiCorp Vault, AWS Secrets Manager) :
- tokens d'accès à des registres d'images privés ;
- mots de passe de bases de données ;
- clés API de services tiers ;
- certificats TLS et clés privées.

Écrire un secret dans un Dockerfile est particulièrement dangereux : même supprimé
dans un layer suivant, il reste lisible via `docker history`. Les secrets doivent
être injectés au runtime, jamais au moment du build.

<img width="1388" height="261" alt="image" src="https://github.com/user-attachments/assets/96524989-d1cd-4196-87f8-2bd8f3688d57" />


## Rollback

Grâce aux tags `sha-` conservés dans GHCR et au digest immuable, il est possible de
revenir à une version précédente sans rebuilder l'image.

Procédure de rollback :

```bash
# Identifier le tag sha- de l'ancienne version stable
docker pull ghcr.io/test97440/tp-cicd:sha-785ef17

# Re-tagger vers production-simulee sans rebuild
docker tag ghcr.io/test97440/tp-cicd:sha-785ef17 \
           ghcr.io/test97440/tp-cicd:production-simulee

# Pousser le nouveau tag dans GHCR
docker push ghcr.io/test97440/tp-cicd:production-simulee
```

En pratique, le rollback s'effectue en déclenchant manuellement le workflow
03-promote.yml via workflow_dispatch en saisissant le tag `sha-` de l'ancienne
version comme `source_tag`. Le pipeline reteste l'image en recette simulée puis
la repromeut. Le digest garantit que c'est exactement le même artefact qui est
redéployé.

## Sauvegarde / restauration

| Élément | Méthode | Restauration |
|---|---|---|
| Dépôt GitHub (code, workflows, docs) | Clone régulier, fork | `git clone` vers un nouveau dépôt |
| Images GHCR | Persistantes dans GHCR ; backup via `docker save > image.tar` | `docker load < image.tar` puis `docker push` |
| Configuration environnements GitHub | Non exportable nativement, documentée dans docs/ | Recréation manuelle dans Settings → Environments |
| Preuves GitHub Actions | Captures d'écran et liens permanents vers les runs | Archives locales |

Le dépôt Git est la source principale de vérité : il contient le code, les workflows,
la documentation et l'historique complet. Les images GHCR permettent de redéployer
sans avoir à rebuilder depuis les sources. La combinaison des deux couvre la majorité
des scénarios de restauration.

## Deux éléments complémentaires

### Contrôle des vulnérabilités

En production, un scanner comme Trivy ou Grype serait intégré dans le workflow
01-ci.yml après le build de l'image. S'il détecte une CVE critique, le pipeline
s'arrête et l'image n'est pas publiée dans GHCR. Cela évite de déployer une image
exposée à des failles connues, sans alourdir le processus pour les développeurs.

### Validation manuelle avant production

Dans ce projet, l'environnement `production-simulee` est configuré avec une approbation
manuelle obligatoire dans GitHub (Settings → Environments → Required reviewers). Le
workflow 03-promote.yml ne progresse vers le job `promote-production-simulee` qu'après
validation humaine. En production réelle, cette validation serait renforcée par une
checklist formelle, un ticket de changement et une fenêtre de déploiement définie.

<img width="1192" height="623" alt="image" src="https://github.com/user-attachments/assets/3c32f468-7f86-4f2a-b546-96c83cec7926" />

