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

# ── Persistent top bar ───────────────────────────────────────────────────────
# Pins a colored status bar to the top row using terminal scroll regions.
# The bar stays visible as you work; content scrolls below it.

_vs_draw_topbar() {
  local tag="$1"
  local color_code="$2"
  local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
  local label="⚡ $tag ⚡"
  local label_len=${#label}
  local pad_left=$(( (cols - label_len) / 2 ))
  local pad_right=$(( cols - label_len - pad_left ))

  # Save cursor, move to row 1 col 1
  printf '\033[s\033[1;1H'
  # Draw the bar across full width
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$pad_left" ''
  printf '%s' "$label"
  printf '%*s' "$pad_right" ''
  printf '\033[0m'
  # Set scroll region to row 2 onward, restore cursor
  printf '\033[2;%dr\033[u' "${LINES:-$(tput lines 2>/dev/null || echo 24)}"
}

_vs_clear_topbar() {
  local lines="${LINES:-$(tput lines 2>/dev/null || echo 24)}"
  # Reset scroll region to full terminal
  printf '\033[1;%dr' "$lines"
  # Clear row 1
  printf '\033[s\033[1;1H\033[2K\033[u'
}

_vs_topbar_precmd() {
  # Redraw the top bar and re-set the tab title before each prompt
  # (handles resizes, clears, and process name overrides in VS Code)
  if [[ -n "$VS_TAG" && -n "$VS_COLOR" ]]; then
    _vs_draw_topbar "$VS_TAG" "$VS_COLOR"
    _vs_set_title "⚡ ${VS_TAG}"
  fi
}

# Register the precmd hook (idempotent)
_vs_install_topbar_hook() {
  # Add to precmd_functions if not already there
  if [[ ${precmd_functions[(ie)_vs_topbar_precmd]} -gt ${#precmd_functions} ]]; then
    precmd_functions+=(_vs_topbar_precmd)
  fi
}

_vs_remove_topbar_hook() {
  precmd_functions=(${precmd_functions:#_vs_topbar_precmd})
}

_vs_install_topbar_hook

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
      _vs_clear_topbar
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
      _vs_draw_topbar "$tag" "$color_code"
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

# ── Learning mode 🎶 ────────────────────────────────────────────────────────
# Hook-driven: preexec captures commands, precmd evaluates scores with decay.
# No background processes. No polling. Just zsh hooks.

zmodload zsh/datetime 2>/dev/null

# State arrays — each entry is "timestamp category weight"
typeset -a _VS_LEARN_EVENTS=()
_VS_LEARN_ACTIVE=false
_VS_LEARN_LAST_EVAL=0
_VS_LEARN_RT_SIGNALS=0  # count of real-time (non-snapshot) signals

_vs_learning_banner() {
  local width=60
  local msg="tuning up..."
  local pad_total=$(( width - ${#msg} - 4 ))
  local pad_left=$(( pad_total / 2 ))
  local pad_right=$(( pad_total - pad_left ))

  printf '\n'
  printf '\033[48;5;240m\033[38;5;252m\033[1m'
  printf '%*s' "$width" '' | tr ' ' '~'
  printf '\033[0m\n'
  printf '\033[48;5;240m\033[38;5;252m\033[1m'
  printf '%*s' "$pad_left" ''
  printf '🎸 %s 🎸' "$msg"
  printf '%*s' "$pad_right" ''
  printf '\033[0m\n'
  printf '\033[48;5;240m\033[38;5;252m\033[1m'
  printf '%*s' "$width" '' | tr ' ' '~'
  printf '\033[0m\n'
  printf '\033[2m  listening to your workflow...\033[0m\n'
  printf '\n'
}

_vs_song_learned() {
  local tag="$1"
  local color_code="$2"
  local width=60
  local msg="song learned! → $tag"
  local pad_total=$(( width - ${#msg} - 4 ))
  local pad_left=$(( pad_total / 2 ))
  local pad_right=$(( pad_total - pad_left ))

  printf '\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$width" '' | tr ' ' '━'
  printf '\033[0m\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$pad_left" ''
  printf '🎶 %s 🎶' "$msg"
  printf '%*s' "$pad_right" ''
  printf '\033[0m\n'
  printf '\033[48;5;%sm\033[38;5;15m\033[1m' "$color_code"
  printf '%*s' "$width" '' | tr ' ' '━'
  printf '\033[0m\n'
  printf '\n'
}

# Classify a command string → "category weight" (or empty if unrecognized)
_vs_learn_classify_cmd() {
  local cmd="$1"
  local base="${cmd%% *}"

  case "$base" in
    # Backend commands (weight 4)
    python|python3|pip|pip3|pipenv|poetry|uvicorn|gunicorn|flask|django-admin|manage.py)
      echo "backend 4" ;;
    go|cargo|rustc|javac|java|gradle|mvn|ruby|rails|bundle|rake)
      echo "backend 4" ;;
    pytest|mypy|ruff|black|isort|flake8)
      echo "backend 4" ;;

    # Frontend commands (weight 4)
    npm|npx|yarn|pnpm|bun|vite|next|nuxt|gatsby|astro)
      echo "frontend 4" ;;
    tsc|eslint|prettier|stylelint|postcss|tailwindcss)
      echo "frontend 4" ;;

    # DevOps commands (weight 4)
    docker|docker-compose|kubectl|helm|terraform|ansible|vagrant)
      echo "devops 4" ;;
    wrangler|railway|vercel|netlify|flyctl|heroku)
      echo "devops 4" ;;

    # Data science commands (weight 4)
    jupyter|ipython|conda|mamba|dvc|mlflow)
      echo "data 4" ;;
    Rscript|R)
      echo "data 4" ;;

    # Research commands (weight 4)
    pdflatex|xelatex|bibtex|pandoc|zotero)
      echo "research 4" ;;

    # Editors — classify by file extension (weight 3)
    vim|nvim|vi|nano|emacs|code|subl|mate)
      local args="${cmd#* }"
      case "$args" in
        *.py|*.go|*.rs|*.rb|*.java)      echo "backend 3" ;;
        *.html|*.css|*.jsx|*.tsx|*.vue|*.svelte) echo "frontend 3" ;;
        *.ipynb)                          echo "data 3" ;;
        *.tex|*.bib)                      echo "research 3" ;;
        *.tf|*.yml|*.yaml|Dockerfile*)    echo "devops 3" ;;
        *.md|*.txt)
          case "$args" in
            *marketing*|*email*|*campaign*) echo "marketing 3" ;;
            *grade*|*rubric*|*syllabus*)    echo "grading 3" ;;
            *)                              ;; # ambiguous, skip
          esac ;;
        *) ;; # can't tell from editor alone
      esac ;;

    # Git — classify by what's in the diff
    git)
      case "$cmd" in
        *add*|*commit*|*push*|*pull*|*merge*|*rebase*|*stash*)
          ;; # too generic, skip
        *) ;; # skip other git subcommands
      esac ;;

    # Cat/less — classify by target file
    cat|less|head|tail|bat)
      local args="${cmd#* }"
      case "$args" in
        *.py|*.go|*.rs|*.rb)              echo "backend 2" ;;
        *.html|*.css|*.jsx|*.tsx)          echo "frontend 2" ;;
        *.ipynb)                          echo "data 2" ;;
        *marketing*|*email*|*campaign*)   echo "marketing 2" ;;
        *grade*|*rubric*)                 echo "grading 2" ;;
      esac ;;

    # Make/task runners — try to infer from target
    make)
      case "$cmd" in
        *test*|*lint*|*build*|*run*|*serve*|*dev*)
          ;; # ambiguous
        *deploy*|*docker*|*push*)
          echo "devops 3" ;;
      esac ;;

    # curl/httpie — likely backend/API work
    curl|http|httpie|wget)
      echo "backend 2" ;;

    # Marketing-specific
    mailchimp|sendgrid|resend)
      echo "marketing 4" ;;

    *) ;; # unrecognized, no signal
  esac
}

# Take a one-time snapshot of static signals
_vs_learn_snapshot() {
  local now=$EPOCHSECONDS

  # 1. Environment variables (weight 3)
  [[ -n "$VIRTUAL_ENV" || -n "$CONDA_DEFAULT_ENV" ]] && \
    _VS_LEARN_EVENTS+=("$now backend 3")
  [[ -n "$NODE_ENV" || -n "$NVM_DIR" ]] && \
    _VS_LEARN_EVENTS+=("$now frontend 3")

  # 2. Active processes listening on ports (weight 3)
  local procs=""
  procs=$(lsof -iTCP -sTCP:LISTEN -P 2>/dev/null | tail -n +2)
  if [[ -n "$procs" ]]; then
    echo "$procs" | grep -qiE '(uvicorn|gunicorn|flask|django|python|ruby|rails|java)' && \
      _VS_LEARN_EVENTS+=("$now backend 3")
    echo "$procs" | grep -qiE '(node|next|vite|webpack|esbuild|bun)' && \
      _VS_LEARN_EVENTS+=("$now frontend 3")
  fi

  # 3. Config file presence (weight 2)
  [[ -f "requirements.txt" || -f "Pipfile" || -f "pyproject.toml" || -f "setup.py" || -f "Cargo.toml" || -f "go.mod" || -f "Gemfile" ]] && \
    _VS_LEARN_EVENTS+=("$now backend 2")
  [[ -f "package.json" || -f "tsconfig.json" || -f "vite.config.ts" || -f "next.config.js" || -f "tailwind.config.js" ]] && \
    _VS_LEARN_EVENTS+=("$now frontend 2")
  [[ -f "Dockerfile" || -f "docker-compose.yml" || -f "wrangler.toml" || -f "terraform.tf" ]] && \
    _VS_LEARN_EVENTS+=("$now devops 2")
  [[ -f "environment.yml" || -f "setup.cfg" ]] && \
    _VS_LEARN_EVENTS+=("$now data 2")

  # 4. Directory name (weight 3)
  local dir="$(basename "$PWD")"
  local parent="$(basename "$(dirname "$PWD")")"
  local combined="$dir $parent"
  case "$combined" in
    *backend*|*api*|*server*|*service*) _VS_LEARN_EVENTS+=("$now backend 3") ;;
    *site*|*frontend*|*web*|*ui*)       _VS_LEARN_EVENTS+=("$now frontend 3") ;;
    *marketing*|*email*|*outreach*)     _VS_LEARN_EVENTS+=("$now marketing 3") ;;
    *grad*|*course*|*teaching*|*hw*)    _VS_LEARN_EVENTS+=("$now grading 3") ;;
    *data*|*analysis*|*notebook*)       _VS_LEARN_EVENTS+=("$now data 3") ;;
    *infra*|*deploy*|*devops*|*worker*) _VS_LEARN_EVENTS+=("$now devops 3") ;;
    *design*|*figma*|*assets*)          _VS_LEARN_EVENTS+=("$now design 3") ;;
    *research*|*paper*|*lit*)           _VS_LEARN_EVENTS+=("$now research 3") ;;
  esac

  # 5. Recent shell history — last 15 commands (weight 1 each)
  local hist_line
  fc -l -15 -1 2>/dev/null | while read -r _ hist_line; do
    local result
    result=$(_vs_learn_classify_cmd "$hist_line")
    if [[ -n "$result" ]]; then
      local cat="${result% *}"
      _VS_LEARN_EVENTS+=("$now $cat 1")
    fi
  done
}

# preexec hook — fires on every command
_vs_learn_preexec() {
  [[ "$_VS_LEARN_ACTIVE" != true ]] && return

  local cmd="$1"
  local result
  result=$(_vs_learn_classify_cmd "$cmd")
  if [[ -n "$result" ]]; then
    local cat="${result% *}"
    local weight="${result#* }"
    _VS_LEARN_EVENTS+=("$EPOCHSECONDS $cat $weight")
    (( _VS_LEARN_RT_SIGNALS++ ))
  fi
}

# precmd hook — evaluate scores (throttled to every 5s)
_vs_learn_evaluate() {
  [[ "$_VS_LEARN_ACTIVE" != true ]] && return

  local now=$EPOCHSECONDS
  # Throttle: skip if less than 5s since last eval
  (( now - _VS_LEARN_LAST_EVAL < 5 )) && return
  _VS_LEARN_LAST_EVAL=$now

  # Prune events older than 10 minutes
  local cutoff=$(( now - 600 ))
  local -a pruned=()
  local entry
  for entry in "${_VS_LEARN_EVENTS[@]}"; do
    local ts="${entry%% *}"
    (( ts >= cutoff )) && pruned+=("$entry")
  done
  _VS_LEARN_EVENTS=("${pruned[@]}")

  # Compute decayed scores per category
  # Half-life = 120s → decay = 0.5^(age/120)
  local -A scores=()
  for entry in "${_VS_LEARN_EVENTS[@]}"; do
    local ts="${entry%% *}"
    local rest="${entry#* }"
    local cat="${rest% *}"
    local weight="${rest#* }"
    local age=$(( now - ts ))

    # Decay: approximate 0.5^(age/120) using integer math
    # For age 0-30s: factor=100, 30-90s: 80, 90-180s: 50, 180-360s: 25, 360+: 12
    local factor
    if (( age < 30 )); then
      factor=100
    elif (( age < 90 )); then
      factor=80
    elif (( age < 180 )); then
      factor=50
    elif (( age < 360 )); then
      factor=25
    else
      factor=12
    fi

    local decayed=$(( weight * factor ))
    scores[$cat]=$(( ${scores[$cat]:-0} + decayed ))
  done

  # Find winner and runner-up
  local winner="" winner_score=0 runner_score=0
  local cat
  for cat in ${(k)scores}; do
    if (( scores[$cat] > winner_score )); then
      runner_score=$winner_score
      winner_score=${scores[$cat]}
      winner="$cat"
    elif (( scores[$cat] > runner_score )); then
      runner_score=${scores[$cat]}
    fi
  done

  # Lock-in: winner >= 1500 (15 * 100), leads by >= 500 (5 * 100), at least 2 RT signals
  if (( winner_score >= 1500 && (winner_score - runner_score) >= 500 && _VS_LEARN_RT_SIGNALS >= 2 )); then
    # Determine color
    local color_code
    if [[ -n "${VS_COLORS[$winner]}" ]]; then
      color_code=$(_vs_color_code "${VS_COLORS[$winner]}")
    else
      color_code=$(_vs_hash_color "$winner")
    fi

    # Song learned!
    _vs_song_learned "$winner" "$color_code"
    _vs_play "shred-run.wav"

    # Apply the style
    VS_TAG="$winner"
    VS_COLOR="$color_code"
    _vs_set_title "⚡ ${winner}"
    _vs_draw_topbar "$winner" "$color_code"
    _vs_set_prompt "$winner" "$color_code"

    # Stop learning
    vs-learn-stop
  fi
}

vs-learn() {
  # Stop any previous learning session
  vs-learn-stop 2>/dev/null

  # Reset state
  _VS_LEARN_EVENTS=()
  _VS_LEARN_ACTIVE=true
  _VS_LEARN_LAST_EVAL=0
  _VS_LEARN_RT_SIGNALS=0

  # Show the tuning banner
  _vs_learning_banner
  _vs_set_title "🎸 tuning up..."

  # Take a one-time snapshot of static signals
  _vs_learn_snapshot

  # Install hooks (idempotent)
  if [[ ${preexec_functions[(ie)_vs_learn_preexec]} -gt ${#preexec_functions} ]]; then
    preexec_functions+=(_vs_learn_preexec)
  fi
  if [[ ${precmd_functions[(ie)_vs_learn_evaluate]} -gt ${#precmd_functions} ]]; then
    precmd_functions+=(_vs_learn_evaluate)
  fi
}

vs-learn-stop() {
  _VS_LEARN_ACTIVE=false
  # Remove hooks
  preexec_functions=(${preexec_functions:#_vs_learn_preexec})
  precmd_functions=(${precmd_functions:#_vs_learn_evaluate})
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

# ── Guitar alerts 🎸 ────────────────────────────────────────────────────────
# Play guitar riffs as terminal alerts. Uses afplay (macOS) with bundled tones.

VS_SOUNDS_DIR="${0:A:h}/sounds"
VS_ALERT_ENABLED=true

_vs_play() {
  local sound_file="$VS_SOUNDS_DIR/$1"
  if [[ -f "$sound_file" ]] && command -v afplay &>/dev/null; then
    afplay -v 0.1 "$sound_file" &>/dev/null &
  fi
}

# Play a specific riff or a random one
vs-riff() {
  local riff="$1"
  local -a riffs=(power-chord wah-sweep shred-run pinch-harmonic drop-d-chug)

  if [[ -z "$riff" ]]; then
    # Random riff
    riff="${riffs[$((RANDOM % ${#riffs[@]} + 1))]}"
  fi

  _vs_play "${riff}.wav"
}

# Alert — plays a riff when something needs your attention
vs-alert() {
  local msg="${1:-Hey! Over here.}"
  local riff="${2}"

  vs-riff "$riff"
  printf '\033[1;33m🎸 %s\033[0m\n' "$msg"
}

# Play riff when styling (optional — set VS_RIFF_ON_STYLE=true)
VS_RIFF_ON_STYLE=false

# Wrap the original vs to optionally riff on style
_vs_original=$(functions vs)
eval "_vs_inner${_vs_original#vs}"
vs() {
  _vs_inner "$@"
  local ret=$?
  if [[ "$VS_RIFF_ON_STYLE" == true && -n "$1" && "$1" != "off" && "$1" != "list" && "$1" != "now" && "$1" != "help" ]]; then
    vs-riff
  fi
  return $ret
}

# Toggle alerts on/off
vs-mute() { VS_RIFF_ON_STYLE=false; VS_ALERT_ENABLED=false; echo "🔇 Muted."; }
vs-unmute() { VS_RIFF_ON_STYLE=true; VS_ALERT_ENABLED=true; echo "🔊 Unmuted. Let it rip."; }

# ── Claude Code hook helper ──────────────────────────────────────────────────
# Use as a Notification hook — riffs when Claude needs your attention.
#
# Add to .claude/settings.json:
# {
#   "hooks": {
#     "Notification": [
#       { "command": "source ~/vibe-style/vibe-style.sh && vs-riff power-chord" }
#     ]
#   }
# }
#
# Or auto-style on session start:
# {
#   "hooks": {
#     "SessionStart": [
#       { "command": "source ~/vibe-style/vibe-style.sh && vs-auto" }
#     ]
#   }
# }
