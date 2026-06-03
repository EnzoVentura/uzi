#!/bin/bash
# Renomme la session Claude Code quand une mission uzi démarre (/uzi-start),
# pour la retrouver facilement. Hook UserPromptSubmit : émet `sessionTitle`
# (même effet que /rename).
#
# Titre : "uzi · ECI-XXXX" si un ticket est passé, sinon "uzi · <libellé court>"
# dérivé de la description entre guillemets.
#
# Garde « sticky » : ne nomme la session qu'UNE fois (marqueur par session_id),
# pour qu'un /rename manuel ultérieur soit préservé.

set -euo pipefail

input="$(cat)"

prompt="$(printf '%s' "$input" | jq -r '.prompt // .message // ""' 2>/dev/null || true)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // ""' 2>/dev/null || true)"

# Ne réagit qu'au lancement d'une mission uzi.
printf '%s' "$prompt" | grep -qiE '(^|/)uzi-start( |$|")' || exit 0

# Sticky : une seule fois par session.
marker_dir="${TMPDIR:-/tmp}/uzi-session-rename"
mkdir -p "$marker_dir"
marker="$marker_dir/${session_id:-unknown}.named"
[ -f "$marker" ] && exit 0

# Ticket prioritaire, sinon libellé court depuis la 1ʳᵉ chaîne entre guillemets.
ticket="$(printf '%s' "$prompt" | grep -oiE 'ECI-[0-9]+' | head -n1 | tr '[:lower:]' '[:upper:]' || true)"
if [ -n "$ticket" ]; then
  title="uzi · ${ticket}"
else
  desc="$(printf '%s' "$prompt" | sed -nE 's/.*uzi-start[[:space:]]+"([^"]+)".*/\1/p' | head -n1)"
  desc="$(printf '%s' "$desc" | cut -c1-48 | sed -E 's/[[:space:]]+$//')"
  [ -z "$desc" ] && desc="mission"
  title="uzi · ${desc}"
fi

printf '%s' "$title" > "$marker"

jq -n --arg t "$title" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    sessionTitle: $t
  }
}'
