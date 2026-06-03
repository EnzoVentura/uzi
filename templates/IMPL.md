---
status: completed       # completed | failed | partial
branche: ""             # feat/eci-XXXX--slug
fichiers_modifies: []
tests_ajoutes: []
tsc: green              # green | red
---

# IMPL — `<slug>`

## Ce qui a été fait

_(résumé par tâche, en regard du découpage d'ARCHI.md)_

## Décisions clés

- _(choix de nommage, de pattern, de placement de la logique)_

## Déviations vs ARCHI.md

- _(toute déviation + justification ; "aucune" si conforme)_

## Vérifications lancées

- `npx nx test <app> --testPathPattern="…"` → _(vert)_
- `npx tsc --noEmit` → _(vert)_
- `craft-review` → _(findings traités)_

## Commits

- `feat(ECI-XXXX): …` _(sur la branche)_

<!-- UZI_IMPL_DONE -->
