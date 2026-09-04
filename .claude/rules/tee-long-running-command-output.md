# Tee Long-Running Command Output to a File

When running a long-running or background command (builds, tests, bazel, docker,
regen, deploys, anything that may take minutes), write its output to a file
instead of blindly tailing or buffering it in the terminal.

## Why

If the command hangs, a plain `tail`/streamed invocation gives no signal — you
can't tell "still working" from "stuck." A file on disk that stops growing makes
a hang obvious (check the timestamp / size), and preserves the full log for
inspection afterward instead of a truncated tail.

## What to do

- Tee to a file and keep watching it, e.g.:
  `<command> 2>&1 | tee /path/to/run.log`
- For background runs, redirect to a known file and poll it:
  `<command> > /path/to/run.log 2>&1 &` then `tail -f`/re-read the file.
- Prefer the scratchpad directory for these logs when one is available.
- Report the log path so the user can watch it too, and so a stall is
  diagnosable (last line + mtime) rather than invisible.
