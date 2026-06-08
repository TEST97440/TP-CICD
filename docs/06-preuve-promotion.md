# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : 03-promote.yml
- Environnement GitHub : production-simulee
- Tag source : latest
- Tag cible : production-simulee
- Lien du run : A compléter

## Point essentiel

La promotion doit réutiliser une image existante. Elle ne doit pas reconstruire l'image.

## Preuve

l'image a été docker pull puis docker tag puis docker push, pas de docker build
