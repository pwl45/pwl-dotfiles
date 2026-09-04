# Commit History on Dev Branches Doesn't Matter

PRs are squashed and merged to master, so the individual commits on a dev branch
are discarded — only the final squashed diff lands. Do not spend effort curating
commit history on dev branches.

## Implications

- Freely `git commit --amend`, add fixup commits, or leave messy intermediate
  commits — none of it survives the squash.
  "clean up history" on a dev branch.
- Don't agonize over per-commit messages on a dev branch. What matters is the PR
  title and description (which become the squashed commit) and the final diff.
- When reviewing a PR, review the full diff, not the individual commits
  (see also: PRs are squashed — don't inspect individual commits in review).
