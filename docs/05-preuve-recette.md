# 05 - Preuve recette simulée

## Workflow de validation recette

- Workflow concerné : 03-promote.yml
- Environnement GitHub : recette
- Tag source validé : latest
- Digest observé : sha256:5354a619e3a8eb29e1b228f8932498e13c7f8b161e4cebb7de860d955312b9d4
- Lien du run : https://github.com/TEST97440/TP-CICD/actions/runs/28609517968

<img width="1265" height="540" alt="image" src="https://github.com/user-attachments/assets/5c085b1a-e9d4-4ed0-9d9d-712d238bcfc5" />


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

<img width="906" height="583" alt="image" src="https://github.com/user-attachments/assets/c59c2fad-bc8f-47c0-9ef6-3c9c1a049dbe" />


<img width="1385" height="98" alt="image" src="https://github.com/user-attachments/assets/64affb7d-6ba0-4a5e-ba01-702654eb64fd" />

