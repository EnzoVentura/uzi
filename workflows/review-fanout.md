# Protocole `review-fanout`

Phase de review d'uzi : **fan-out à asymétrie d'information** + **agrégation
déterministe**. Exécuté par Jack (Manager). Conçu pour tourner **sans dépendance au
Workflow tool** — Jack dispatche les 3 chasseurs en parallèle via le tool `Agent`.

## Entrées

- `slug` de la mission ;
- la diff de la branche vs la base d'intégration (`main` par défaut).

## Étape 1 — collecte de la diff (base résolue, patch garde-fou)

Jack résout la **base d'intégration** (ne présume pas `main`) puis écrit la diff sur le
**merge-base** :

```bash
base="${UZI_BASE:-$(git symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')}"
base="${base:-main}"
git fetch --quiet origin "$base" 2>/dev/null || true
git diff "$(git merge-base "origin/$base" HEAD)"..HEAD > .uzi/<slug>/_diff.patch
```

**Garde-fou** : si `_diff.patch` est **vide** ou si `git diff` a erré (base introuvable),
**ne lance pas** le fan-out → escalade (les chasseurs concluraient `APPROVED` sur du vide).

## Étape 2 — fan-out parallèle (UN seul message, 3 `Agent`)

Jack dispatche les **3 chasseurs en parallèle**, chacun avec **son** asymétrie :

Jack passe à chacun **les chemins absolus d'entrée ET de sortie** (le chasseur ne
découvre rien) :

| Sous-agent | Input (entrée + sortie) | Asymétrie garantie par | Marqueur de fin |
|---|---|---|---|
| `uzi:blind-hunter` (Bastien) | `_diff.patch` (entrée) + `REVIEW-blind.md` (sortie) — **rien d'autre** | ses tools `Read, Write` (ni Grep/Glob/Bash → **pas de découverte** ; il peut lire un chemin absolu donné, mais n'en connaît aucun) | `UZI_REVIEW_BLIND_DONE` |
| `uzi:edge-hunter` (Edgar) | `_diff.patch` + repo + `CLAUDE.md` → `REVIEW-edge.md` | accès complet en lecture | `UZI_REVIEW_EDGE_DONE` |
| `uzi:craft-reviewer` (Yugo) | `_diff.patch` + rules craft → `REVIEW-craft.md` | accès `~/.claude/rules/*` | `UZI_REVIEW_CRAFT_DONE` |

Chacun écrit son fichier (au chemin de sortie fourni) puis rend la main.

## Étape 3 — agrégation déterministe → `REVIEW.md`

Quand les 3 fichiers existent (verrou : fichier + `verdict` + marqueur d'angle
`UZI_REVIEW_{BLIND,EDGE,CRAFT}_DONE`) :

1. **Collecter** tous les findings des 3 angles.
2. **Dédupliquer** par `fichier:ligne` (garder la sévérité la plus haute, mentionner les
   angles concordants).
3. **Vérifier l'acceptance** : confronter la diff aux AC de `BESOIN.md` — un AC non
   couvert par le code/les tests = finding 🔴 « AC non couvert ».
4. **Verdict (préséance stricte)** :
   - `REJECTED` si un angle rejette (archi cassée, régression majeure) → escalade ;
   - sinon `CHANGES_REQUESTED` si ≥ 1 🔴 (tout angle) **ou** un AC non couvert ;
   - sinon `APPROVED` (🟡/🔵 tolérés, listés pour info).
5. Écrire `.uzi/<slug>/REVIEW.md` (gabarit `templates/REVIEW.md`).

## Boucle de correction

Si `CHANGES_REQUESTED` : Jack transmet à Aurélien les findings **priorisés** (🔴 + AC
manquants d'abord) → nouvel `IMPL.md` → re-QA si surface UI touchée. Avant le
**re-fanout**, Jack **régénère `_diff.patch`** (étape 1) — sinon les chasseurs
re-reviewent l'ancienne diff — et archive les `REVIEW-*.md`/`REVIEW.md` du cycle
précédent (ex. suffixe `-cycle<N>`). Compteur `cycles.max` (défaut 2) ; épuisé → escalade.

## Déclenchement isolé

`/uzi-review [--base <ref>]` lance ce protocole seul (re-review après corrections
manuelles, ou audit d'une branche existante).

> Variante avancée : en session ultracode, Jack **peut** piloter ce fan-out via le
> Workflow tool (un `parallel()` des 3 angles + agrégation scriptée). Le résultat est
> identique ; le dispatch parallèle `Agent` reste le défaut robuste.
