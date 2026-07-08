# Home Sweet Home — Serveur local

Serveur Dart (`shelf`) : authentification email/mot de passe + liste de courses
temps réel (WebSocket), persistée en SQLite. Source de vérité serveur pour le
partage multi-membres ; l'app reste offline-first (sync additive).

## Lancer

```bash
dart pub get
dart run bin/server.dart
```

Variables d'environnement (optionnelles) :

| Var              | Défaut                 | Rôle                                  |
|------------------|------------------------|---------------------------------------|
| `HSH_PORT`       | `8080`                 | Port d'écoute                         |
| `HSH_JWT_SECRET` | `dev-secret-change-me` | Secret JWT (**à fixer** hors dev)     |
| `HSH_DB_PATH`    | `home_sweet_home.db`   | Fichier SQLite                        |

Le serveur écoute sur `0.0.0.0` : depuis un téléphone du même réseau, viser
`http://<ip-machine>:8080`.

## API

| Méthode | Route             | Auth | Rôle                                        |
|---------|-------------------|------|---------------------------------------------|
| POST    | `/auth/register`  | non  | `{email, password, displayName, joinCode?}` |
| POST    | `/auth/login`     | non  | `{email, password}`                         |
| GET     | `/auth/me`        | oui  | user + maison courante                      |
| GET     | `/household`      | oui  | maison + membres + code d'invitation        |
| GET     | `/shopping`       | oui  | liste de courses de la maison               |
| PUT     | `/shopping`       | oui  | remplace la liste (LWW)                     |
| WS      | `/realtime?token=`| oui  | sync temps réel de la maison                |

**Rejoindre une maison** : le `joinCode` renvoyé à l'inscription du 1ᵉʳ membre
sert aux suivants (`register` avec `joinCode`) pour partager la même liste.

## Temps réel

Le client publie/reçoit des évènements `{type, payload}`. Un `shopping.sync`
porte l'état complet de la liste : le serveur le persiste (autorité) puis le
rediffuse aux **autres** membres. À la connexion, le serveur pousse la liste
courante au nouvel arrivant.
