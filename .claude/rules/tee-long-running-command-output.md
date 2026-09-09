# Wrap Long-Running Commands in `monitor`

For any command that may run for minutes (builds, tests, bazel, nix, docker,
regen, deploys), prefix it with `monitor`:

```
monitor nixos-rebuild switch --flake .
monitor --name hm home-manager switch --flake .
```

`monitor` writes the full output to a log file, prints that path before the
command starts, and warns on stdout whenever the log stops growing. Report the
path it prints so the run stays diagnosable from another shell.

Combine it with the Bash tool's `run_in_background` when the command is expected
to outlast the tool timeout. `monitor` itself runs in the foreground and returns
the command's own exit status.

## Why

A command whose output is buffered or piped into `tail` gives no signal while it
runs: "still working" and "wedged" look identical. A log file on disk makes the
difference visible (last line + mtime), and keeps the full output instead of a
truncated tail.

## Options worth knowing

- `--name NAME` writes to `$MONITOR_LOG_DIR/NAME.log` (default `/tmp/monitor`)
  so the path is predictable. Without it the name is derived from the command
  plus a timestamp.
- `--status [NAME]` prints whether the run is alive, how long since the last
  write, and the tail. Run it from a second shell to check on a run in flight.
- `--stall-abort SECS` kills a command that has gone silent that long, so the
  call returns with a reason instead of consuming the whole timeout.
- `--tty` when the command manages its own output buffering. `stdbuf` only
  reaches libc buffering, so Python, Go, and Rust programs write nothing to the
  log until they exit and will otherwise trip false stall warnings.
- `--split` also writes `.out` and `.err`. The combined log's ordering becomes
  approximate when this is on; leave it off unless stdout needs parsing alone.
