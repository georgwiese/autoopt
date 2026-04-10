#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
MAX_ITERATIONS=${1:-100}
EFFORT=${EFFORT:-max}
MODEL=${MODEL:-}
FALLBACK_MODEL=${FALLBACK_MODEL:-}
RETRY_DELAY=60

cd "$PROJECT_DIR"
mkdir -p autoopt-results/logs

# Log bash script output
RUN_LOG="autoopt-results/logs/run.log"
exec > >(tee -a "$RUN_LOG") 2>&1

run_step() {
  local prompt_file="$1" step_name="$2" iteration="$3" log_name="$4"
  local log_file="autoopt-results/logs/${log_name}.log"

  local cmd=(claude -p "$(cat "$prompt_file")" --dangerously-skip-permissions --effort "$EFFORT" --name "autoopt #$iteration: $step_name" --output-format stream-json)
  [[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
  [[ -n "$FALLBACK_MODEL" ]] && cmd+=(--fallback-model "$FALLBACK_MODEL")

  while true; do
    echo "[$(date)] $step_name → $log_file"
    if "${cmd[@]}" > "$log_file" 2>&1; then
      break
    fi
    echo "[$(date)] $step_name failed (exit $?), retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
  done
}

for i in $(seq 1 "$MAX_ITERATIONS"); do
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  echo "========================================"
  echo "[$(date)] Iteration $i / $MAX_ITERATIONS"
  echo "========================================"
  run_step "$SCRIPT_DIR/prompts/generate_task.md" "Generate Task" "$i" "${TIMESTAMP}-${i}-1-generate"
  run_step "$SCRIPT_DIR/prompts/create_plan.md"   "Create Plan"   "$i" "${TIMESTAMP}-${i}-2-plan"
  run_step "$SCRIPT_DIR/prompts/do_task.md"        "Do Task"       "$i" "${TIMESTAMP}-${i}-3-do"
done
