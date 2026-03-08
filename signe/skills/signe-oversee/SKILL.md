---
name: signe-oversee
description: Code review, quality gates, and progress tracking
context: fork
agent: signe-overseer
disable-model-invocation: false
---

## Oversight Task

Review the following scope using your multi-lens methodology.

$ARGUMENTS

If the first token starts with `scope:`, use it to narrow the review:
- `scope:security` -- run only the security lens
- `scope:correctness` -- run only the correctness lens
- `scope:performance` -- run only the performance lens
- `scope:coverage` -- run only the test coverage lens
- `scope:style` -- run only the style lens
- `scope:plan` -- run only the plan gap analysis
- `scope:progress` -- run only the progress tracker
- `scope:gate` -- run the quality gate verdict only

Otherwise, run the full review (all lenses + plan comparison + progress + verdict).

Check `.planning/` for plan files and acceptance criteria to compare against.
