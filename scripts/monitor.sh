#!/usr/bin/env bash
# Run a command with its output captured to a named log file, warning on stdout
# whenever the log goes quiet for longer than the stall threshold.
#
# The log path is printed before the command starts and again on completion, so
# a stalled run is diagnosable from another shell (last line + mtime) while it is
# still going. Exit status is preserved and also written to <log>.exit.

set -uo pipefail

prog=monitor

log_dir=${MONITOR_LOG_DIR:-/tmp/monitor}
name=""
path=""
background=0
split=0
use_tty=0
follow=0
stall_warn=120
stall_abort=0
tail_lines=20
action=run
ref=""

die() {
  printf '%s: %s\n' "$prog" "$*" >&2
  exit 2
}

usage() {
  cat <<'EOF'
Usage:
  monitor [options] <command> [args...]
  monitor --status [NAME|PATH]
  monitor --list

Options:
  --name NAME        log at $MONITOR_LOG_DIR/NAME.log (stable, overwritten)
  --path PATH        log at exactly PATH
  --dir DIR          base directory for logs (default /tmp/monitor)
  --bg               detach and print the log path immediately
  --split            also write NAME.out and NAME.err alongside the combined log
  --tty              give the command a pty, keeping progress bars and colour
  --follow           also stream output to stdout
  --stall-warn SECS  warn after this much silence, doubling each time (0 off, default 120)
  --stall-abort SECS kill the command after this much silence (0 off, default 0)
  --tail N           lines of log to print on completion (default 20)
EOF
}

while (($#)); do
  case $1 in
    --name) name=${2:?--name needs a value}; shift 2 ;;
    --path) path=${2:?--path needs a value}; shift 2 ;;
    --dir) log_dir=${2:?--dir needs a value}; shift 2 ;;
    --bg) background=1; shift ;;
    --split) split=1; shift ;;
    --tty) use_tty=1; shift ;;
    --follow) follow=1; shift ;;
    --stall-warn) stall_warn=${2:?--stall-warn needs a value}; shift 2 ;;
    --stall-abort) stall_abort=${2:?--stall-abort needs a value}; shift 2 ;;
    --tail) tail_lines=${2:?--tail needs a value}; shift 2 ;;
    --status)
      action=status
      if [[ -n ${2-} && $2 != -* ]]; then ref=$2; shift 2; else shift; fi
      ;;
    --list) action=list; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) die "unknown option: $1 (use -- before a command starting with -)" ;;
    *) break ;;
  esac
done

mkdir -p "$log_dir"

# Human-readable duration: 95 -> 1m35s
fmt_dur() {
  local s=$1
  if ((s < 60)); then
    printf '%ds' "$s"
  elif ((s < 3600)); then
    printf '%dm%02ds' $((s / 60)) $((s % 60))
  else
    printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  fi
}

resolve_log() {
  local ref=$1
  if [[ -z $ref ]]; then
    find "$log_dir" -maxdepth 1 -name '*.log' -printf '%T@ %p\n' 2>/dev/null |
      sort -rn | head -1 | cut -d' ' -f2-
  elif [[ $ref == */* || -f $ref ]]; then
    printf '%s\n' "$ref"
  else
    printf '%s\n' "$log_dir/${ref%.log}.log"
  fi
}

if [[ $action == list ]]; then
  ls -lt --time-style=+%Y-%m-%d\ %H:%M:%S "$log_dir"/*.log 2>/dev/null || echo "no logs in $log_dir"
  exit 0
fi

if [[ $action == status ]]; then
  log_file=$(resolve_log "$ref")
  [[ -n $log_file && -f $log_file ]] || die "no log found for '$ref'"
  now=$(date +%s)
  mtime=$(stat -c %Y "$log_file")
  printf 'log:    %s\n' "$log_file"
  printf 'size:   %s bytes, last write %s ago\n' "$(stat -c %s "$log_file")" "$(fmt_dur $((now - mtime)))"
  if [[ -f $log_file.exit ]]; then
    printf 'state:  finished (exit %s)\n' "$(cat "$log_file.exit")"
  elif [[ -f $log_file.pid ]] && kill -0 "$(cat "$log_file.pid")" 2>/dev/null; then
    printf 'state:  running (pid %s)\n' "$(cat "$log_file.pid")"
  else
    printf 'state:  gone (no exit file, process not alive)\n'
  fi
  printf -- '--- last %s lines ---\n' "$tail_lines"
  tail -n "$tail_lines" "$log_file"
  exit 0
fi

(($#)) || { usage >&2; exit 2; }

cmd=("$@")

if [[ -n $path ]]; then
  log_file=$path
elif [[ -n $name ]]; then
  log_file=$log_dir/${name%.log}.log
else
  base=$(basename -- "${cmd[0]}")
  base=${base//[^A-Za-z0-9._-]/_}
  log_file=$log_dir/$base-$(date +%Y%m%d-%H%M%S).log
fi
mkdir -p "$(dirname -- "$log_file")"

out_file=${log_file%.log}.out
err_file=${log_file%.log}.err

# Detach and hand the log path back right away.
if ((background)); then
  args=(--path "$log_file" --stall-warn "$stall_warn" --stall-abort "$stall_abort" --tail "$tail_lines")
  ((split)) && args+=(--split)
  ((use_tty)) && args+=(--tty)
  setsid "$0" "${args[@]}" -- "${cmd[@]}" >"$log_file.monitor" 2>&1 &
  printf '[%s] running in background, log: %s\n' "$prog" "$log_file"
  printf '[%s] check with: monitor --status %s\n' "$prog" "$log_file"
  exit 0
fi

: >"$log_file"
rm -f "$log_file.exit"
((split)) && : >"$out_file" && : >"$err_file"

printf '[%s] log: %s\n' "$prog" "$log_file"

start=$(date +%s)

run_command() {
  if ((use_tty)); then
    # A pty keeps the child line-buffered and preserves progress output.
    script -qefc "$(printf '%q ' "${cmd[@]}")" /dev/null
  else
    # Without stdbuf most programs switch to 4KB blocks when stdout is a file,
    # which would freeze the log and defeat stall detection.
    stdbuf -oL -eL "${cmd[@]}"
  fi
}

if ((split)); then
  if ((follow)); then
    run_command > >(tee -a "$out_file" "$log_file") 2> >(tee -a "$err_file" "$log_file" >&2) &
  else
    run_command > >(tee -a "$out_file" >>"$log_file") 2> >(tee -a "$err_file" >>"$log_file") &
  fi
elif ((follow)); then
  run_command > >(tee -a "$log_file") 2> >(tee -a "$log_file" >&2) &
else
  run_command >"$log_file" 2>&1 &
fi
child=$!
printf '%s\n' "$child" >"$log_file.pid"

kill_tree() {
  pkill -TERM -P "$1" 2>/dev/null || true
  kill -TERM "$1" 2>/dev/null || true
}

trap 'kill_tree "$child"' INT TERM

# Watchdog runs alongside the wait below, so the child is reaped promptly and
# `kill -0` stops succeeding as soon as it exits.
watchdog() {
  local threshold=$stall_warn poll=5 now mtime quiet
  ((stall_warn > 0 && poll > stall_warn)) && poll=$stall_warn
  while kill -0 "$child" 2>/dev/null; do
    sleep "$poll"
    now=$(date +%s)
    mtime=$(stat -c %Y "$log_file" 2>/dev/null || echo "$now")
    quiet=$((now - mtime))
    if ((stall_warn > 0 && quiet >= threshold)); then
      printf '[%s] no output for %s (log: %s)\n' "$prog" "$(fmt_dur "$quiet")" "$log_file"
      threshold=$((threshold * 2))
    fi
    if ((stall_abort > 0 && quiet >= stall_abort)); then
      printf '[%s] aborting: silent for %s\n' "$prog" "$(fmt_dur "$quiet")"
      kill_tree "$child"
      return
    fi
  done
}

watchdog &
watchdog_pid=$!

wait "$child"
rc=$?

kill "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true

printf '%s\n' "$rc" >"$log_file.exit"
rm -f "$log_file.pid"

elapsed=$(($(date +%s) - start))
printf '[%s] exit %s after %s, log: %s\n' "$prog" "$rc" "$(fmt_dur "$elapsed")" "$log_file"
if ((tail_lines > 0)) && [[ -s $log_file ]]; then
  printf -- '--- last %s lines ---\n' "$tail_lines"
  tail -n "$tail_lines" "$log_file"
fi

exit "$rc"
