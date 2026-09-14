---
alwaysApply: true
---

# Don't Push to GitHub Unprompted in an Interactive Chat

During back-and-forth conversation, do not `git push`, force-push, create or edit a
pull request, or change a PR's base branch unless asked. Commit locally, report what
is staged or committed, and let the user decide when it goes to the remote.

Do push without asking each time when the user has already approved a plan that
includes pushing or creating pull requests, e.g. "create tickets and PRs for each",
"open a PR when it's green", or a plan whose steps end in a PR. That approval covers
the whole plan, including follow-up pushes to branches it created.

## Why

A push is externally visible and hard to take back: it notifies reviewers, kicks off
CI, and a force-push discards the revision they may already be reading. Amending and
re-pushing mid-discussion means the user is reviewing a moving target, and rewriting
a PR's base or description while a design question is still open publishes a decision
that has not been made yet.

## What to do instead

- Make the edit, run the tests, commit, and say the commit is local and unpushed.
- When a design question is open, settle it before the branch goes out.
- If a change to already-pushed work seems clearly right, describe it and ask.
