---
name: signe-research
description: Deep-dive research using web search, paper reading, library docs, and structured analysis with confidence scoring
context: fork
agent: signe-researcher
disable-model-invocation: false
---

## Research Task

Investigate the following topic thoroughly using your multi-source research methodology.

$ARGUMENTS

If the first token of the topic starts with `preset:`, use that preset's specific methodology. Otherwise, auto-detect the best preset based on the query.

Report your findings in structured Markdown with inline citations, confidence levels, and source URLs.
