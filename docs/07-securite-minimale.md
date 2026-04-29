# 07 - Sécurité minimale

## Permissions GitHub Actions

Indiquer les permissions utilisées dans les workflows et expliquer pourquoi elles sont limitées.

- 01-ci.yml : contents: read
- 02-publish-ghcr.yml : contents: read, packages: write
- 03-promote.yml : contents: read, packages: write

## Gestion des secrets

Expliquer pourquoi aucun secret ne doit être stocké dans le code.

Expliquer l'usage du GITHUB_TOKEN dans ce projet.

Indiquer quels éléments devraient être placés dans GitHub Secrets ou dans un coffre de secrets en production réelle.

## Rollback

Expliquer comment revenir à une version précédente à partir d'un tag, d'un digest ou de la promotion d'une image antérieure.

## Sauvegarde / restauration

Expliquer ce qu'il faudrait sauvegarder et comment restaurer : dépôt GitHub, workflows, documentation, images publiées, configuration, preuves et éléments nécessaires à la reprise.

## Deux éléments complémentaires

Choisir et expliquer au moins deux éléments parmi : répartition de charge, supervision, haute disponibilité, registre d'images maîtrisé, gestion des accès, journalisation, contrôle des vulnérabilités, politique de déploiement, validation manuelle avant production, séparation stricte des environnements.
