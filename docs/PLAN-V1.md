# 🗂️ Plan V1 — le HUB

Objectif V1 : **le hub seul**, magnifique et vivant (météo réelle + jour/nuit + effets + hotspots cliquables vers placeholders). Archi **server-ready léger** (voir `CLAUDE.md`).

## Arborescence (feature-first, 3 couches)
```
lib/
  main.dart
  app/
    app.dart            # MaterialApp.router + thème
    router.dart         # go_router : toutes les routes
    theme.dart          # ThemeData depuis les tokens
    theme_tokens.dart   # couleurs/typo/espacement (jour+nuit)
  core/
    realtime/realtime_service.dart   # interface + NoopRealtimeService (V1)
    result.dart / failures.dart / extensions/
  features/
    household/domain/   # Household(id, members[]), Member/User  (freezed, JSON) — solo V1
    weather/
      domain/           # Weather, DailyForecast, WeatherCode→WeatherEffect, DayNight
      data/             # open_meteo_datasource, weather_repository_impl
      presentation/     # weather_indicator, weather_card, weather_providers
    location/
      domain/ data/     # geolocator + repli ville, persistance
    house/
      domain/           # HouseVersion, Hotspot(normCoords, AppTarget)
      data/             # house_repository (local, liste des versions)
      presentation/     # house_view, hotspot_widget, sky_painter, weather_fx
    settings/
      domain/ data/ presentation/   # version maison + localisation (persist)
    placeholder/presentation/        # UnderConstructionScreen partagé
  shared/
    widgets/  animations/ (glint, halo, glass_card)  fx/ (rain, snow, fog, lightning painters)
assets/
  houses/  cosy.png  riad.png
  weather/ clouds/*  wind/*
```

## Routes (go_router)
`/` (hub) · `/shopping` · `/house-plan` · `/documents` · `/paint` · `/gallery` · `/mirror` · `/garden` · `/settings`
→ toutes sauf `/` et `/settings` = `UnderConstructionScreen` en V1.

## Dépendances
`flutter_riverpod` · `go_router` · `freezed`/`json_serializable` (+build_runner) · `shared_preferences` · `geolocator` · `geocoding` · `http` · `flutter_lints`.

## Jalons
1. **Init** : projet Flutter, pubspec + deps, `analysis_options` (flutter_lints), tokens + thème (jour/nuit).
2. **Core** : `Household`/`Member` (freezed+JSON), `RealtimeService` no-op, router + toutes les routes, `UnderConstructionScreen`.
3. **Weather** : models + `WeatherCode→effect`, datasource Open-Meteo, repository, `AsyncNotifier` ; géoloc + repli ville ; calcul jour/nuit (sunrise/sunset).
4. **Hub visuel** : `SkyPainter` (dégradé dynamique + étoiles) → `WeatherFx` (nuages/vent en sprites + pluie/neige/brouillard/éclairs en painters) → image maison + overlay hotspots (glint/tap).
5. **Météo UI** : indicateur coin + carte glass 7 jours (toggle animé).
6. **Settings** : toggle version maison (persist) + localisation.
7. **Polish** : reduced-motion, haptics, safe areas, `flutter analyze` propre, tests unitaires (mapping météo, jour/nuit, hit-testing, version).
8. **Livraison** : run sur **émulateur Android**, build **APK release**.

## Notes
- Coords hotspots en **normalisé** (0–1) → indépendantes de la résolution ; un jeu par version (Cosy/Riad très proches).
- Les PNG maison/nuages/vent sont livrés par génération ChatGPT (voir `ASSET-PROMPTS.md`) ; on peut coder avec des placeholders en attendant.
- Vérifier l'env : `flutter doctor` + émulateur dispo au jalon 1.
