# 🎨 Design System — Home Sweet Home (front V1)

Style : **Lofi Girl / ChilledCow** + chrome **soft-clay / glass** (radii généreux, spring, haptics). Cadré via ui-ux-pro-max.

## Tokens couleur (warm lofi)
Jamais de hex en dur dans un widget → passer par le thème.

### Base / chrome (jour)
| Token | Hex | Usage |
|---|---|---|
| `cream` | `#F3E9DC` | fond des écrans (placeholder, settings) |
| `sand` | `#E7D6C1` | surfaces muted, séparateurs |
| `terracotta` | `#C97B5A` | **primary** (CTA, actif) |
| `amber` | `#E9A96B` | chaleur / soleil / highlight |
| `sage` | `#8FA98C` | accent nature (jardin) |
| `ink` | `#33291F` | texte principal (≥4.5:1 sur cream) |
| `ink-soft` | `#6E5F52` | texte secondaire |

### Nuit (variante quand `isNight`)
| Token | Hex |
|---|---|
| `night-base` | `#241F30` |
| `night-surface` | `rgba(40,34,52,.55)` (glass) |
| `moon-gold` | `#E8C98A` (accent) |
| `on-night` | `#F1E7D9` (texte) |

### Ciel dynamique (CustomPainter, dégradé haut→bas)
| Moment / météo | Dégradé |
|---|---|
| Aube | `#F6C9A8 → #B79BC0` |
| Jour clair | `#AFD4E6 → #EAF1EA` |
| Coucher | `#F3A97C → #6E5A8C` |
| Nuit | `#2B2540 → #4A3F63` + étoiles |
| Couvert | `#B9BEC2 → #D7D3CC` |
| Pluie | `#8A94A0 → #B4B8BC` |

## Typographie
- **Titres/afichage** : `Calistoga` (serif rond chaleureux) — temp géante, titres apps.
- **Corps / UI** : `Inter` (300–700). Chiffres météo en **tabular figures**.
- Échelle : 12 / 14 / 16 / 20 / 28 / 40. Corps 16, line-height 1.5.
- Alt cozy possible : `Nunito` corps si Inter juge trop neutre.

## Effets
- Radii : cartes **28**, boutons **20**, gros conteneurs 40.
- Glass : `BackdropFilter` blur ~18–22, surface translucide + bord `rgba(255,255,255,.25)`, ombre douce.
- Grain léger en overlay global (texture, opacité basse).

## Motion (150–300ms, spring, exit < enter, respecte `reduced-motion`)
| Élément | Animation |
|---|---|
| Hotspot repos | **glint** : balayage de lumière + sparkle toutes ~4–6s, pulse d'opacité |
| Hotspot tap | scale **0.95** spring + **halo** qui s'étend + `HapticFeedback.lightImpact` → push route (~250ms) |
| Widget météo toggle | scale+fade depuis l'origine (coin haut-droit), enter 280 / exit 180ms |
| Nuages | dérive continue, vitesse ∝ vent réel |
| Transition écran | slide/shared-axis 300ms ; reduced-motion → simple fade |

## Specs composants
### 1. Indicateur météo (coin haut-droit, permanent)
- Cible **≥48dp**, safe-area aware. Icône **vectorielle** soleil/lune/nuage (CustomPainter).
- Idle doux : rayons soleil qui tournent lentement / halo lune / nuage qui dérive.
- Tap → toggle la carte. `Semantics(label: 'Météo, <condition>')`.

### 2. Carte météo glass (7 jours, Apple-like)
- `BackdropFilter` + surface jour `rgba(255,250,244,.6)` / nuit `rgba(40,34,52,.55)`, radius 28.
- Haut : **temp actuelle géante** (Calistoga) + condition + max/min.
- Liste 7 lignes : jour · icône · min/max · mini-barre de plage. Chiffres tabular.
- Dismiss : scrim (tap dehors) + swipe up. Anime depuis le coin.

### 3. Hotspot (sur objet de maison)
- Zone invisible **≥48dp** positionnée en **coordonnées normalisées** sur l'image maison (mêmes coords réutilisables entre versions).
- Overlay glint au repos ; scale+halo au tap ; `Semantics(label:'<App>')` ; `onTap → context.push('/route')`.

### 4. Écran placeholder « en construction »
- Thème lofi (cream/night), centré : petite illu/icône d'app + titre (Calistoga) + « Bientôt disponible ».
- Bouton retour doux (`context.pop()`), léger élément flottant. Safe areas.

### 5. Settings (seul écran fonctionnel V1)
- **Version de maison** : cartes/segmented (Cosy lofi / Riad) avec preview → persistée (shared_preferences).
- **Localisation** : switch GPS auto + champ ville manuel (repli).
- Unités °C/°F, section « À propos ». Lignes ≥48dp, feedback au tap.

## Checklist pré-livraison (rappel)
Cibles ≥48dp · contraste ≥4.5:1 (jour ET nuit) · reduced-motion · text scaling · icônes vectorielles · safe areas · scrim modal 40–60%.
