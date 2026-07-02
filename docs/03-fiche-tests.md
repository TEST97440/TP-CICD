# 03 - Fiche tests

## Test automatisé GitHub Actions

- Workflow concerné : 01-ci.yml
- Lien vers le run réussi : https://github.com/TEST97440/TP-CICD/actions (commit 571cdf3)
- Ce qui est testé : Build Docker + test HTTP sur / et /version.json
- Résultat : OK en 18s

<img width="1441" height="301" alt="image" src="https://github.com/user-attachments/assets/8b641748-3e25-4a3d-80e8-45d75707b8f0" />

Le workflow exécute dans l'ordre :
1. Vérification de la présence des fichiers attendus (Dockerfile, compose.yml,
   site/index.html, site/version.json, docs/08-compte-rendu-final.md).
2. Validation de la syntaxe du compose.yml via `docker compose config`.
3. Construction de l'image avec `docker build`.
4. Démarrage d'un conteneur sur le port 8083 et attente de la réponse (jusqu'à
   10 tentatives espacées de 2 secondes).
5. Test HTTP sur / et /version.json avec `curl -fsS`.
6. Vérification que le contenu HTML contient bien "Projet CICD".
7. Nettoyage du conteneur (step `if: always()` pour s'exécuter même en cas d'échec).

## Test local Docker ou Docker Compose

### Situation A - Test réalisé

Commandes utilisées :

```bash
docker build -t projet-cicd-nginx:local .
docker run --rm -p 8083:80 projet-cicd-nginx:local
```

ou :

```bash
docker compose up --build
```

Résultat observé : conteneur Catal-Log actif (ID 4f29de4e31ac), site accessible sur
http://localhost:8083, réponse HTTP 200 sur / et sur /version.json.

Le service tester du compose.yml a également validé les deux URLs automatiquement
en exécutant `curl -fsS http://web/` et `curl -fsS http://web/version.json` depuis
le réseau interne cicd_net, sans passer par l'hôte.


<img width="777" height="592" alt="image" src="https://github.com/user-attachments/assets/d709b68c-e06e-4761-a6d0-818a73ce592a" />

<img width="1470" height="193" alt="image" src="https://github.com/user-attachments/assets/51eef4b5-63ed-44a9-b52c-2d5db0823b96" />


## Simulation de scaling

```bash
docker compose up -d --scale web=2
docker compose ps
```

Résultat observé : deux instances du service web démarrées (tp-cicd-web-1 et
tp-cicd-web-2) sur le réseau cicd_net. Le service tester a pu joindre le nom DNS
web qui pointe vers l'une des deux instances.

Note : le port 8083 ne peut être mappé que sur une seule instance à la fois avec
`ports`. Pour scaler sans conflit de port, il faudrait utiliser `expose` uniquement
et placer un reverse proxy devant les instances.

## Limites de la simulation

- **Pas de load balancer** : Docker Compose ne répartit pas le trafic entre les
  instances sur un même port externe. Une seule instance répond aux requêtes depuis
  l'hôte, les autres ne reçoivent rien.
- **Pas de failover automatique** : si une instance tombe, Docker Compose peut la
  redémarrer via la restart policy mais il n'y a pas de rescheduling intelligent
  comme avec Kubernetes.
- **Mono-hôte** : toutes les instances tournent sur la même machine. Une panne de
  l'hôte entraîne l'arrêt de l'ensemble du service.
- **Pas de gestion d'état distribuée** : si un conteneur redémarre, l'état en mémoire
  est perdu. Une application stateful nécessiterait des volumes persistants et une
  stratégie de réplication.
- **Dépendance à l'environnement local** : la simulation ne reproduit pas les
  contraintes réseau, les règles de sécurité ou la charge réelle d'un environnement
  de production.
