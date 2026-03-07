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
  printf '\033]0;%s CC: %s\007' "$emoji" "$label"
}

case "${1:-start}" in
  start)   _vs_set_tab "⚡" ;;
  stop)    _vs_set_tab "🔴" ;;
  resume)  _vs_set_tab "⚡" ;;
esac
