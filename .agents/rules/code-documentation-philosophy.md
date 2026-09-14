---
alwaysApply: true
---

# Code Documentation Philosophy

Enforce an information hierarchy: each fact about the code lives in exactly
one place, at the altitude where a reader needs it. Everything else points
there.

## The hierarchy

- **Module docstring**: one or two short paragraphs, broad strokes -- what the
  module is and where the deeper story lives. Cross-reference, never restate.
  If a module carries process-wide policy (a lifecycle, a precedence order),
  state it here once; no other docstring in the file repeats it.
- **Function/method docstrings**: one or two lines of plain WHAT. Raise
  conditions can be summarized in a sentence ("Raises if two releases diverge
  in the value of a member"). Do not re-explain module policy, defend design
  decisions, or narrate callers ("Called by X before Y...") -- that is the
  caller's business.
- **Inline comments**: only where the code is non-obvious, one line, on the
  exact statement they explain. A comment restating an adjacent
  `if`/`raise` whose message already says it is noise; a comment decoding a
  cryptic idiom (a `setdefault` trick, a magic literal like `"\n\n\n"`) earns
  its place.
- **Examples**: concrete beats prose, but examples live with the machinery
  they illustrate (the function that builds the thing), not in the module
  header.

## Style

- Remember that documentation is written primarily for humans and secondarily for LLMs.
- Sound like a human: blunt topic sentence first, then stop.
- Rationale (the WHY) goes at the definition site of the mechanism, stated
  once. If two places must agree, derive one from the other or cross-reference
  with a keep-in-sync note.
- No scar tissue: never explain rejected alternatives, past bugs, or what a
  change replaced. Comments are for readers of this file today.

## The test

A documentation edit that improves the file should usually delete more lines
than it adds. If a docstring cannot be shortened without losing a fact,
check whether the fact is already stated somewhere better -- it usually is.
