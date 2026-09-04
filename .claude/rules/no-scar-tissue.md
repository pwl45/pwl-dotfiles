# Don't Document What Isn't There

In code comments, commit messages, and PR descriptions, describe what the
code/commit/PR *does*. Never explain what it does not contain, what you chose
not to do, what lives somewhere else, or what an earlier version did.

## Do not write

- "X is not in this PR / X comes from the base branch / X landed separately"
- "I did not adopt the workarounds from <other branch or doc>"
- "This used to do X" / "replaces the old Y" / "moved from Z"
- "Note: this does not handle W" for a W nobody asked about

## Instead
- State what the change does, and why the code is the way it is.
