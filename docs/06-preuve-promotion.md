# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : 03-promote.yml
- Environnement GitHub : production-simulee
- Tag source : latest
- Tag cible : production-simulee
- Lien du run : https://github.com/TEST97440/TP-CICD/actions/runs/28585192882

📸 [Capture de l'approbation manuelle promote-production-simulee ]

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
digest sha256:efe803e5319212a4957c9506f17dc56deccbe3c51a5e85a759c4737d3b2261a8.
Aucune recompilation, aucun rebuild : ce qui a été testé est exactement ce qui est
en production-simulee.

<img width="1391" height="178" alt="image" src="https://github.com/user-attachments/assets/503df03a-0510-4c1d-9682-573ee5fa6d34" />
<img width="766" height="337" alt="image" src="https://github.com/user-attachments/assets/0d4ae6d4-14f2-437e-ba81-ee2cbabff743" />

<img width="2172" height="255" alt="ChatGPT Image 2 juil  2026, 15_59_22" src="https://github.com/user-attachments/assets/4c230691-a74b-44ab-b880-c27f37321922" />
