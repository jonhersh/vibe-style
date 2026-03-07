#!/usr/bin/env bash
# vibe-style Claude Code hook — sets terminal tab title based on project context
# Bash-compatible (no zsh features). Used by Claude Code hooks.

_vs_detect_dir() {
  local dir
  dir="$(basename "$PWD")"
  case "$dir" in
    *backend*|*api*|*server*|*service*) echo "backend" ;;
    *site*|*frontend*|*web*|*ui*)       echo "frontend" ;;
    *marketing*|*email*|*outreach*)     echo "marketing" ;;
    *grad*|*course*|*teaching*|*hw*)    echo "grading" ;;
    *data*|*analysis*|*notebook*)       echo "data" ;;
    *infra*|*deploy*|*devops*|*worker*) echo "devops" ;;
    *design*|*figma*|*assets*)          echo "design" ;;
    *research*|*paper*|*lit*)           echo "research" ;;
    *seg*|*cost*)                       echo "backend" ;;
    *)                                  echo "$dir" ;;
  esac
}

_vs_find_tty() {
  # Walk the process tree upward to find a TTY
  local pid="$$"
  local tty_dev=""
  while [ -n "$pid" ] && [ "$pid" != "0" ] && [ "$pid" != "1" ]; do
    tty_dev=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$tty_dev" ] && [ "$tty_dev" != "??" ]; then
      echo "/dev/$tty_dev"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

_vs_set_tab() {
  local emoji="$1"
  local label
  label="$(_vs_detect_dir)"
  local esc
  esc=$(printf '\033]0;%s CC: %s\007' "$emoji" "$label")

  # Try direct output first
  if [ -t 1 ]; then
    printf '%s' "$esc"
    return
  fi

  if [ -w /dev/tty ] && { printf '%s' "$esc" > /dev/tty; } 2>/dev/null; then
    return
  fi

  # Walk process tree to find the terminal
  local tty_path
  tty_path=$(_vs_find_tty)
  if [ -n "$tty_path" ] && [ -w "$tty_path" ]; then
    printf '%s' "$esc" > "$tty_path"
    return
  fi

  # Last resort: stdout
  printf '%s' "$esc"
}

case "${1:-start}" in
  start)   _vs_set_tab "⚡" ;;   # session started, Claude working
  stop)    _vs_set_tab "✅" ;;   # Claude finished, waiting for you
  notify)  _vs_set_tab "🔥" ;;   # Claude needs your attention NOW
  resume)  _vs_set_tab "⚡" ;;   # Claude working again after tool use
esac
