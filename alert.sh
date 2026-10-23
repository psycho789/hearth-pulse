#!/usr/bin/env bash
# Turn the result of check.sh into GitHub issues, so an outage notifies the owner once:
# - something down and no open outage issue: open one, assigned to the owner;
# - still down but a different set of URLs: comment with the new list;
# - everything up and an outage issue is open: comment and close it.
# Needs GH_TOKEN (issues: write), GITHUB_REPOSITORY and OWNER in the environment.
set -euo pipefail

down_file="$1"
label="outage"

gh label create "$label" --color B60205 --description "A watched URL is down" 2>/dev/null || true
open=$(gh issue list --label "$label" --state open --json number --jq '.[0].number // empty')
now=$(date -u '+%Y-%m-%d %H:%M UTC')

if [[ -s "$down_file" ]]; then
  list=$(sed 's/^/- /' "$down_file")
  if [[ -z "$open" ]]; then
    gh issue create --label "$label" --assignee "$OWNER" \
      --title "Down: $(cut -d' ' -f1 "$down_file" | paste -sd ' ' -)" \
      --body "$(printf '@%s these stopped answering at %s (3 tries, 20 s apart):\n\n%s\n\nThis issue closes itself when they answer again. Run: %s' \
        "$OWNER" "$now" "$list" "$RUN_URL")"
  else
    previous=$(gh issue view "$open" --json body,comments \
      --jq '[.body] + [.comments[].body] | last')
    if [[ "$previous" != *"$list"* ]]; then
      gh issue comment "$open" --body "$(printf '@%s down now (%s):\n\n%s' "$OWNER" "$now" "$list")"
    fi
  fi
elif [[ -n "$open" ]]; then
  gh issue comment "$open" --body "$(printf '@%s everything answers again (%s).' "$OWNER" "$now")"
  gh issue close "$open"
fi
