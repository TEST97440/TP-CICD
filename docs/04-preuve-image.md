# 04 - Preuve image GHCR

## Image publiée

- Nom de l'image : ghcr.io/test97440/tp-cicd
- Tags : sha-cee92d4, latest
- Digest : sha256:2fe42ea3b041c63dedb2558dcc5d40dff87935cd1b35e482d78707ed81f884e7
- Lien GHCR : https://github.com/TEST97440/TP-CICD/pkgs/container/tp-cicd

<img width="1907" height="886" alt="image" src="https://github.com/user-attachments/assets/3efc6e9b-188f-44ca-a053-0dc21474b6e7" />

<img width="1427" height="762" alt="image" src="https://github.com/user-attachments/assets/da132dc1-7bee-4d80-a0e7-a269f72d57bb" />

<img width="1427" height="762" alt="image" src="https://github.com/user-attachments/assets/c84b9377-0be4-4c82-b212-81ece24fdf26" />


## Explication

Le **tag** est un pointeur nommé vers une version de l'image. Il est mutable : on
peut le déplacer pour qu'il pointe vers une autre image. Dans ce projet :
- le tag `sha-cee92d4` est lié au commit Git qui a déclenché le build, il permet
  de retrouver exactement quel code a produit cette image.
- le tag `latest` pointe toujours vers la dernière image publiée sur main.

Le **digest sha256** est une empreinte cryptographique du contenu de l'image. Il est
immuable : deux images avec le même digest sont identiques bit pour bit, quels que
soient les tags associés. On ne peut pas le falsifier ni le modifier.

Ces deux éléments sont utiles pour deux raisons :

**Traçabilité** : en recoupant le tag `sha-cee92d4` avec l'historique Git, on sait
exactement quel commit a produit quelle image, à quelle date et via quel workflow.
Le digest confirme que l'image n'a pas été modifiée depuis sa publication.

**Rollback** : en cas de problème en production, on ne rebuild pas. On identifie
le tag `sha-` de l'ancienne version stable, on le promeut à nouveau vers
`production-simulee` via le workflow 03-promote.yml. Le digest garantit que
l'artefact redéployé est exactement celui qui avait été validé en recette.
