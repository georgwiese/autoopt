#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MAX_ITERATIONS=${1:-100}
RETRY_DELAY=60

cd "$PROJECT_DIR"
mkdir -p autoopt-results

run_step() {
  local prompt_file="$1" step_name="$2"
  while true; do
    echo "[$(date)] $step_name"
    if claude -p "$(cat "$prompt_file")" --dangerously-skip-permissions; then
      break
    fi
    echo "[$(date)] $step_name failed, retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
  done
}

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo "========================================"
  echo "[$(date)] Iteration $i / $MAX_ITERATIONS"
  echo "========================================"
  run_step "$SCRIPT_DIR/prompts/generate_task.md" "Generate Task"
  run_step "$SCRIPT_DIR/prompts/create_plan.md" "Create Plan"
  run_step "$SCRIPT_DIR/prompts/do_task.md" "Do Task"
done
