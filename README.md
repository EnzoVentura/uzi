# uzi

> Une **équipe d'agents à personas développés** qui livre une feature ou un bug de
> bout en bout, orchestrée depuis **une seule session Claude Code** — sans AoE.

`uzi` est un plugin Claude Code. Il met en scène une petite équipe (Manager, PO, Tech
Lead, Dev, QA, et une escouade de review) qui exécute le flow complet d'une tâche :

> **besoin → compréhension de l'existant → ajout/correction → vérification autonome
> (Playwright) → review interne adversariale → PR avec descriptif.**

Le plugin ne contient **aucune règle métier** : les personas délèguent tout le savoir
technique aux **skills locaux du repo** (sur btoc-frontend : `btoc-composant`,
`btoc-hook`, `btoc-ticket`, `pr`…). C'est ce qui le rend portable : sur un autre repo,
les mêmes personas s'appuient sur les skills de ce repo.

## Le casting

| Persona | Rôle | Ce qu'il fait |
|---|---|---|
| **Jack** | Manager / orchestrateur | Pilote la mission, dispatche, ne code jamais. |
| **Paul** | PO / Analyste du besoin | Cadre le besoin en critères d'acceptation vérifiables. |
| **Théo** | Tech Lead / Architecte | Cartographie l'existant, fixe les garde-fous, découpe. |
| **Aurélien** | Dev / implémenteur | Code (skills btoc), teste, commite sur une branche. |
| **Valentin** | QA | Vérifie l'app réelle via **Playwright** (+ a11y), preuves à l'appui. |
| **Bastien** | Blind Hunter | Review de la **diff seule**, sans aucun contexte. |
| **Edgar** | Edge Case Hunter | Diff + repo + `CLAUDE.md` : cas limites & conventions projet. |
| **Yugo** | Craft Reviewer | `craft.md` / `react-patterns.md` : SRP, immutabilité, React 19. |

## Le flow

```
/uzi-start "ECI-1234: ..." 
  → Paul (BESOIN)      → [HALT]
  → Théo (ARCHI)       → [HALT]
  → Aurélien (IMPL : code + commits branche)
  → Valentin (QA Playwright)
  → review-fanout (Bastien ‖ Edgar ‖ Yugo → REVIEW)
  → APPROVED → [HALT] → PR draft        |  CHANGES_REQUESTED → corrections → re-review
```

Trois **halts** de validation (besoin, découpage, avant PR) ; tout le reste est
autonome. L'état de la mission vit dans `.uzi/<slug>/` (gitignoré).

## Moteur

100 % natif Claude Code, **zéro AoE** :
- **personas = subagents** (`agents/*.md`), dispatchés par Jack via le tool `Agent` ;
- **review = fan-out parallèle** : Jack dispatche les 3 chasseurs en **un seul message**
  (3 `Agent`), asymétrie d'information + agrégation déterministe (protocole
  `workflows/review-fanout.md`). *(Le Workflow tool peut piloter ce fan-out en session
  ultracode, mais le dispatch `Agent` est le défaut, sans dépendance.)*
- **Agent Teams** (expérimental) en option `--team` — **non opérationnel en v0.1**.

## Installation

```bash
# Ajouter le marketplace local (ou via GitHub une fois publié)
/plugin marketplace add EnzoVentura/uzi
/plugin install uzi@uzi
```

## Permissions (repo cible)

Le Dev commite/pushe sur une branche (autorisé), et **Jack** lance l'app via
**`npx nx serve <app>`** (ex. `npx nx serve web` → port 4200). On **n'ajoute pas**
`npm run start:*` en `allow` : `settings.json` (policy d'équipe) le `deny`, et `deny`
l'emporte sur `allow` — d'où le passage par `nx serve`.

> Le pré-check de `/uzi-start` **vérifie** réellement les permissions du repo (il lit
> `settings*.json`) au lieu de les présumer : il confirme qu'un `allow` couvre `nx serve`
> et que `main` est protégé.

La seule chose à ajouter, c'est la **protection de `main`** dans le `deny` local
(`.claude/settings.local.json`, gitignoré = config perso) :

```jsonc
{
  "permissions": {
    "deny": [
      "Bash(git push origin main)",
      "Bash(git push -u origin main)",
      "Bash(git push * main)",
      "Bash(git merge main)",
      "Bash(gh pr merge:*)"
    ]
  }
}
```

> ⚠️ Ces `deny` sont une **première couche** (un `git *` large peut être contourné par
> des variantes exotiques). La protection robuste de `main` reste la *branch protection*
> GitHub côté serveur.

## uzi vs jack

`jack` (l'autre orchestrateur du même auteur) repose sur **AoE** (sessions/worktrees
externes, vrai parallélisme multi-tâches). `uzi` fait un choix différent : **natif,
mono-session, personas-RP-first**, avec vérification **Playwright** intégrée et une
escouade de review nommée. Les deux partagent des *patterns* (verrou de complétude,
agrégation par préséance) mais aucun code.

## État du projet

Construit par briques (voir `CHANGELOG` / commits) :

- **B0** ✅ Squelette plugin + permissions.
- **B1** ✅ Chaîne PO → Tech Lead → Dev (MVP).
- **B2** ✅ Review-fanout (3 chasseurs, asymétrie d'information).
- **B3** ✅ QA Playwright.
- **B4** ✅ Ship + commandes de cycle (`/uzi-status`, `/uzi-resume`).
- **B5** ✅ *(branche `next`)* Agent Teams (`--team`, Dev persistant) + `/uzi-modif`.
- **B6** ✅ *(branche `next`)* Extensibilité multi-repo (mode générique).

> `main` = v0.1 stable (validée sur btoc). B5/B6 cuisent sur `next` ; un
> `/plugin marketplace update` ne les tire pas tant qu'elles ne sont pas mergées.

## Sur un autre repo (extensibilité)

uzi n'a **aucune** règle métier câblée. Au pré-check, le skill `uzi-local-skills`
détecte les skills du repo et tranche un **mode** :

- **Mode projet** (ex. btoc-frontend) : les personas délèguent aux skills `btoc-*`.
- **Mode générique** (repo non outillé) : Aurélien code via l'agent `crafter` + les rules
  globales `craft.md`/`react-patterns.md`, Théo/Edgar lisent le `CLAUDE.md` du repo (ou
  infèrent du code), Yugo devient l'angle craft principal, Valentin ne fait la QA
  navigateur que si une app web + un MCP navigateur existent.

Mêmes personas, même flow — seules les capacités locales changent.

## Licence

MIT — Enzo Ventura.
