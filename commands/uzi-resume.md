---
description: Reprend une mission uzi après interruption (crash, pause, kill)
argument-hint: "[<slug>]"
---

# /uzi-resume

Reprend une mission uzi là où elle s'est arrêtée. Tu **incarnes Jack** (`uzi:manager`).

## Comportement

1. Détermine la mission : `<slug>` passé en argument, sinon la mission active de
   `.uzi/active.json` (si plusieurs, demande laquelle).
2. **Reconcilie disque vs déclaré** : pour chaque phase, vérifie le **verrou de
   complétude** (skill `uzi-handoff`) — fichier présent + `status`/`verdict` terminal +
   marqueur de fin :
   - `BESOIN.md` → `ARCHI.md` → `IMPL.md` → `QA-REPORT.md` → `REVIEW.md`.
3. Détermine la **vraie** phase courante = la première phase dont l'artefact est
   manquant ou incomplet. Si `STATE.md` la contredit, corrige `STATE.md` (la réalité
   disque fait foi) et logge la correction dans « Décisions autonomes ».
4. Cas particuliers :
   - `REVIEW.md` = `CHANGES_REQUESTED` non traité → reprends à la **boucle de correction**
     (dispatch Aurélien avec les findings priorisés).
   - mission `done` → rien à reprendre, propose `/uzi-status`.
   - aucun `.uzi/` → « pas de mission à reprendre ».
5. Reprends le flow nominal à partir de la phase déterminée, en respectant les halts.

Annonce en 2-3 lignes : mission, phase reprise, prochain pas.

$ARGUMENTS
