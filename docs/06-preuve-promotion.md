# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : 03-promote.yml
- Environnement GitHub : production-simulee
- Tag source : latest
- Tag cible : production-simulee
- Lien du run : https://github.com/TEST97440/TP-CICD/actions/runs/28609517968

<img width="1637" height="961" alt="image" src="https://github.com/user-attachments/assets/555a7da2-0e3c-42cd-bd3e-845241c5e801" />


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
digest sha256:5354a619e3a8eb29e1b228f8932498e13c7f8b161e4cebb7de860d955312b9d4
Aucune recompilation, aucun rebuild : ce qui a été testé est exactement ce qui est
en production-simulee.

<img width="1382" height="370" alt="image" src="https://github.com/user-attachments/assets/d3b3a01a-06ac-4554-b164-39a2d676872c" />

<img width="1372" height="332" alt="image" src="https://github.com/user-attachments/assets/bf4f8f45-ffa2-47a7-8903-4f54ee6aa267" />

<img width="2170" height="255" alt="image" src="https://github.com/user-attachments/assets/a6f60386-9e3f-4103-82b3-4a706437ec3d" />

