# AutoOpt

Automated optimization loop powered by Claude. Symlink this into any project, write a context file describing what to optimize and how to measure it, and let agents iterate: analyze, plan, implement, measure, repeat.

Inspired by [autoresearch](https://github.com/karpathy/autoresearch) and [Anthropic's C compiler approach](https://www.anthropic.com/engineering/building-c-compiler).

## Quickstart

```bash
# 1. Clone this repo
git clone <repo-url> autoopt-repo
cd autoopt-repo

# 2. Symlink into your project
ln -s "$(pwd)" /path/to/your-project/autoopt

# 3. Create project-specific config
cd /path/to/your-project/autoopt
cp context_template.md context.md
cp review_guideline_template.md review_guideline.md

# 4. Edit context.md — describe your optimization problem:
#    - How to build and set up
#    - What you're optimizing
#    - How to measure results (exact commands)
#    - How to profile
#    - What must not be changed
#    - What result files to collect
$EDITOR context.md

# 5. Optionally customize review_guideline.md for your domain

# 6. Run
cd /path/to/your-project
bash autoopt/run.sh        # default: 100 iterations
bash autoopt/run.sh 10     # or specify a count
```

That's it. The agent will create `autoopt-results/` in your project directory and start optimizing.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- The `claude` command must be available in PATH

## How It Works

Each iteration runs three separate Claude sessions back-to-back:

### Phase 1: Generate Task

The agent reads all context and history, measures current performance, profiles the system, and generates several optimization ideas. It picks the most promising one based on expected impact, probability of success, and implementation complexity, then writes a task description to `autoopt-results/task.md`.

On the first run, it also creates `autoopt-results/baseline/` with baseline measurements that all future results are compared against.

### Phase 2: Create Plan

The agent reads the task, researches the relevant code paths, and writes a detailed implementation plan. It then spawns a reviewer sub-agent that evaluates the plan against the review guideline. The plan is iterated until the reviewer approves it (no design-level blockers, prototype-ready).

### Phase 3: Execute Task

The agent measures before, implements the plan, and measures after. It writes a detailed report with results compared to both the baseline and the previous task, appends a summary to the log, and commits the implementation. If the optimization didn't help, it commits anyway (preserving the work in git history) then reverts.

### Communication Between Phases

The three phases are independent Claude sessions with no shared context. They communicate entirely through files in `autoopt-results/`:

```
autoopt-results/
  baseline/              # Baseline measurements (created once)
  task.md                # Current task (written by phase 1, read by 2 and 3)
  log.md                 # Append-only history (read by phase 1, appended by phase 3)
  2026-04-10-1430-foo/
    plan.md              # Written by phase 2, read by phase 3
    report.md            # Written by phase 3
    results/             # Measurement artifacts from phase 3
```

### Error Handling

If any phase fails (e.g., API credit exhaustion, network error), the script retries after 60 seconds until it succeeds.

## File Reference

### Checked into this repo (framework)

| File | Description |
|------|-------------|
| `run.sh` | Bash loop that drives the three phases |
| `autoopt_context.md` | Generic framework documentation read by all agents |
| `context_template.md` | Template for project-specific context |
| `review_guideline_template.md` | Template for plan review guidelines |
| `prompts/generate_task.md` | Prompt for phase 1 |
| `prompts/create_plan.md` | Prompt for phase 2 |
| `prompts/do_task.md` | Prompt for phase 3 |

### Created per project (gitignored)

| File | Description |
|------|-------------|
| `context.md` | Your project-specific optimization context |
| `review_guideline.md` | Your project-specific review criteria |

### Created at runtime in project dir

| Path | Description |
|------|-------------|
| `autoopt-results/baseline/` | Baseline measurements |
| `autoopt-results/task.md` | Current task |
| `autoopt-results/log.md` | Full optimization history |
| `autoopt-results/<task>/plan.md` | Approved plan |
| `autoopt-results/<task>/report.md` | Results report |
| `autoopt-results/<task>/results/` | Measurement artifacts |

## Writing a Good context.md

The quality of `context.md` determines how well the agents perform. Key principles:

- **Be exact about measurement commands.** Don't say "run the benchmark." Say `python bench.py --config fast --output results.json`. The agent needs copy-pasteable commands.
- **Define success numerically.** "Faster" is vague. "Reduce latency from 50ms to 30ms" gives the agent a clear target.
- **List constraints explicitly.** If the API contract can't change, say so. If certain files are off-limits, name them.
- **Describe what result files look like.** The agent needs to know what to save and how to compare before vs. after.
- **Include prior knowledge.** If you know where the bottleneck is, say so. Link to relevant docs, papers, or profiles.

## Tips

- Check `autoopt-results/log.md` periodically to see cumulative progress.
- Individual task reports in `autoopt-results/<task>/report.md` have detailed analysis.
- All implementation work is in git history, including reverted failed attempts — use `git log` to review.
- To resume after stopping: just run `bash autoopt/run.sh` again. The agent reads the log and picks up where it left off.
- To steer the agent: edit `autoopt-results/log.md` to add notes about what to try or avoid next, or edit `autoopt-results/task.md` to override the next task.
