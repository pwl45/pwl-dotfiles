---
alwaysApply: true
---

# Run Long Commands in tmux Windows

For any command that may run for minutes (builds, tests, bazel, nix, docker,
regen, deploys, dev servers, watchers, REPLs), do not run it in the foreground
Bash tool. Start it in a detached, named tmux window in a dedicated
`claude-bg` session, then come back to it only when you need an update.

## Start

```bash
tmux has-session -t claude-bg 2>/dev/null || tmux new-session -d -s claude-bg
tmux new-window -d -t claude-bg -n rebuild \
  'nixos-rebuild switch --flake . ; echo "EXIT:$?"'
```

Give every run a short, stable `-n` name. That name is the handle for peeking,
stopping, and attaching. A tmux window is a pty, so the command line-buffers,
keeps color, and renders progress bars. A run that appears silent is genuinely
silent, not block-buffered into a pipe.

## Check on it

The `EXIT:` line that the command prints at the end is the completion signal.
Its presence is success or failure; its absence means still running.

```bash
tmux capture-pane -p -t claude-bg:rebuild -S -200
```

Do not poll in a loop. Launch the run, continue with other work, and peek only
when you need interim output or want to confirm it finished. Use
`tmux list-windows -t claude-bg -F '#{window_name} #{window_activity}'` to see
what is running.

## Let the user watch

Report the run's window name and, when they want to see it live, give them the
attach command:

```bash
tmux switch-client -t claude-bg   # when already inside tmux
tmux attach -t claude-bg          # otherwise
```

## Stop

```bash
tmux kill-window -t claude-bg:rebuild
```

## Why

Long foreground commands hit the Bash tool timeout and, when their output is
piped into `tail`, give no signal while they run: "still working" and "wedged"
look identical. A log file works around that, but a tmux window is the real
thing: a live pty the agent can capture and the user can attach to. This is the
flow pi recommends, and there is no reason to build a bespoke wrapper for it.
