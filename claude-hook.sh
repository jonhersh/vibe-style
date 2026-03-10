#!/usr/bin/env bash
# vibe-style Claude Code hook — classifies what CC is working on and sets tab title.
# Reads tool_name + tool_input JSON from stdin on PreToolUse/PostToolUse.
# Persists detected task type to a temp file so it survives between hook calls.
#
# Tab icons per state (from README):
#   SessionStart  → ⚡ (started)
#   PostToolUse   → ⚡ (cooking)
#   Stop          → ✅ (done, your turn)
#   Notification  → 🔥 (needs input)

STATE_FILE="/tmp/vs-claude-task-${PPID}"

# ── TTY discovery ──────────────────────────────────────────────────────────
_vs_find_tty() {
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
  local label="$1"
  local tty=""
  tty=$(_vs_find_tty) || return
  # Set immediately
  printf '\033]0;%s\007' "$label" > "$tty"
  # Repeatedly re-assert to overwrite Claude Code's own title changes
  # (CC sends OSC title updates after the hook returns)
  {
    sleep 0.15 && printf '\033]0;%s\007' "$label" > "$tty"
    sleep 0.2  && printf '\033]0;%s\007' "$label" > "$tty"
    sleep 0.3  && printf '\033]0;%s\007' "$label" > "$tty"
    sleep 0.5  && printf '\033]0;%s\007' "$label" > "$tty"
  } &
}

# ── Get current task from state file ───────────────────────────────────────
_get_current_task() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo ""
  fi
}

# ── Classify from file path ────────────────────────────────────────────────
_classify_path() {
  local p="$1"
  case "$p" in
    # Frontend
    */costseg-site/*|*site/*|*frontend/*|*web/*|*ui/*)
      case "$p" in
        */portal/*)            echo "portal-frontend" ;;
        */str/*|*/calculator*) echo "str-calculator" ;;
        */blog/*)              echo "blog" ;;
        *.css|*style*)         echo "styling" ;;
        *)                     echo "frontend" ;;
      esac ;;

    # Backend
    */report-service/*|*backend/*|*api/*|*server/*)
      case "$p" in
        *test*|*spec*)              echo "testing" ;;
        *generate_report*|*pdf*)    echo "pdf-generation" ;;
        *costseg_engine*|*engine*)  echo "engine" ;;
        *narrative*|*gpt*|*openai*) echo "ai-integration" ;;
        *stripe*|*payment*|*webhook*) echo "payments" ;;
        *email*|*resend*|*sequence*) echo "email" ;;
        *portal*|*partner*)         echo "cpa-portal" ;;
        *land_val*|*property*|*enrichment*) echo "property-data" ;;
        *qc*|*valid*)               echo "qc-validation" ;;
        *route*|*app.py*|*endpoint*) echo "api-routes" ;;
        *s3*|*storage*)             echo "storage" ;;
        *)                          echo "backend" ;;
      esac ;;

    # Marketing
    */marketing/*|*/outreach/*|*/campaign/*)
      case "$p" in
        *email*|*drip*|*sequence*) echo "email-marketing" ;;
        *cpa*|*partner*)           echo "cpa-outreach" ;;
        *video*|*script*)          echo "video-content" ;;
        *)                         echo "marketing" ;;
      esac ;;

    # Worker / DevOps
    */stripe-worker/*|*/worker/*|*wrangler*|*Dockerfile*|*railway*|*deploy*)
      echo "devops" ;;

    # Scripts / Tooling
    */scripts/*)
      case "$p" in
        *batch*|*eval*|*calibrat*) echo "calibration" ;;
        *test*)                    echo "testing" ;;
        *fit*|*param*)             echo "tuning" ;;
        *)                         echo "scripting" ;;
      esac ;;

    # Data
    */data/*|*.json|*.csv|*.jsonl)
      case "$p" in
        *fixture*|*batch*|*golden*) echo "test-data" ;;
        *cost_ind*|*metro*|*geo*)   echo "cost-indices" ;;
        *)                          echo "data" ;;
      esac ;;

    # Tests
    */tests/*|*test_*|*_test.*|*spec*)
      echo "testing" ;;

    # Config
    *.env*|*config*|*setting*|*.toml|*requirements*)
      echo "config" ;;

    # Docs
    *.md|*README*|*PRD*|*docs/*)
      echo "docs" ;;

    # Catch-all by extension
    *.py)  echo "backend" ;;
    *.js)  echo "frontend" ;;
    *.html|*.css) echo "frontend" ;;
    *.sh)  echo "scripting" ;;

    *) echo "" ;;
  esac
}

# ── Classify from bash command ─────────────────────────────────────────────
_classify_command() {
  local cmd="$1"
  case "$cmd" in
    *pytest*|*test*|*unittest*|*coverage*)   echo "testing" ;;
    *run_batch*|*eval_qc*|*diff_batch*|*calibrat*) echo "calibration" ;;
    *curl*|*httpie*|*wget*fetch*)            echo "api-testing" ;;
    *pip*|*poetry*|*uv*)                     echo "dependencies" ;;
    *git*push*|*git*deploy*|*wrangler*|*railway*) echo "deploying" ;;
    *git*)                                   echo "git" ;;
    *docker*|*kubectl*)                      echo "devops" ;;
    *python*server*|*uvicorn*|*gunicorn*)    echo "backend" ;;
    *npm*|*node*|*bun*|*yarn*|*pnpm*)        echo "frontend" ;;
    *scrapy*|*beautifulsoup*|*selenium*|*playwright*|*puppeteer*) echo "web-scraping" ;;
    *stripe*)                                echo "payments" ;;
    *resend*|*sendgrid*|*mailchimp*)         echo "email" ;;
    *openai*|*anthropic*|*gpt*)              echo "ai-integration" ;;
    *psql*|*mysql*|*dynamodb*|*mongo*)       echo "database" ;;
    *aws*|*s3*)                              echo "cloud" ;;
    *lint*|*ruff*|*black*|*prettier*|*eslint*) echo "linting" ;;
    *) echo "" ;;
  esac
}

# ── Read + classify from stdin JSON ────────────────────────────────────────
_classify_tool_call() {
  local json=""
  json=$(cat 2>/dev/null) || return

  local tool_name=""
  tool_name=$(echo "$json" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

  local task=""

  case "$tool_name" in
    Read|Edit|Write|Glob)
      local file_path=""
      file_path=$(echo "$json" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"//')
      if [ -z "$file_path" ]; then
        file_path=$(echo "$json" | grep -o '"pattern"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"pattern"[[:space:]]*:[[:space:]]*"//;s/"//')
      fi
      [ -n "$file_path" ] && task=$(_classify_path "$file_path")
      ;;

    Grep)
      local path=""
      path=$(echo "$json" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"path"[[:space:]]*:[[:space:]]*"//;s/"//')
      [ -n "$path" ] && task=$(_classify_path "$path")
      ;;

    Bash)
      local command=""
      command=$(echo "$json" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"//')
      [ -n "$command" ] && task=$(_classify_command "$command")
      ;;

    WebFetch)
      task="web-research"
      ;;

    WebSearch)
      task="web-research"
      ;;

    Agent)
      task="sub-agent"
      ;;

    *)
      task=""
      ;;
  esac

  echo "$task"
}

# ── Main dispatch ──────────────────────────────────────────────────────────
case "${1:-start}" in
  start)
    # Session started — show lightning bolt
    _vs_set_tab "⚡ CC: starting..."
    ;;

  resume)
    # PostToolUse / PreToolUse — Claude is cooking
    task=$(_classify_tool_call)

    # Update state if we got a new classification
    if [ -n "$task" ]; then
      echo "$task" > "$STATE_FILE"
    fi

    # Read current task (may be from this call or a previous one)
    current=$(_get_current_task)
    if [ -n "$current" ]; then
      _vs_set_tab "⚡ $current"
    else
      _vs_set_tab "⚡ CC"
    fi
    ;;

  stop)
    # Claude finished — checkmark, your turn
    current=$(_get_current_task)
    if [ -n "$current" ]; then
      _vs_set_tab "✅ $current"
    else
      _vs_set_tab "✅ done"
    fi
    rm -f "$STATE_FILE" 2>/dev/null
    ;;

  notify)
    # Claude needs your input — fire icon
    current=$(_get_current_task)
    if [ -n "$current" ]; then
      _vs_set_tab "🔥 $current"
    else
      _vs_set_tab "🔥 needs input"
    fi
    ;;
esac
