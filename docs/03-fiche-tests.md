# 03 - Fiche tests

## Test automatisé GitHub Actions

* Workflow concerné : 01-ci.yml
* Lien vers le run réussi : A compléter
* Ce qui est testé : A compléter
* Résultat : A compléter

## Test local Docker ou Docker Compose

Renseigner l'une des deux situations.

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

Résultat observé : A compléter

### Situation B - Test local impossible

Justification : A compléter

## Simulation de scaling

Si l'environnement le permet :

```bash
docker compose up -d --scale web=2
docker compose ps
```

Résultat observé : A compléter

## Limites de la simulation

Expliquer les limites : absence de vrai load balancer, absence de haute disponibilité, absence de supervision, dépendance à l'environnement local, etc.

