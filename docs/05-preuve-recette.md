# 05 - Preuve recette simulée

## Workflow de validation recette

- Workflow concerné : 03-promote.yml
- Environnement GitHub : recette
- Tag source validé : latest
- Digest observé : sha256:2fe42ea3b041c63dedb2558dcc5d40dff87935cd1b35e482d78707ed81f884e7
- Lien du run : https://github.com/TEST97440/TP-CICD/actions/runs/28585192882

<img width="1312" height="517" alt="image" src="https://github.com/user-attachments/assets/4f4922d4-7c41-45ee-aa62-763a49630c6a" />


## Résultat

Lors de l'exécution du job `validate-recette` dans le workflow 03-promote.yml :

1. L'image `ghcr.io/test97440/tp-cicd:latest` a été téléchargée depuis GHCR via
   `docker pull`, sans rebuilder l'image.
2. Un conteneur a été démarré sur le port 8083.
3. Le workflow a attendu que le service réponde en boucle (jusqu'à 10 tentatives
   espacées de 2 secondes).
4. Le test HTTP sur `http://127.0.0.1:8083/` a retourné une réponse valide.
5. Le test sur `http://127.0.0.1:8083/version.json` a retourné le contenu JSON attendu.
6. Le digest de l'image a été affiché dans le résumé du job pour confirmer l'identité
   de l'artefact testé.
7. Le conteneur a été supprimé en fin de job via le step nettoyage (`if: always()`).

La validation recette s'est terminée avec succès, ce qui a débloqué le job suivant
`promote-production-simulee`.

<img width="1442" height="602" alt="image" src="https://github.com/user-attachments/assets/01737737-e897-4051-9e69-007b1ea70a75" />

<img width="1395" height="96" alt="image" src="https://github.com/user-attachments/assets/dbbc313f-96e8-4c67-9f1b-60e4bf127180" />

