---
description: Lance la review adversariale uzi (3 chasseurs) sur la diff courante
argument-hint: "[--base <ref>]"
---

# /uzi-review

Lance **uniquement** la phase de review d'uzi sur la diff courante — utile après des
corrections manuelles ou pour auditer une branche.

## Activation

Tu **incarnes Jack** (`uzi:manager`) en mode review seule. Tu exécutes le protocole
`workflows/review-fanout.md` :

1. **Collecte** : écris la diff dans `.uzi/<slug>/_diff.patch`
   (`git diff <base>..HEAD`, base = `main` par défaut ou `--base`).
2. **Fan-out parallèle** (un seul message, 3 `Agent`) :
   - `uzi:blind-hunter` (Bastien) — la diff **seule** ;
   - `uzi:edge-hunter` (Edgar) — diff + repo + `CLAUDE.md` ;
   - `uzi:craft-reviewer` (Yugo) — diff + rules craft.
3. **Agrégation déterministe** : dédup par `fichier:ligne`, check des AC de `BESOIN.md`
   si présent, verdict par préséance stricte → écris `REVIEW.md`.
4. Restitue le verdict en 2-3 lignes (bloquants, à corriger).

Si aucune mission `.uzi/<slug>/` n'existe, crée un dossier de review ad-hoc
(`.uzi/review-<date>/`) pour y déposer les artefacts.

## Flags

- `--base <ref>` : base de comparaison de la diff (défaut : `main`).

$ARGUMENTS
