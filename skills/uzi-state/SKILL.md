---
name: uzi-state
description: "Lecture et écriture atomiques de l'état d'une mission uzi dans .uzi/. Définit le layout, le frontmatter de STATE.md et la procédure d'écriture sûre (write-temp + mv). À invoquer par Jack et les personas pour lire/mettre à jour l'état sans corruption."
---

# uzi-state — état d'une mission

Mécanique de persistance de l'état. **Aucune logique métier.**

## Layout

```
.uzi/
├── active.json                 # { "active_missions": ["<slug>"], "plugin_version": "0.1.0" }
└── <slug>/
    ├── STATE.md                # source de vérité de la mission
    ├── BESOIN.md  ARCHI.md  IMPL.md  QA-REPORT.md
    ├── REVIEW-{blind,edge,craft}.md  REVIEW.md
    ├── _diff.patch
    └── preuves/*.png
```

`.uzi/` doit être **gitignoré** dans le repo cible. Au pré-check : `git check-ignore .uzi/`
→ si non ignoré, ajouter la ligne **`.uzi/`** (exactement — pas `\.uzi/`, qui est de la
syntaxe regex, pas gitignore) au `.gitignore`, puis revérifier avec `git check-ignore`.
Le Dev ne fait **jamais** `git add .uzi/`.

## Slug — déterministe et idempotent

Le slug doit être **reproductible** (sinon `/uzi-resume` et `/uzi-review` ne retrouvent
pas le dossier). Algorithme :

1. base = description (ou résumé du ticket), **3-4 mots** significatifs ;
2. minuscules ; translittération ASCII (`é→e`, `à→a`, `ç→c`…) ; apostrophes supprimées ;
3. espaces → `-` ; tout caractère non `[a-z0-9-]` retiré ; tirets multiples compressés ;
4. préfixe `eci-XXXX--` si ticket présent ;
5. collision : si `.uzi/<slug>/` existe déjà pour une autre mission, suffixe `-2`, `-3`…

Au **resume**, on ne recalcule jamais le slug : on le **relit** depuis `active.json` /
`STATE.md`.

## Écriture des artefacts

Pour les fichiers markdown (`STATE.md`, `BESOIN.md`…), utilise les outils **`Write`/
`Edit` natifs** du harness : ils écrivent de façon sûre et gèrent l'échappement (le
contenu contient du YAML, des backticks, parfois des `EOF` — un heredoc bash serait
fragile).

Réserve le pattern atomique **temp + `mv`** (atomique sur le même FS) aux cas où c'est
strictement nécessaire en shell :

```bash
tmp="$(mktemp "${dir}/.STATE.XXXXXX")"; printf '%s' "$content" > "$tmp"; mv -f "$tmp" "${dir}/STATE.md"
```

En mode `--parallel` (2 missions), `active.json` est **partagé** : sérialise son écriture
(lockfile) ou interdis la concurrence — ne jamais écraser la liste des missions actives.

## STATE.md — frontmatter

```yaml
mission_slug, type(feature|bug), status(besoin|archi|impl|qa|review|corrections|final|done|escalated),
phase_courante(po|tech-lead|dev|qa|review|ship), mode(solo|team), ticket, branche,
started_at(ISO8601), plugin_version, cycles{max, consommes}
```

Mettre à jour `status`, `phase_courante` et le tableau **Phases** à **chaque** transition,
et logger les décisions autonomes dans la section dédiée. Modèle complet :
`templates/STATE.md`.

## Règles

- Une seule mission écrit son `STATE.md` à la fois (pas de concurrence intra-mission).
- Ne jamais réécrire un artefact de persona (`BESOIN.md`…) depuis Jack : seul le persona
  propriétaire l'écrit.
- Horodatages en ISO8601 UTC.
