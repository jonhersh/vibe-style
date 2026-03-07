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

_vs_set_tab() {
  local emoji="$1"
  local label
  label="$(_vs_detect_dir)"
  local esc
  esc=$(printf '\033]0;%s CC: %s\007' "$emoji" "$label")
  # Try multiple ways to reach the terminal
  if [ -t 1 ]; then
    printf '%s' "$esc"
  elif [ -w /dev/tty ]; then
    printf '%s' "$esc" > /dev/tty
  else
    # Find parent's TTY via ps
    local tty_dev
    tty_dev=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
    if [ -n "$tty_dev" ] && [ "$tty_dev" != "??" ] && [ -w "/dev/$tty_dev" ]; then
      printf '%s' "$esc" > "/dev/$tty_dev"
    else
      # Last resort: output to stdout, hope the runner passes it through
      printf '%s' "$esc"
    fi
  fi
}

case "${1:-start}" in
  start)   _vs_set_tab "⚡" ;;
  stop)    _vs_set_tab "🎸" ;;
  notify)  _vs_set_tab "🔥" ;;
  resume)  _vs_set_tab "⚡" ;;
esac
