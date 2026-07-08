# Home Sweet Home — Instructions projet

App Flutter de gamification des tâches ménagères. Hub = coupe de maison (dollhouse), style **Lofi Girl**. Détails produit : `docs/BRIEF.md`.

## Communication
- **Français, concis, strict nécessaire.** Pas de remplissage, pas de re-résumé de ce qui est déjà dit. Économiser les tokens.
- Une question seulement si elle est bloquante ; sinon appliquer le défaut raisonnable et l'indiquer.

## Code — principes
- Dart/Flutter idiomatique, `flutter_lints` actif, **zéro warning** (`flutter analyze` propre = condition de fin de tâche).
- **Fonctions courtes** (~≤30 lignes), une seule responsabilité, early-return, nesting minimal.
- Nommage explicite. Zéro code mort. Commenter le **pourquoi**, jamais le quoi.
- **Immutabilité par défaut** (freezed), `const` partout où possible.
- Pas d'abstraction prématurée — **sauf** les coutures « server-ready » ci-dessous, qui sont volontaires.

## Architecture (server-ready léger, décidé V1)
Le serveur (multi-users par maison + temps réel sockets) n'est PAS implémenté en V1, mais l'archi est prête.
- **Feature-first**, 3 couches par feature :
  - `domain/` — models (freezed, **sérialisables JSON** = futurs DTO), interfaces de repository.
  - `data/` — implémentations repo + datasources (en V1 : local / Open-Meteo).
  - `presentation/` — widgets + providers Riverpod.
- **Les widgets ne parlent jamais à une API/DB en direct** → toujours via un repository (interface `domain`, impl `data`).
- **`Household(id, members[])`** modélisé même en solo, pour rendre le multi-user naturel.
- **`RealtimeService`** = interface abstraite, **impl no-op en V1**, impl WebSocket plus tard. Aucune logique socket dans l'UI.
- **Offline-first** : le local est la source de vérité ; le serveur synchronisera (ajout non destructif).

## Flutter
- `go_router` pour **toute** navigation (pas de `Navigator.push` ad hoc). Routes centralisées.
- Thème centralisé : **tokens** couleur/typo/espacement. **Jamais de hex en dur** dans un widget.
- `const` constructors, providers Riverpod ciblés, éviter les rebuilds inutiles.
- Assets sous `assets/`, déclarés dans `pubspec.yaml`, nommage `snake_case` cohérent.
- État async (météo) via `AsyncNotifier`/`FutureProvider` ; gérer explicitement loading / error / data.

## UI/UX (rappels non négociables)
- Cibles tactiles **≥48dp**, espacement **≥8dp**, feedback au tap **<150ms**.
- Contraste texte **≥4.5:1**. Supporter **reduced-motion** et le **text scaling** sans casser le layout.
- **Icônes vectorielles** (pas d'emoji comme icône structurelle). Respecter les **safe areas**.
- Un seul CTA primaire par écran ; animations 150–300ms, exit plus court que enter.

## Tests & vérif
- Couvrir par **tests unitaires** la logique métier : mapping code météo → effet, calcul jour/nuit, hit-testing des hotspots, sélection de version de maison.
- Vérifier sur **émulateur Android** ; livrable = **APK release** installable.
