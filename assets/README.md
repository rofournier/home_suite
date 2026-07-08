# Assets générés (ChatGPT Image)

Dépose ici les 4 générations décrites dans `docs/ASSET-PROMPTS.md`, en PNG
**fond transparent**, aux emplacements suivants :

```
assets/
  houses/
    bg_cosy.png   # Maison A — Cosy lofi (1024×1536, ou ×2)
    bg_riad.png   # Maison B — Riad marocain
  weather/
    clouds/  cloud_sm_01 cloud_sm_02 cloud_md_01 cloud_md_02
             cloud_lg_01 cloud_storm_01 cloud_storm_02   (~360–700 px)
    sky/     sun.png  moon.png                            (~320 px)
    wind/    gust_01 gust_02 gust_03                      (~360×180)
             leaves_01 leaves_02  petals_01 petals_02     (~240 px)
```

Tailles = bounding box serrée, fond transparent (×2 possible pour du net).

Tant que les PNG ne sont pas là, le hub tourne avec des placeholders (silhouette
de maison + ciel/effets dessinés en Flutter). Il suffira de déposer les fichiers
et de les déclarer dans `pubspec.yaml` (section `flutter/assets`).
