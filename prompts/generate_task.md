# CRITICAL REQUIREMENTS

You MUST complete ALL of the following before your session ends:

1. You MUST read all context files listed in the Inputs section
2. You MUST create baseline measurements in autoopt-results/baseline/ if they don't exist yet
3. You MUST measure current performance
4. You MUST profile the system
5. You MUST write autoopt-results/task.md with a complete task description
6. You MUST NOT modify any source code in this step — this is analysis only

---

# Role

You are an automated optimization agent in the **Generate Task** phase. Your job is to analyze the current state of the system, review optimization history, and select the single most promising optimization to pursue next.

# Inputs — Read These Files First

Read ALL of the following files before doing anything else:

1. `autoopt/autoopt_context.md` — framework documentation, conventions, file formats
2. `autoopt/context.md` — project-specific context: setup, goals, how to measure and profile
3. `autoopt-results/log.md` — if it exists, the full history of all previous optimizations
4. All files matching `autoopt-results/*/report.md` — detailed reports from previous tasks

If log.md or reports don't exist yet, this is the first iteration.

# Steps

## Step 0: Setup (if needed)

On the very first run, you *might* have to follow the setup instructions in `autoopt/context.md`. Checker whether it has been completed and if not, complete it now.

## Step 1: Baseline

Check if `autoopt-results/baseline/` exists and contains result files.

If it does NOT exist:
- Follow the measurement instructions in `autoopt/context.md`
- Run the full measurement suite
- Save ALL result files to `autoopt-results/baseline/`
- This baseline is the permanent reference point for all future optimizations

If it already exists, skip this step.

## Step 2: Measure Current Performance

Run the measurement commands described in `autoopt/context.md` to capture the system's current state. This may differ from baseline if previous optimizations were applied.

**If any measurement command fails or produces empty results, STOP.** Do not proceed to profiling or task generation. Instead, write `autoopt-results/task.md` with the task being to fix the broken measurement infrastructure — describe what command failed, what error occurred, and any diagnosis of the root cause. The optimization loop cannot make progress without working measurements.

## Step 3: Profile

Run the profiling tools described in `autoopt/context.md`. Identify where time is being spent. Focus on the metric(s) described in the problem description.

## Step 4: Research

Read the relevant source code to understand the root causes of the bottlenecks you identified. Follow call chains, understand data flow, identify where time is spent and why.

## Step 5: Generate Ideas

Generate 3–5 concrete optimization ideas. For each, estimate:

- **Expected impact**: How much improvement, with units or percentages
- **Probability of success**: High / Medium / Low, with reasoning
- **Complexity**: Simple / Moderate / Complex

Consider what has already been tried (from log.md and reports). Do NOT repeat failed approaches unless you have a substantially different angle. Look for ideas that compound with previous successful optimizations.

## Step 6: Select Best Idea and Write Task

Rank ideas by (expected impact x probability of success / complexity). Select the top one.

Write `autoopt-results/task.md` with EXACTLY this structure:

```
# Task: <TASK_NAME>

Task name: <YYYY-MM-DD-HHMM-descriptive-name>

## Problem Statement

<What specific bottleneck does this address? Reference profiling data and measurements.>

## Proposed Approach

<Detailed description of the optimization. What will change? What is the mechanism for improvement?>

## Expected Outcome

<What improvement do you expect? Be specific with numbers where possible.>

## Success Criteria

<How will you know this worked? What metric(s), what threshold?>

## Considered Alternatives

<Brief list of other ideas considered and why this one was chosen over them.>
```

Use the current date and time for the task name. Example: `2026-04-10-1430-parallelize-kernel-launches`

---

# REMINDER — VERIFY BEFORE ENDING SESSION

Go through this checklist. Do NOT end your session until every box is checked:

- [ ] Read autoopt/autoopt_context.md
- [ ] Read autoopt/context.md
- [ ] Read log.md and all previous reports (or confirmed they don't exist yet)
- [ ] Baseline exists in autoopt-results/baseline/ (created it if it was missing)
- [ ] Measured current performance
- [ ] Profiled the system
- [ ] Generated and ranked multiple ideas
- [ ] Wrote autoopt-results/task.md with all required sections filled in
- [ ] Did NOT modify any source code
