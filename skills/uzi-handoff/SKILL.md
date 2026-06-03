---
name: uzi-handoff
description: "Contrat de passation entre personas uzi : format d'INPUT/OUTPUT par phase, marqueurs de fin, et verrou de complétude que Jack applique avant chaque passation. À invoquer pour savoir ce qu'un persona reçoit, ce qu'il produit, et comment Jack valide qu'une phase est terminée."
---

# uzi-handoff — contrat de passation

La coordination uzi passe par des **fichiers `.uzi/`**, pas par de la conversation.
Chaque persona lit les artefacts amont et écrit le sien.

## Table des passations

| Phase | Persona | INPUT (lit) | OUTPUT (écrit) | Marqueur de fin |
|---|---|---|---|---|
| Besoin | Paul (po) | desc + `ECI-XXXX` | `BESOIN.md` | `<!-- UZI_BESOIN_DONE -->` |
| Archi | Théo (tech-lead) | `BESOIN.md` | `ARCHI.md` | `<!-- UZI_ARCHI_DONE -->` |
| Impl | Aurélien (dev) | `BESOIN.md` + `ARCHI.md` (+ findings) | `IMPL.md` + commits | `<!-- UZI_IMPL_DONE -->` |
| QA | Valentin (qa) | `BESOIN.md` + `IMPL.md` | `QA-REPORT.md` | `<!-- UZI_QA_DONE -->` |
| Review (fan-out) | Bastien / Edgar / Yugo | diff (asymétrie) | `REVIEW-blind/edge/craft.md` | `<!-- UZI_REVIEW_BLIND_DONE -->` / `…_EDGE_DONE` / `…_CRAFT_DONE` |
| Review (agrégat) | Jack | les 3 `REVIEW-*.md` | `REVIEW.md` | `<!-- UZI_REVIEW_AGG_DONE -->` |

> **Marqueurs distincts** (fan-out vs agrégat) : chaque chasseur termine SON fichier par
> son marqueur d'angle ; Jack termine l'agrégat par `UZI_REVIEW_AGG_DONE`. Ainsi un crash
> entre fan-out et agrégation laisse 3 `REVIEW-*.md` complets sans `REVIEW.md`, et
> `/uzi-resume` ne ré-exécute QUE l'agrégation, pas tout le fan-out.

## Verrou de complétude (appliqué par Jack avant chaque passation)

Jack ne considère une phase **terminée** que si les trois conditions sont réunies pour
l'artefact attendu :

1. le **fichier** `.uzi/<slug>/<ARTEFACT>.md` existe sur disque ;
2. son **frontmatter** `status`/`verdict` est **terminal** — valeur appartenant à la
   liste par-artefact ci-dessous (section « Frontmatter attendus »), `failed`/`partial`/
   `CONCERNS`/`FAIL` **compris** ;
3. le **marqueur de fin** correspondant est présent.

Si l'une manque → la phase n'est **pas** finie : Jack relance le persona (retry ×2),
puis escalade.

## Terminé ≠ Réussi (garde-fou)

Le verrou ci-dessus vérifie qu'une phase est **terminée** (forme), pas qu'elle a
**réussi**. Un `IMPL.md` `status: failed`/`partial`, un `tsc: red`, ou un `QA-REPORT.md`
`verdict: FAIL` sont des fins **négatives** : Jack **n'avance pas** — il re-dispatche le
persona avec le diagnostic, ou escalade. Il n'enchaîne sur la phase suivante que sur une
fin **positive** (`completed`+`tsc: green`, `PASS`/`CONCERNS` selon sévérité, `APPROVED`).

## Frontmatter `status` / `verdict` attendus

- `BESOIN.md`, `ARCHI.md` : `status: done`
- `IMPL.md` : `status: completed | failed | partial`
- `QA-REPORT.md` : `verdict: PASS | CONCERNS | FAIL`
- `REVIEW.md` : `verdict: APPROVED | CHANGES_REQUESTED | REJECTED`

## Règles

- Un persona n'écrit **que** son propre artefact, **dans `.uzi/<slug>/`**.
- Les chemins passés entre personas sont **absolus**.
- Le récap conversationnel d'un persona (2-3 lignes) ne remplace **pas** l'artefact :
  c'est le fichier qui fait foi pour le verrou.
