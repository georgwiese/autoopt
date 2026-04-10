#!/bin/bash
# Usage: bash autoopt/view_log.sh autoopt-results/logs/<file>.log
# Or:   tail -f autoopt-results/logs/<file>.log | bash autoopt/view_log.sh
#
# Converts stream-json output into readable text.

set -euo pipefail

filter() {
  jq -r --unbuffered '
    if .type == "system" and .subtype == "init" then
      "═══ Session \(.session_id[:8]) | model: \(.model) ═══\n"

    elif .type == "assistant" then
      [.message.content[] |
        if .type == "text" then
          .text
        elif .type == "tool_use" then
          "→ \(.name)(\(.input | to_entries | map("\(.key)=\(.value | tostring | if length > 100 then .[:100] + "..." else . end)") | join(", ")))"
        else empty
        end
      ] | join("\n")

    elif .type == "user" then
      [.message.content[] |
        if .type == "tool_result" then
          if (.content | length) > 500 then
            "  ← \(.content[:500])..."
          else
            "  ← \(.content)"
          end
        else empty
        end
      ] | join("\n")

    elif .type == "result" then
      "\n═══ \(.subtype) | \(.duration_ms/1000)s | $\(.total_cost_usd | tostring[:6]) | \(.num_turns) turns ═══"

    else empty
    end
  ' 2>/dev/null
}

if [ $# -ge 1 ]; then
  cat "$1" | filter
else
  filter
fi
