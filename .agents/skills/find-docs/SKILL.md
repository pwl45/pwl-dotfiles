---
name: find-docs
description: >-
  Look up current documentation, API references, and examples when the answer
  is unknown, uncertain, version-sensitive, or explicitly needs verification.
  Skip lookup for stable facts and familiar, routine tasks.
---

# Documentation Lookup

Use Context7 when documentation would resolve real uncertainty about a developer
technology. Trust existing knowledge for stable basics that can be answered
confidently.

Look up documentation when:

- API syntax, configuration, or behavior may have changed.
- The question depends on a particular version.
- Debugging hinges on library-specific behavior you are unsure about.
- The user asks for current docs, verification, citations, or links.

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
