# Protocole `review-fanout`

Phase de review d'uzi : **fan-out à asymétrie d'information** + **agrégation
déterministe**. Exécuté par Jack (Manager). Conçu pour tourner **sans dépendance au
Workflow tool** — Jack dispatche les 3 chasseurs en parallèle via le tool `Agent`.

## Entrées

- `slug` de la mission ;
- la diff de la branche vs la base d'intégration (`main` par défaut).

## Étape 1 — collecte de la diff

Jack écrit la diff brute dans `.uzi/<slug>/_diff.patch` :

```bash
git -C <repo> diff <base>..HEAD > .uzi/<slug>/_diff.patch
```

## Étape 2 — fan-out parallèle (UN seul message, 3 `Agent`)

Jack dispatche les **3 chasseurs en parallèle**, chacun avec **son** asymétrie :

| Sous-agent | Input fourni | Asymétrie garantie par |
|---|---|---|
| `uzi:blind-hunter` (Bastien) | chemin de `_diff.patch` **seul** | ses tools : `Read, Write` (ni Grep, ni Glob, ni Bash → ne peut pas explorer) |
| `uzi:edge-hunter` (Edgar) | `_diff.patch` + repo + `CLAUDE.md` | accès complet en lecture |
| `uzi:craft-reviewer` (Yugo) | `_diff.patch` + rules craft | accès rules `~/.claude/rules/*` |

Chacun écrit `REVIEW-{blind,edge,craft}.md` puis rend la main.

## Étape 3 — agrégation déterministe → `REVIEW.md`

Quand les 3 fichiers existent (verrou de complétude : fichier + `verdict` + marqueur) :

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
manquants d'abord) → nouvel `IMPL.md` → re-QA si surface UI touchée → **re-fanout**.
Compteur `cycles.max` (défaut 2) ; épuisé → escalade.

## Déclenchement isolé

`/uzi-review [--base <ref>]` lance ce protocole seul (re-review après corrections
manuelles, ou audit d'une branche existante).

> Variante avancée : en session ultracode, Jack **peut** piloter ce fan-out via le
> Workflow tool (un `parallel()` des 3 angles + agrégation scriptée). Le résultat est
> identique ; le dispatch parallèle `Agent` reste le défaut robuste.
