# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : 03-promote.yml
- Environnement GitHub : production-simulee
- Tag source : latest
- Tag cible : production-simulee
- Lien du run : https://github.com/TEST97440/TP-CICD/actions/runs/XXXXXXXXX

📸 [Capture du job promote-production-simulee avec les steps réussis]
📸 [Capture de la page GHCR montrant le tag production-simulee apparu]

## Point essentiel

La promotion réutilise une image existante déjà publiée dans GHCR. Elle ne reconstruit
pas l'image. Le digest reste identique entre le tag source et le tag cible, ce qui
garantit que l'artefact déployé en production-simulee est exactement celui qui a été
validé en recette.

## Preuve

Le job `promote-production-simulee` a exécuté trois commandes uniquement, sans aucun
`docker build` :

```bash
# Téléchargement de l'image source depuis GHCR
docker pull ghcr.io/test97440/tp-cicd:latest

# Création du nouveau tag pointant vers le même artefact
docker tag ghcr.io/test97440/tp-cicd:latest \
           ghcr.io/test97440/tp-cicd:production-simulee

# Publication du nouveau tag dans GHCR
docker push ghcr.io/test97440/tp-cicd:production-simulee
```

Après la promotion, les tags `latest` et `production-simulee` pointent vers le même
digest sha256:2fe42ea3b041c63dedb2558dcc5d40dff87935cd1b35e482d78707ed81f884e7.
Aucune recompilation, aucun rebuild : ce qui a été testé est exactement ce qui est
en production-simulee.