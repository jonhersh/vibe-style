#!/usr/bin/env bash
# vibe-style installer — adds source line to .zshrc + configures VS Code

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_LINE="source \"${SCRIPT_DIR}/vibe-style.sh\""

# ── 1. Add to .zshrc ──────────────────────────────────────────────────────────
if grep -qF "vibe-style" ~/.zshrc 2>/dev/null; then
  echo "vibe-style is already in your .zshrc"
else
  echo "" >> ~/.zshrc
  echo "# vibe-style — visual terminal styling" >> ~/.zshrc
  echo "${SOURCE_LINE}" >> ~/.zshrc
  echo "Installed! Added to ~/.zshrc"
  echo "Run: source ~/.zshrc (or open a new terminal)"
fi

# ── 2. Configure VS Code to use terminal-set tab titles ───────────────────────
# This makes VS Code show "⚡ backend" instead of "node" or "zsh" in the tab
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [[ ! -f "$VSCODE_SETTINGS" ]]; then
  # Try Linux path
  VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
fi

if [[ -f "$VSCODE_SETTINGS" ]]; then
  if grep -q '"terminal.integrated.tabs.title"' "$VSCODE_SETTINGS" 2>/dev/null; then
    echo ""
    echo "VS Code: terminal.integrated.tabs.title already set (check it includes \${sequence})"
  else
    # Insert the setting before the last closing brace
    # Use a temp file for portability
    tmp_file="${VSCODE_SETTINGS}.vibe-tmp"
    # Remove trailing whitespace/newlines, then remove the last }
    sed '$ s/}$/,\n  "terminal.integrated.tabs.title": "${sequence} - ${process}",\n  "terminal.integrated.tabs.description": ""\n}/' "$VSCODE_SETTINGS" > "$tmp_file" 2>/dev/null
    if [[ $? -eq 0 && -s "$tmp_file" ]]; then
      mv "$tmp_file" "$VSCODE_SETTINGS"
      echo ""
      echo "VS Code: configured tab titles to show vibe-style labels"
    else
      rm -f "$tmp_file" 2>/dev/null
      echo ""
      echo "VS Code: couldn't auto-configure. Add this to your settings.json:"
      echo '  "terminal.integrated.tabs.title": "${sequence} - ${process}"'
    fi
  fi
else
  echo ""
  echo "VS Code settings not found. To show vibe-style labels in tabs, add to settings.json:"
  echo '  "terminal.integrated.tabs.title": "${sequence} - ${process}"'
fi

echo ""
echo "Usage:"
echo "  vs backend       # style as backend (blue)"
echo "  vs grading       # style as grading (orange)"
echo "  vs \"my task\"     # custom label, auto-color"
echo "  vs off           # clear style"
echo "  vs list          # show all presets"
echo "  vs-auto          # smart auto-detect what you're working on"
