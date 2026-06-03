---
name: uzi-local-skills
description: "Résolution des skills locaux du repo cible pour briefer les personas uzi. Détecte les skills présents (btoc-* ou autres), les mappe aux rôles, et définit le fallback générique si absents. À invoquer par Jack au pré-check d'une mission."
---

# uzi-local-skills — résolution des capacités locales

uzi ne contient **aucune** règle métier. Les personas s'appuient sur les skills
**du repo courant**. Ce skill détecte ce qui est disponible et prépare le brief.

## Détection (au pré-check)

```bash
# Skills locaux du repo
ls -1 .claude/skills/ 2>/dev/null
# Agent reviewer local éventuel
ls -1 .claude/agents/ 2>/dev/null
# Conventions
ls .claude/checklist-review.md CLAUDE.md 2>/dev/null
```

## Mapping rôle → skills (cas btoc-frontend)

| Rôle | Skills locaux attendus |
|---|---|
| Paul (PO) | `btoc-ticket` (Jira) |
| Aurélien (Dev) | `btoc-composant`, `btoc-hook`, `btoc-test`, `btoc-refacto`, `debug`, `btoc-run` |
| Valentin (QA) | `btoc-run` (ports) ; MCP Playwright |
| Ship | `pr`, `ship`, `btoc-create-pr` |
| Tous | `CLAUDE.md` racine + `apps/*/CLAUDE.md` |

## Fallback générique (repo sans skills `btoc-*`)

Si un skill local attendu est **absent**, le persona bascule sur l'outillage global :

| Manque | Fallback |
|---|---|
| `btoc-composant`/`btoc-hook`/`btoc-test` | agent `crafter` + rules `craft.md` / `react-patterns.md` |
| `craft-review` indispo | rules `craft.md` + `react-patterns.md` lues directement |
| pas de stratégie de test | skill `test-strategy` |
| `btoc-ticket` absent | Paul part de la description brute |

## Décision de mode (à consigner dans `STATE.md`)

Au pré-check, Jack tranche **un mode** selon ce qui est détecté :

- **Mode projet** (ex. btoc) : ≥ 1 skill `<prefix>-*` métier détecté (`btoc-composant`,
  `btoc-ticket`…). Les personas délèguent à ces skills ; Edgar lit le `CLAUDE.md` du repo
  pour les conventions ; le reviewer local éventuel est ignoré (on garde les 3 chasseurs).
- **Mode générique** (repo non outillé) : aucun skill métier détecté. uzi tourne quand
  même :
  - **Paul** part de la description / du ticket brut (pas de `btoc-ticket`).
  - **Théo** lit le `CLAUDE.md` du repo (quel qu'il soit) + explore le code pour les
    conventions ; s'il n'y a pas de `CLAUDE.md`, il infère les conventions du code voisin.
  - **Aurélien** code via l'agent `crafter` + rules globales `craft.md`/`react-patterns.md` ;
    lance les tests avec la commande détectée (`npm test`/`vitest`/`jest`/`nx test`…) et
    `tsc` ; stratégie de tests via `test-strategy` si besoin.
  - **Valentin** : QA navigateur seulement si une app web + un MCP navigateur sont
    présents ; sinon il le signale et la mission se contente des tests.
  - **Bastien/Edgar/Yugo** sont **déjà agnostiques** (diff / repo+CLAUDE.md / rules craft)
    — Yugo devient l'angle craft principal puisqu'il n'y a pas de checklist projet.

Jack écrit le mode retenu et la liste détectée/fallbacks dans `STATE.md → Décisions`.

## Sortie

Jack consigne dans `STATE.md → Décisions autonomes` la liste des skills **détectés** et
des **fallbacks** activés, puis brieffe chaque persona avec les noms de skills à utiliser.
Si rien de pertinent n'est trouvé, il **avertit l'utilisateur** (le repo n'est peut-être
pas outillé) avant de lancer la mission.
