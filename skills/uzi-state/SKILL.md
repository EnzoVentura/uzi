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

`.uzi/` doit être **gitignoré** dans le repo cible (ajouter `\.uzi/` au `.gitignore`
si absent — vérification au pré-check de `/uzi-start`).

## Écriture atomique (obligatoire pour STATE.md et active.json)

Jamais d'écriture en place sur un fichier d'état (risque de corruption si interruption).
Toujours : écrire dans un fichier temporaire puis renommer.

```bash
tmp="$(mktemp "${dir}/.STATE.XXXXXX")"
cat > "$tmp" <<'EOF'
<nouveau contenu>
EOF
mv -f "$tmp" "${dir}/STATE.md"
```

Le `mv` sur le même système de fichiers est atomique → pas d'état intermédiaire visible.

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
