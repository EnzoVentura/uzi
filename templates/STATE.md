---
mission_slug: "<slug>"
type: feature          # feature | bug
status: besoin         # besoin | archi | impl | qa | review | corrections | final | done | escalated
phase_courante: po     # po | tech-lead | dev | qa | review | ship
mode: solo             # solo (Agent + Workflow) | team (Agent Teams, --team)
ticket: ""             # ECI-XXXX si applicable, sinon vide
branche: ""            # feat/eci-XXXX--slug | fix/eci-XXXX--slug
started_at: "<ISO8601>"
plugin_version: "0.1.0"
cycles:
  max: 2
  consommes: 0
---

# STATE — mission `<slug>`

## Résumé

| Champ | Valeur |
|---|---|
| Description | _(une phrase)_ |
| Type | feature / bug |
| Ticket | `ECI-XXXX` _(si applicable)_ |
| Branche | `feat/eci-XXXX--slug` |
| Mode | solo / team |
| Casting actif | Jack, Paul, Théo, Aurélien, Valentin, Bastien, Edgar, Yugo |

## Phases

| Phase | Persona | Artefact | Statut | Horodatage |
|---|---|---|---|---|
| Besoin | Paul (PO) | `BESOIN.md` | _pending_ | |
| Archi | Théo (Tech Lead) | `ARCHI.md` | _pending_ | |
| Impl | Aurélien (Dev) | `IMPL.md` | _pending_ | |
| QA | Valentin (QA) | `QA-REPORT.md` | _pending_ | |
| Review | Bastien ‖ Edgar ‖ Yugo | `REVIEW.md` | _pending_ | |
| Ship | Jack (Manager) | PR draft | _pending_ | |

_Statuts possibles : pending | in_progress | done | changes_requested | escalated._

## Décisions autonomes

_Log horodaté des décisions prises seul par Jack (TPM-style). Une ligne par décision._

- `[<ISO8601>]` — Mission créée, dispatch de Paul (PO).

## Halts en attente

_Validations utilisateur en attente. Vide quand la mission avance nominalement._

## Findings différés

_Findings non bloquants reportés par l'utilisateur. Rappelés avant le ship._
