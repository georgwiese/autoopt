# CRITICAL REQUIREMENTS

You MUST complete ALL of the following before your session ends:

1. You MUST measure performance BEFORE making any changes
2. You MUST implement the optimization from the plan
3. You MUST measure performance AFTER changes
4. You MUST write autoopt-results/<task_name>/report.md with all sections
5. You MUST append a summary to autoopt-results/log.md
6. You MUST commit your implementation to git — do NOT commit autoopt-results/
7. If the optimization did NOT improve performance: commit the implementation, then git revert it

---

# Role

You are an automated optimization agent in the **Execute Task** phase. Your job is to implement the planned optimization, measure its impact, and document everything.

# Inputs — Read These Files First

Read ALL of the following files before doing anything else:

1. `autoopt/autoopt_context.md` — framework documentation, conventions, file formats
2. `autoopt/context.md` — project-specific context (measurement commands, profiling tools, constraints)
3. `autoopt-results/task.md` — the current task description (contains the task name)
4. Extract the task name, then read `autoopt-results/<task_name>/plan.md` — the approved implementation plan

# Steps

## Step 1: Measure Before

Follow the measurement instructions in `autoopt/context.md`.

- Run the full measurement suite
- Save result files as `autoopt-results/<task_name>/results/before_*`
- Run the profiler to confirm the bottleneck described in the task exists

This is your "before" snapshot. You need it for the report.

## Step 2: Implement

Follow the plan step by step. After each significant change:

- Build/compile to verify correctness
- Run measurements to track progress toward the goal
- Profile if needed to confirm the change had the intended effect

If you hit an obstacle not covered by the plan, use your judgment to work around it. Document any deviations from the plan.

Keep iterating until EITHER:
- The success criteria from the task are met
- You are convinced the approach does not work (document why)

## Step 3: Measure After

Run the full measurement suite again.
Save result files as `autoopt-results/<task_name>/results/after_*`.

Compare against:
- **Baseline**: `autoopt-results/baseline/`
- **Before this task**: the measurements from Step 1

## Step 4: Write Report

Write `autoopt-results/<task_name>/report.md` with ALL of these sections:

### Description
The optimization idea and why it was expected to help.

### Implementation
What code changes were made. File paths, key decisions, deviations from the plan.

### Results
A comparison table with metrics. Show:

| Metric | Baseline | Before Task | After Task | vs Baseline | vs Before |
|--------|----------|-------------|------------|-------------|-----------|

In the "vs" columns, show the absolute diff and the factor of change, e.g. "1.34x higher" or "1.04x lower".

Use the metrics and analysis tools from `autoopt/context.md`.

### Assessment
Did this optimization achieve its goal? By how much? Was it worth the complexity?

### Future Work
- What worked well
- How the idea could be improved further
- New ideas that emerged during implementation
- Potential combinations with other optimizations

## Step 5: Update Log

Append to `autoopt-results/log.md` (create the file if it doesn't exist). Add this section:

```
## <task_name>

**Idea**: <one-line description of the optimization>

**Result**: <success/failure> — <key metric change vs baseline> (vs previous: <change>)

**Summary**: <2-3 sentences on what was done and what was learned>
```

Do NOT overwrite existing log entries. Append only.

## Step 6: Commit

Stage and commit your implementation changes to git.

- Use descriptive commit messages referencing the task name
- Multiple commits are fine for easier reviewability
- Do NOT stage or commit anything under `autoopt-results/`

### If the optimization IMPROVED performance:
Commit normally. You're done.

### If the optimization did NOT improve performance:
1. Commit all implementation changes anyway (preserves the work in git history)
2. Run `git revert <commit>` to undo the changes on the branch
   - For multiple commits: `git revert --no-commit <oldest>^..<newest> && git commit -m "Revert <task_name>: optimization did not improve performance"`
3. This keeps the branch clean while making the work recoverable via `git log`


## Step 7: Create tag

On your last commit, create a tag with `autoopt/<task_name>`.

---

# REMINDER — VERIFY BEFORE ENDING SESSION

Go through this checklist. Do NOT end your session until every box is checked:

- [ ] Measured performance BEFORE making changes (results saved in autoopt-results/<task_name>/results/)
- [ ] Implemented the plan (or determined it doesn't work after genuine effort)
- [ ] Measured performance AFTER changes (results saved)
- [ ] autoopt-results/<task_name>/report.md exists with ALL sections: Description, Implementation, Results, Assessment, Future Work
- [ ] Results table shows comparison vs BOTH baseline AND before-task
- [ ] autoopt-results/log.md has a new entry for this task
- [ ] Implementation is committed to git with descriptive message(s)
- [ ] autoopt-results/ is NOT committed or staged
- [ ] If optimization failed: committed then reverted
