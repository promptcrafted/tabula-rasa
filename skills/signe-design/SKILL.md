---
name: signe-design
description: Structured design with four presets -- architecture, UI/UX, agent, product
context: fork
agent: signe-designer
disable-model-invocation: false
---

## Design Task

Create a structured design for the following topic using the appropriate preset.

$ARGUMENTS

If the first token starts with `preset:`, use that preset's methodology.
Otherwise, auto-detect the best preset based on the topic.

Available presets: architecture, uiux, agent, product.

Before designing, check the current directory for research output files
(signe-research-*.md) and incorporate their findings into your design.

Produce structured design deliverables and write them to disk.
