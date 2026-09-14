---
alwaysApply: true
---

# On Disk-Full, Stop and Ask — Never Clean Up Yourself

If a command fails with "No space left on device" (or you otherwise run out of
disk), stop immediately and prompt the user to free space. Never run `bazel
clean`, delete cache/output-base directories, or otherwise try to reclaim disk
yourself — the caches are shared across worktrees and deleting them can wreck
other work.
