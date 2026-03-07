#!/usr/bin/env bash
# vibe-style installer — adds source line to .zshrc

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_LINE="source \"${SCRIPT_DIR}/vibe-style.sh\""

if grep -qF "vibe-style" ~/.zshrc 2>/dev/null; then
  echo "vibe-style is already in your .zshrc"
else
  echo "" >> ~/.zshrc
  echo "# vibe-style — visual terminal styling" >> ~/.zshrc
  echo "${SOURCE_LINE}" >> ~/.zshrc
  echo "Installed! Added to ~/.zshrc"
  echo "Run: source ~/.zshrc (or open a new terminal)"
fi

echo ""
echo "Usage:"
echo "  vs backend       # style as backend (blue)"
echo "  vs grading       # style as grading (orange)"
echo "  vs \"my task\"     # custom label, auto-color"
echo "  vs off           # clear style"
echo "  vs list          # show all presets"
echo "  vs-auto          # smart auto-detect what you're working on"
