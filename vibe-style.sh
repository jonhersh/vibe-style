#!/usr/bin/env zsh
# vibe-style — visual terminal styling for VS Code
# Source this in your .zshrc: source ~/vibe-style/vibe-style.sh

# ── Color palette (ANSI 256-color) ──────────────────────────────────────────
typeset -A VS_COLORS

# Predefined styles — add your own here
VS_COLORS=(
  backend    "33"    # blue
  frontend   "magenta"
  marketing  "32"    # green
  grading    "208"   # orange
  data       "135"   # purple
  devops     "196"   # red
  design     "213"   # pink
  research   "37"    # teal
)

# ── State ────────────────────────────────────────────────────────────────────
VS_TAG=""
VS_COLOR=""
VS_ORIGINAL_PS1="${VS_ORIGINAL_PS1:-${PS1}}"

# ── Helpers ──────────────────────────────────────────────────────────────────

_vs_color_code() {
  local name="$1"
  case "$name" in
    red)     echo "196" ;;
    green)   echo "32"  ;;
    blue)    echo "33"  ;;
    yellow)  echo "226" ;;
    orange)  echo "208" ;;
    magenta) echo "165" ;;
    purple)  echo "135" ;;
    pink)    echo "213" ;;
    teal)    echo "37"  ;;
    cyan)    echo "51"  ;;
    *)       echo "$name" ;;
  esac
}

_vs_hash_color() {
  # Deterministic color from string hash
  local str="$1"
  local -a palette=(33 32 208 135 196 213 37 51 226 165 172 69 114 174 209)
  local hash=0
  local i
  for (( i=0; i<${#str}; i++ )); do
    hash=$(( (hash * 31 + $(printf '%d' "'${str:$i:1}")) % ${#palette[@]} ))
  done
  echo "${palette[$((hash + 1))]}"
}

_vs_set_title() {
  printf '\033]0;%s\007' "$1"
}

_vs_banner() {
  local tag="$1"
  local color_code="$2"
  local width=60
  local pad_total=$(( width - ${#tag} - 4 ))
  local pad_left=$(( pad_total / 2 ))
  local pad_right=$(( pad_total - pad_left ))

  printf '\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$width" '' | tr ' ' '━'
  printf '\033[0m\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$pad_left" ''
  printf '⚡ %s ⚡' "$tag"
  printf '%*s' "$pad_right" ''
  printf '\033[0m\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$width" '' | tr ' ' '━'
  printf '\033[0m\n'
  printf '\n'
}

_vs_set_prompt() {
  local tag="$1"
  local color_code="$2"

  if [[ -n "$tag" ]]; then
    PS1="%F{$color_code}[$tag]%f ${VS_ORIGINAL_PS1}"
  else
    PS1="${VS_ORIGINAL_PS1}"
  fi
}

# ── Main command ─────────────────────────────────────────────────────────────

vs() {
  local subcmd="$1"

  case "$subcmd" in
    ""|help|-h|--help)
      echo "vibe-style — style your terminal sessions"
      echo ""
      echo "  vs <tag>          Style this terminal (e.g. vs backend)"
      echo "  vs <tag> <color>  Style with a specific color"
      echo "  vs off            Remove styling and restore defaults"
      echo "  vs list           Show predefined styles"
      echo "  vs now            Show current style"
      echo ""
      echo "Presets: backend, frontend, marketing, grading, data, devops, design, research"
      echo "Or use any label: vs \"fixing auth bug\""
      return 0
      ;;

    off|clear|reset)
      VS_TAG=""
      VS_COLOR=""
      _vs_set_title "Terminal"
      _vs_set_prompt "" ""
      echo "Style cleared."
      return 0
      ;;

    list|ls)
      echo "Available styles:"
      local key
      for key in ${(k)VS_COLORS}; do
        local cc=$(_vs_color_code "${VS_COLORS[$key]}")
        printf '  \033[38;5;%sm● %-12s\033[0m\n' "$cc" "$key"
      done
      return 0
      ;;

    now|status)
      if [[ -n "$VS_TAG" ]]; then
        local cc=$(_vs_color_code "$VS_COLOR")
        printf 'Current: \033[38;5;%sm%s\033[0m\n' "$cc" "$VS_TAG"
      else
        echo "No style set. Use: vs <tag>"
      fi
      return 0
      ;;

    *)
      local tag="$subcmd"
      local color="$2"
      local color_code

      if [[ -n "${VS_COLORS[$tag]}" && -z "$color" ]]; then
        color_code=$(_vs_color_code "${VS_COLORS[$tag]}")
      elif [[ -n "$color" ]]; then
        color_code=$(_vs_color_code "$color")
      else
        color_code=$(_vs_hash_color "$tag")
      fi

      VS_TAG="$tag"
      VS_COLOR="$color_code"

      _vs_set_title "⚡ ${tag}"
      _vs_banner "$tag" "$color_code"
      _vs_set_prompt "$tag" "$color_code"

      return 0
      ;;
  esac
}

# ── Smart auto-detect ────────────────────────────────────────────────────────
# Infers what you're working on from: directory name, recent files, git diff,
# file extensions, and running processes. No manual tagging needed.

_vs_detect_context() {
  local scores_backend=0
  local scores_frontend=0
  local scores_marketing=0
  local scores_grading=0
  local scores_data=0
  local scores_devops=0
  local scores_design=0
  local scores_research=0

  # 1. Directory name (strong signal)
  local dir="$(basename "$PWD")"
  local parent="$(basename "$(dirname "$PWD")")"
  case "$dir" in
    *backend*|*api*|*server*|*service*) (( scores_backend += 5 )) ;;
    *site*|*frontend*|*web*|*ui*)       (( scores_frontend += 5 )) ;;
    *marketing*|*email*|*outreach*)     (( scores_marketing += 5 )) ;;
    *grad*|*course*|*teaching*|*hw*)    (( scores_grading += 5 )) ;;
    *data*|*analysis*|*notebook*)       (( scores_data += 5 )) ;;
    *infra*|*deploy*|*devops*|*worker*) (( scores_devops += 5 )) ;;
    *design*|*figma*|*assets*)          (( scores_design += 5 )) ;;
    *research*|*paper*|*lit*)           (( scores_research += 5 )) ;;
  esac

  # 2. Recently modified files (last 10 min) — what are you actually touching?
  local recent_files=""
  recent_files=$(find . -maxdepth 3 -type f -mmin -10 \
    -not -path '*/.git/*' -not -path '*/node_modules/*' \
    -not -path '*/__pycache__/*' -not -path '*/.venv/*' \
    2>/dev/null | head -30)

  if [[ -n "$recent_files" ]]; then
    # Backend signals
    echo "$recent_files" | grep -qiE '\.(py|go|rs|java|rb)$' && (( scores_backend += 3 ))
    echo "$recent_files" | grep -qiE '(app\.py|main\.py|server\.|routes\.|api/)' && (( scores_backend += 2 ))
    echo "$recent_files" | grep -qiE '(requirements|Pipfile|Cargo|go\.mod|Gemfile)' && (( scores_backend += 1 ))

    # Frontend signals
    echo "$recent_files" | grep -qiE '\.(html|css|jsx|tsx|vue|svelte)$' && (( scores_frontend += 3 ))
    echo "$recent_files" | grep -qiE '(index\.html|styles?\.|component)' && (( scores_frontend += 2 ))
    echo "$recent_files" | grep -qiE '(package\.json|vite|webpack|tailwind)' && (( scores_frontend += 1 ))

    # Marketing signals
    echo "$recent_files" | grep -qiE '(marketing|email|campaign|outreach|newsletter|drip)' && (( scores_marketing += 3 ))
    echo "$recent_files" | grep -qiE '(copy|landing|cta|funnel|promo)' && (( scores_marketing += 2 ))

    # Grading signals
    echo "$recent_files" | grep -qiE '(grad|rubric|assignment|syllabus|student|submission|roster)' && (( scores_grading += 4 ))
    echo "$recent_files" | grep -qiE '\.(xlsx|csv)$' && echo "$recent_files" | grep -qiE '(grade|score|roster)' && (( scores_grading += 2 ))

    # Data science signals
    echo "$recent_files" | grep -qiE '\.(ipynb|parquet|feather)$' && (( scores_data += 4 ))
    echo "$recent_files" | grep -qiE '\.(csv|tsv|json)$' && (( scores_data += 1 ))
    echo "$recent_files" | grep -qiE '(pandas|numpy|sklearn|torch|model|train|predict)' && (( scores_data += 2 ))

    # DevOps signals
    echo "$recent_files" | grep -qiE '(Dockerfile|docker-compose|\.yml|\.yaml)$' && (( scores_devops += 3 ))
    echo "$recent_files" | grep -qiE '(terraform|ansible|k8s|helm|ci|deploy|infra|worker)' && (( scores_devops += 2 ))
    echo "$recent_files" | grep -qiE '(wrangler|cloudflare|railway|vercel|netlify)' && (( scores_devops += 2 ))

    # Design signals
    echo "$recent_files" | grep -qiE '\.(svg|png|jpg|jpeg|gif|webp|ico)$' && (( scores_design += 2 ))
    echo "$recent_files" | grep -qiE '\.(sketch|fig|psd|ai)$' && (( scores_design += 4 ))

    # Research signals
    echo "$recent_files" | grep -qiE '\.(tex|bib|pdf)$' && (( scores_research += 3 ))
    echo "$recent_files" | grep -qiE '(paper|abstract|citation|literature|review)' && (( scores_research += 2 ))
  fi

  # 3. Git diff (if in a repo) — what have you changed?
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local git_files=""
    git_files=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null)
    if [[ -n "$git_files" ]]; then
      echo "$git_files" | grep -qiE '\.(py|go|rs|rb)$' && (( scores_backend += 2 ))
      echo "$git_files" | grep -qiE '\.(html|css|jsx|tsx|vue)$' && (( scores_frontend += 2 ))
      echo "$git_files" | grep -qiE '\.(ipynb)$' && (( scores_data += 3 ))
      echo "$git_files" | grep -qiE '(Dockerfile|\.yml|deploy|worker)' && (( scores_devops += 2 ))
      echo "$git_files" | grep -qiE '(marketing|email|campaign)' && (( scores_marketing += 2 ))
    fi
  fi

  # 4. Pick the winner
  local max_score=0
  local winner="$dir"
  local -A all_scores=(
    backend "$scores_backend"
    frontend "$scores_frontend"
    marketing "$scores_marketing"
    grading "$scores_grading"
    data "$scores_data"
    devops "$scores_devops"
    design "$scores_design"
    research "$scores_research"
  )

  local cat
  for cat in ${(k)all_scores}; do
    if (( all_scores[$cat] > max_score )); then
      max_score=$all_scores[$cat]
      winner="$cat"
    fi
  done

  # Only use detected category if score is meaningful (>= 3)
  if (( max_score < 3 )); then
    winner="$dir"
  fi

  echo "$winner"
}

vs-auto() {
  local detected=$(_vs_detect_context)
  vs "$detected"
}

# ── Directory-only auto (faster, no file scanning) ──────────────────────────

vs-dir() {
  local dir="$(basename "$PWD")"
  case "$dir" in
    *backend*|*api*|*server*|*service*)  vs backend ;;
    *site*|*frontend*|*web*|*ui*)        vs frontend ;;
    *marketing*|*email*|*outreach*)      vs marketing ;;
    *grad*|*course*|*teaching*)          vs grading ;;
    *data*|*analysis*|*notebook*)        vs data ;;
    *infra*|*deploy*|*devops*|*worker*)  vs devops ;;
    *)  vs "$dir" ;;
  esac
}
