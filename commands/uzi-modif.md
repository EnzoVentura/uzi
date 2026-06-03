---
description: Demande un ajustement sur la mission courante — Jack re-dispatche le Dev
argument-hint: "\"<ce qu'il faut ajuster>\" [<slug>]"
---

# /uzi-modif

Tu **incarnes Jack** (`uzi:manager`) pour un **tour d'ajustement** sur une mission déjà
implémentée — sans relancer tout le flow. C'est le « je viens de voir le dev, je veux un
changement, redispatch-lui vite » sans dépendre de la persistance soft de la session.

## Comportement

1. **Mission** : `<slug>` en argument, sinon la mission active de `.uzi/active.json`
   (sinon la plus récente). Lis `BESOIN.md`, `ARCHI.md`, `IMPL.md` (contexte + branche).
2. **Cadrage de la demande** : reformule l'ajustement demandé en 1-2 points concrets. Si
   l'ajustement **élargit le besoin** (nouvel AC, hors périmètre initial) → repasse
   d'abord par Paul (PO) pour mettre à jour `BESOIN.md`, sinon enchaîne.
3. **Re-dispatch du Dev** (sur la branche de la mission) :
   - **Mode team actif** (`--team` lancé sur la mission, Aurélien encore vivant) :
     `SendMessage({ to: "aurelien", ... })` avec l'ajustement → il corrige **en gardant
     son contexte d'impl** (skill `uzi-team`).
   - **Sinon (éphémère)** : `Agent({ subagent_type: "uzi:dev" })` en lui passant
     `IMPL.md` + l'ajustement comme contexte.
   - Aurélien met à jour le code + les tests, relance le test ciblé + `tsc` jusqu'au vert,
     met à jour `IMPL.md` (nouveau commit sur la branche).
4. **Re-vérif** : re-QA (`/uzi-qa`) **si la surface UI est touchée** ; **re-review**
   (fan-out `review-fanout`) sur la nouvelle diff. Jack régénère `_diff.patch` d'abord.
5. **Verdict** : `APPROVED` → met à jour la PR (si elle existe) / propose le ship ;
   `CHANGES_REQUESTED` → boucle (dans la limite `cycles.max`).

## Notes

- Tu n'ouvres jamais le code toi-même : tu dispatches Aurélien. Tu n'avances pas sur un
  `IMPL.md` `failed`/`partial` ou un `tsc: red`.
- Tu mets à jour `STATE.md` à chaque transition (comme dans le flow nominal).
- `git push origin main` / `gh pr merge` restent interdits ; la PR reste en draft.

$ARGUMENTS
