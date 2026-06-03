---
description: Affiche l'état des missions uzi en cours (lecture seule)
argument-hint: "[<slug>]"
---

# /uzi-status

Affiche l'état des missions uzi du repo courant. **Lecture seule** — n'écrit rien, ne
dispatche personne.

## Comportement

1. Lis `.uzi/active.json`. Si absent ou vide → « aucune mission active ».
2. Pour chaque mission active (ou le `<slug>` passé en argument), lis
   `.uzi/<slug>/STATE.md` et affiche, de façon compacte :
   - **mission** : slug, type, ticket, branche ;
   - **phase courante** + statut, et le tableau des phases (✅ done / ⏳ en cours / ⬜ à venir) ;
   - **dernier verdict** de review s'il existe (`REVIEW.md`) et de QA (`QA-REPORT.md`) ;
   - **cycles** consommés / max ;
   - **halts en attente** (section « Halts en attente » de STATE.md) ;
   - les **3 dernières décisions autonomes** loggées.
3. Si des artefacts existent sur disque mais ne sont pas reflétés dans STATE.md, le
   signaler (« incohérence — lance `/uzi-resume` »).

Sortie en quelques lignes scannables, pas de pavé.

$ARGUMENTS
