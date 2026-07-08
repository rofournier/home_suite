# 🏠 Home Sweet Home — Brief & Checklist

> Document vivant. Mis à jour à chaque décision du grill.
> Légende : ✅ décidé · 🟡 à trancher · 💡 idée / réserve

---

## 1. Vision
- App de **gamification de la gestion des tâches de la maison**.
- **Flutter**, architecturée en **mini-apps** accessibles depuis un **hub central**.
- Ton chaleureux, « maison de poupées », familial/collaboratif.

## 2. Contrainte de production des assets
- Chaque asset nécessaire → **un prompt prêt pour ChatGPT image**.
- **Générations limitées** → maximiser le nombre d'assets utiles **par prompt** (planches de sprites, sans exagérer).

## 3. Le HUB (écran principal)
- ✅ Vue en **coupe d'une maison, style maison de poupées**, plusieurs pièces, **bien visible**.
- ✅ **Espace libre au-dessus** de la maison → **effets météo** selon la **météo locale**.
- ✅ **En haut à droite en permanence** : icône **soleil / lune / nuages** selon temps + heure, **cliquable** → toggle un **widget météo « Apple-like »** avec **prévisions sur 1 semaine**.
- ✅ **La V1 = uniquement le HUB** (les mini-apps viendront après).
- ✅ Certains **éléments de la maison sont cliquables**. En V1, le tap **ouvre une vraie route** (go_router) vers un **écran placeholder « en construction »** soigné (thème lofi), un par app. Navigation déjà câblée pour la suite.
- ✅ Routes définies : `/shopping` `/house-plan` `/documents` `/paint` `/gallery` `/mirror` `/settings` `/garden`.
- ✅ **Settings = seul écran réellement fonctionnel en V1** (toggle version de maison + localisation météo).
- ✅ Hotspots : **scintillement/reflet au repos** + **rebond+halo au tap** avant le push.

## 4. Rendu & composition (décidé)
- ✅ **Meilleur rendu possible**, en optimisant le nb d'assets par génération.
- ✅ **Maison = 1 génération** par version, en « belle image » complète (objets peints en place → cohérence lumière/perspective garantie).
- ✅ **Hotspots** = zones tappables ; **scintillement / reflet (glint / light-sweep)** dessiné **dans Flutter** (shader + sparkle) → 0 génération en plus pour l'effet.
- 💡 Réserve : **2-3 objets « héros »** sur **1 planche de sprites partagée** (réutilisable entre versions) si on veut qu'un objet bouge physiquement (miroir qui ondule, tableau qui s'incline).
- ✅ **Maison détourée sur fond transparent** → **ciel + météo dynamiques rendus en Flutter derrière** (une seule maison couvre toutes les météos/heures).
- ✅ **Bande d'herbe + petit lopin de terre / potager peint au premier plan** (ancre la maison, pas de « vide »). Sol re-teinté par Flutter selon l'ambiance (nuit/orage).
- ✅ Le lopin de terre = futur **hotspot app Jardin**.

## 4bis. Style anchor (à coller dans CHAQUE prompt)
- ✅ **Esthétique « Lofi Girl » / ChilledCow** : illustration anime cozy, influence Studio Ghibli, semi-réaliste 2D dessinée main.
- Lumière ambiante chaude et douce, palette **désaturée mais chaleureuse**, léger grain/texture, ombres douces, vibe nostalgique « lofi beats to relax/study to ».
- ✅ **Même style pour toutes les versions de maison** (le contenu/la déco varie, jamais le style).

## 5. Cycle jour/nuit & météo
- ✅ Icône météo (soleil/lune/nuages) en haut à droite, dépend du **temps + heure locale**.
- ✅ Toggle → **widget météo Apple-like = UI native Flutter** (carte glassmorphism animée, dynamique, jamais un asset).
- ✅ **Indicateur du coin (soleil/lune/nuage) = icônes vectorielles dessinées en Flutter** (crisp, animables, 0 génération).
- ✅ **Gros soleil/lune du CIEL (effet de fond)** = version **peinte lofi sur la planche nuages** (même génération, coût nul) pour un rendu riche.
- ✅ **Effets météo animés** au-dessus/autour de la maison selon météo locale.
- ✅ **Open-Meteo** (gratuit, sans clé) : codes météo WMO, prévisions 7 jours, températures, **lever/coucher soleil** → jour/nuit.
- ✅ **Géoloc GPS** (permission demandée proprement) + **repli sur ville saisie manuellement**.
- ✅ **Nuages** et **vent** = **assets générés par ChatGPT** (planches de sprites, plusieurs formes/variantes par prompt), animés en Flutter (parallaxe, dérive, rafales).
- ✅ **Palette d'effets riche complète** : clair jour (soleil+rayons), clair nuit (lune+étoiles), peu nuageux, couvert, **vent** (rafales+feuilles), pluie (+gouttes sur vitre), neige, brouillard (voile), orage (nuages sombres + **éclairs**).
- ✅ **Nuages + vent = assets générés** ; pluie/neige/étoiles/brouillard/éclairs = **particules/overlays Flutter**.
- ✅ Vitesse de dérive des nuages **proportionnelle au vent réel** (Open-Meteo windspeed).

## 5bis. App 🛒 Liste de courses collaborative (grill ✅ — 1ʳᵉ mini-app)
- ✅ **Modèle d'édition = rows structurées, feeling bloc-note.** Chaque item = une row (checkbox + `TextField` inline).
  - Tap sur le **texte** = curseur à la position tapée. Tap sur la **checkbox** = coché.
  - **Entrée** au milieu/fin d'une ligne = **split** à la position du curseur → nouvelle row dessous (le texte après le curseur descend). Seul geste d'insertion.
  - **Backspace** en début de ligne vide = fusionne/supprime la row (réflexe éditeur).
- ✅ **Onglets = catégories créées par l'utilisateur** (créer/renommer/supprimer/**réordonner par drag**), onglet `+`. Seed **2-3 onglets** par défaut. Un item vit dans un onglet.
- ✅ **Acheté** = coché → **reste en place, texte barré (trait crayon) + grisé**. Décochable. Bouton **« Nettoyer les achetés (n) »** vide manuellement.
- ✅ **Supprimer** = **swipe** sur la row (SnackBar « Annuler ») **+ Backspace ligne vide**.
- ✅ **Pas de champ quantité structuré** — quantité écrite librement dans le texte (« Tomates 1kg »).
- ✅ **Pas de drag-reorder d'items** en V1 (ordre = insertion via Entrée). Réordonnancement = réserve.
- ✅ **Look = papier ligné lofi crème texturé + typo manuscrite** (Google Fonts, ex. Caveat/Patrick Hand) pour le texte des items ; chrome (onglets/titres) en typo app. Barré = trait crayon. **0 asset généré** (tout dessiné Flutter). Repli typo app si gros text-scaling (accessibilité, contraste ≥4.5:1).
- ✅ **Temps réel = plomberie complète, invisible en prod solo V1.** Mutations → `RealtimeEvent` publié via `realtimeServiceProvider` ; UI branchée sur `.events`. Impl no-op → aucun événement avant serveur. Validé par **tests widget** (flux d'events injecté), pas de démo user-facing.
- ✅ **Notif in-app** (écran Courses) sur event : **badge « nouveau » sur l'onglet** (persiste jusqu'à ouverture) + **bannière lofi brève** (~3s, tap → onglet) + **surbrillance douce de la row** à l'insertion.
- ✅ **Notif dopamine HUB** : sur le hotspot Courses (frigo/panier cuisine), **badge compteur** (pastille chaude) + **halo/pulse plus chaud & rythmé** que le glint normal, tant qu'il y a des items non-vus. Tap → `/shopping` + **reset compteur**.
- ✅ **Persistance = JSON dans `shared_preferences`** derrière `ShoppingRepository` (interface `domain`, impl `data`), local = source de vérité. Modèles **freezed sérialisables** (futurs DTO).
- ✅ **Item** : `id, text, bought, createdBy, createdAt, position`. `createdBy` alimente la notif.
- ✅ **Bootstrap household** : premier usage réel de `Household`/`Member` — household solo persistant (1 membre « Moi ») fournit `householdId` + `currentMember`. `connect(householdId)` câblé.
- ✅ Route `/shopping` : remplace le placeholder par le vrai `ShoppingScreen`.

## 6. Les mini-apps (à garder en tête pour les objets reconnaissables sur la maison)
1. 🛒 **Liste de courses collaborative** ✅ **implémentée** (voir §5bis)
2. 🗺️ **Plan interactif customisé de la maison** (assigner des tâches par pièce)
3. 📄 **Documents** (partage de documents / papiers)
4. 🎨 **Paint**
5. 🖼️ **Galerie** (objet cliquable = **un tableau**) pour visualiser les dessins
6. ⚙️ **Settings** (dont **toggle de la version de maison**)
7. 🪞 **Miroir interactif**
8. 🌱 **Jardin** (nouveau — via le lopin de terre)

## 7. Versions de maison
- ✅ **Toggleables dans les Settings** (mécanisme codé, extensible sans refacto).
- ✅ **V1 = 2 versions**, même style lofi, même mapping des 8 objets :
  1. **Cosy lofi** (l'originale).
  2. **Riad marocain** (patio central, zellige, fontaine ; le « jardin » = **jardin de patio / fontaine**).

## 8. Process
- ✅ Skill **grill-me** installé, grill en cours **avant** le plan V1.
- ✅ Skill **/ui-ux-pro-max** utilisé pour le front (à activer sur la partie UI chrome / widget météo).

---

## 10. Plan de la maison (V1) — LOCKÉ
- ✅ **Coupe dollhouse, 2 étages + grenier cosy + potager devant**, portrait 2:3 (1024×1536).
- ✅ **Rez** : Cuisine (frigo + liste = 🛒 Courses) · Salon (tableau encadré = 🖼️ Galerie) · Entrée/hall (plan encadré = 🗺️ Plan + thermostat/panneau = ⚙️ Settings).
- ✅ **Étage** : Bureau (classeur/dossiers = 📄 Documents) · Atelier (chevalet + palette = 🎨 Paint) · Salle de bain (miroir = 🪞 Miroir).
- ✅ **Grenier** : déco cosy (pas d'app en V1, réserve).
- ✅ **Devant** : potager (= 🌱 Jardin).
- ✅ **Règle d'or** : maison **assez grande pour cliquer sans zoomer** → objets peints en grand, **hotspots généreux** (≥ confortable au doigt), pièces bien cohérentes, 8 objets max.

## 10bis. Serveur & archi (server-ready léger — pas implémenté en V1)
- ✅ Anticipé : **plusieurs users par maison (Household partagé)** + **temps réel via sockets**.
- ✅ **Feature-first** + couches `domain` / `data` / `presentation`.
- ✅ **Repositories derrière interfaces** (impl locale V1 → remote plus tard, additif).
- ✅ **Modèles freezed sérialisables JSON** = futurs DTO serveur.
- ✅ **`Household(id, members[])`** modélisé dès la V1 (même en solo).
- ✅ **`RealtimeService` no-op** en V1, impl WebSocket ensuite ; zéro logique socket dans l'UI.
- ✅ **Offline-first** : local = source de vérité.
- ✅ Règles figées dans `CLAUDE.md`.

## 11. Build & test
- ✅ Cible de test : **émulateur Android** (à lancer par Claude pour les tests).
- ✅ Livrable installable : **APK release** buildée pour installation sur smartphone physique.
- 🟡 Vérifier l'environnement Flutter (SDK, `flutter doctor`, émulateur dispo) au démarrage de l'implémentation.

## 9. Assets à générer (liste FINALE V1) — 4 générations
- [ ] **Maison A — Cosy lofi** — 1 gen, détourée (fond transparent), 2 étages + grenier + potager, 8 objets peints en grand.
- [ ] **Maison B — Riad marocain** — 1 gen, détourée, même plan/mapping, déco riad (patio, zellige, fontaine).
- [ ] **Planche nuages + célestes** — 1 gen, fond transparent : cumulus → gros nuages d'orage (plusieurs densités) + **soleil peint lofi** + **lune peinte lofi**.
- [ ] **Planche vent** — 1 gen, fond transparent : rafales / traînées de vent + feuilles & pétales emportés (plusieurs variantes).
- ✅ Indicateur coin (soleil/lune/nuage) = **vectoriel Flutter**, pas de génération.
- 💡 (réserve, non V1) Planche objets « héros » animables.

## Décisions résolues
- [x] Architecture de rendu (belle image + hotspots animés en Flutter, réserve sprite sheet)
- [x] Fond détouré + ciel dynamique + sol/potager peint

## Décisions résolues (grill complet ✅)
- [x] Architecture de rendu (belle image + hotspots animés en Flutter)
- [x] Fond détouré + ciel dynamique + sol/potager peint
- [x] Style : **Lofi Girl / ChilledCow**, identique toutes versions
- [x] Ratio 2:3 (1024×1536), maison assez grande (pas de zoom)
- [x] Plan maison 2 étages + grenier + potager, mapping 8 objets
- [x] Météo : **Open-Meteo + GPS (repli ville)**
- [x] Effets météo : **set riche complet**, nuages+vent générés
- [x] Widget = **UI native Flutter glass** ; indicateur coin = **vectoriel**
- [x] Tap V1 = **écrans placeholder par app** (go_router câblé)
- [x] State = **Riverpod** ; stack figée
- [x] **2 versions** maison V1 : Cosy lofi + Riad marocain
