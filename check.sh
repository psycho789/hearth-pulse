#!/usr/bin/env bash
# Fetch every URL in the targets file and print the ones that are down, one per line
# as "<url> <reason>". A URL counts as down only if all attempts fail, so one slow
# request does not raise an alert. Exit status: 0 all up, 1 something is down.
set -euo pipefail

targets="${1:-targets.txt}"
attempts="${ATTEMPTS:-3}"
pause="${PAUSE_SECONDS:-20}"

down=0
while IFS= read -r url; do
  [[ -z "$url" || "$url" == \#* ]] && continue
  reason=""
  for ((try = 1; try <= attempts; try++)); do
    # %{http_code} is 000 when no HTTP answer arrived (DNS, TLS, timeout).
    code=$(curl -sS -o /dev/null -m 15 -w '%{http_code}' "$url" 2>/dev/null) || true
    if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
      reason=""
      break
    fi
    reason="HTTP ${code:-000}"
    ((try < attempts)) && sleep "$pause"
  done
  if [[ -n "$reason" ]]; then
    echo "$url $reason"
    down=1
  fi
done < "$targets"
exit "$down"
