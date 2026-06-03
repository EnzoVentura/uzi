---
apps_touchees: []       # ex: [web, offres]
couches: []             # ex: [composant, hook, service]
risque: faible          # faible | moyen | élevé
status: done
---

# ARCHI — `<slug>`

## Carte de l'existant

_(chemins clés : composants/hooks/services voisins, ce qui est réutilisable — Rule of Three)_

- `apps/.../...` — _(rôle)_

## Découpage en tâches

| # | Tâche | Couche | Fichiers touchés | Contrainte ARCH | Risque |
|---|---|---|---|---|---|
| 1 | … | composant/hook/service | `…` | … | … |

## Garde-fous bloquants (à respecter par Aurélien)

- Couches strictes : composant → hook de feature → store (jamais de saut).
- i18n obligatoire (zéro texte hardcodé), tokens `@btoc/theme` (pas de hex/px en dur).
- React 19 : zéro `useMemo`/`useCallback` ; état dérivable dérivé inline.
- Un composant par fichier ; identifiants métier en français.
- _(garde-fous spécifiques à cette mission)_

## Points de vigilance par plateforme

- _(offres SSR `<ClientOnly>` / btoc-wc Shadow DOM / store-locator `'use client'` / mobile UI native — selon apps touchées)_

<!-- UZI_ARCHI_DONE -->
