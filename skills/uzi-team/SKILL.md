---
name: uzi-team
description: "Mode --team d'uzi : garde Aurélien (Dev) persistant via Agent Teams pour retenir son contexte d'implémentation entre cycles de correction et entre demandes. Mécanique TeamCreate/SendMessage + dégradation gracieuse vers le dispatch éphémère. À invoquer par Jack quand --team est passé."
---

# uzi-team — Dev persistant (Agent Teams)

**Expérimental, OFF par défaut.** N'a de valeur que pour une mission à plusieurs cycles
ou une session où l'utilisateur enchaîne des ajustements : garder Aurélien **vivant**
évite de reconstruire son contexte d'impl (chemins explorés, pourquoi tel pattern,
pièges écartés) à chaque re-dispatch.

## Ce qui est persistant (et ce qui ne l'est pas)

- **Persistant** : **Aurélien (Dev)** uniquement. C'est lui qui porte du contexte coûteux
  à reconstruire.
- **Éphémère (inchangé)** : les 3 chasseurs de review (Bastien/Edgar/Yugo) restent
  *stateless*, re-spawnés à chaque fan-out ; Paul et Théo (one-shot en amont). Inutile
  et risqué de les mettre en team.

## Mécanique (Jack = team-lead)

> Les primitives Agent Teams (`TeamCreate`, `SendMessage`, `Monitor`, `TaskCreate`) ne
> sont disponibles que si le flag `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` est activé.
> Jack les **charge à la demande** via `ToolSearch` (`select:TeamCreate,SendMessage,Monitor`).
> Si elles restent introuvables → bascule directe en mode solo (pas de `--team`).

1. **Créer la team** : `TeamCreate({ name: "uzi-<slug>" })`.
2. **Spawn Aurélien persistant** : `Agent({ subagent_type: "uzi:dev", team_name:
   "uzi-<slug>", name: "aurelien", run_in_background: true, prompt: <brief impl> })`.
   Il devient adressable par `SendMessage({ to: "aurelien" })`.
3. **Briefs & corrections** : au lieu de re-dispatcher un sous-agent, Jack
   `SendMessage({ to: "aurelien", ... })` avec le brief initial, puis les findings
   priorisés (en boucle de correction) ou une demande d'ajustement (`/uzi-modif`).
4. **Observation** : `Monitor` sur la session d'Aurélien (idle/failed). Jack applique
   toujours le **verrou de complétude** (`uzi-handoff`) sur `IMPL.md` — un `idle` ne vaut
   pas « fini ».
5. **Fin** : à mission terminée **et** utilisateur OK pour clore, `SendMessage` un
   `shutdown_request` puis `TeamDelete`. Si l'utilisateur veut enchaîner des modifs, la
   team **reste vivante** (c'est tout l'intérêt) — `/uzi-modif` réutilise Aurélien chaud.

## Dégradation gracieuse (garde-fou clé)

Agent Teams est expérimental. Si Aurélien est **muet** ou si le verrou de complétude
n'est **pas** atteint après 2 relances (`SendMessage` sans progrès, session `failed`,
idle qui n'avance pas) :
1. Jack **bascule en mode éphémère** : `Agent({ subagent_type: "uzi:dev" })` classique,
   en lui passant `IMPL.md` + les findings comme contexte (reconstruction ~80 %).
2. Il logge la bascule dans `STATE.md → Décisions autonomes`.
3. La mission continue **sans** dépendre de la team. **Aucun chemin critique ne repose
   sur Agent Teams.**

## Quand l'activer

- `--team` **explicite** ET `cycles.max > 1` (sinon aucun gain).
- Ou session « poste de pilotage » où l'utilisateur va demander plusieurs ajustements
  successifs au même Dev.
- Sinon : mode solo (Agent + Workflow), le défaut robuste.

## Ce que Jack ne fait jamais en team

- ❌ Mettre les reviewers ou le PO/Tech Lead en team (one-shot/stateless).
- ❌ Laisser un `idle` court-circuiter le verrou de complétude.
- ❌ Rendre une étape critique dépendante de la team sans fallback éphémère.
