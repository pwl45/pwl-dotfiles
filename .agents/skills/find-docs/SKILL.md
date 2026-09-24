---
name: find-docs
description: >-
  Look up documentation to resolve a specific knowledge gap, a concrete version
  dependency, or an explicit request for verification. Answer familiar, routine
  commands and stable concepts directly from existing knowledge.
---

# Documentation Lookup

Answer familiar basics directly. 

Before looking up documentation, identify the specific unknown or requested
verification the lookup will resolve. Software being updateable is not enough;
there must be a concrete reason the answer could depend on a change or version.

Look up documentation when you cannot confidently answer a necessary detail,
there is a concrete version dependency, or the user requests current docs,
verification, citations, or links.

## Context7

Resolve the library, then query its documentation:

```bash
npx ctx7@latest library <name> "<query>"
npx ctx7@latest docs <libraryId> "<query>"
```

Run `library` first unless the user supplied a Context7 ID such as
`/org/project` or `/org/project/version`. Prefer an exact name, an applicable
version, and an authoritative source. Make the query specific to the user's
question and never include secrets or private data.

Make at most three Context7 attempts per question. If the answer is still not
available, use the best reliable source or knowledge you have and state any
material uncertainty.

If Context7 reports an exhausted quota, tell the user. Mention
`npx ctx7@latest login` only when they want to continue using Context7.
