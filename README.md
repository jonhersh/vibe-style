# 🎸 vibe-style 🎸

### _Because your terminals deserve a soundtrack_ 🎶🕶️

You've got 4 terminals open. You're flipping between them like a DJ switching tracks. Which one's the backend? Which one's the frontend? Which one's running that migration? You squint. You scroll. You lose 30 seconds of your life you'll never get back.

**Never again.**

<!-- SCREENSHOT: Replace with a screenshot of 3-4 styled terminals side by side -->
<!-- How to take: open 3+ terminals, run vs backend / vs frontend / vs devops, screenshot the full VS Code window -->
![Multiple styled terminals](screenshots/hero.png)

Each terminal gets its own **color**, its own **banner**, its own **vibe**. 🎷

---

## 🎤 What It Does

| Feature | What You Get |
|---------|-------------|
| 🏷️ **Tab rename** | VS Code terminal tab says "⚡ backend" instead of "zsh" |
| 🎨 **Color banner** | Fat colored bar you can't miss when switching terminals |
| 📌 **Persistent top bar** | Colored status bar pinned to the top of your terminal — always visible |
| 💬 **Prompt tag** | `[backend] $` — always know where you are |
| 🧠 **Smart detect** | Scans your recent files & git diff to auto-tag |

---

## 🚀 Install (30 seconds)

```bash
git clone https://github.com/jonhersh/vibe-style.git ~/vibe-style
bash ~/vibe-style/install.sh
source ~/.zshrc
```

That's it. Now [unleash the fury](https://youtu.be/dmFzT_BtVLk?si=qBrMNaC557dMw6gf&t=271) 🎸🔥

---

## 🎹 Usage

```bash
vs backend          # 🔵 blue
vs frontend         # 💜 magenta
vs devops           # 🔴 red
vs data             # 🟣 purple
vs marketing        # 🟢 green
vs design           # 🩷 pink
vs research         # 🩵 teal
```

<!-- SCREENSHOT: Show a single terminal right after running "vs backend" -->
<!-- How to take: run "vs backend" in a terminal, screenshot showing the banner + top bar + prompt tag -->
![vs backend example](screenshots/vs-backend.png)

### 🎯 Custom labels

```bash
vs "fixing auth"        # auto-assigned color based on text
vs "deploy v2.3"        # same label = same color, every time
vs myproject red        # pick your own color
vs myproject 51         # or use any ANSI 256-color code
```

### 🧹 Controls

```bash
vs off              # clear everything, back to default
vs list             # show all preset styles with colors
vs now              # what's my current style?
```

---

## 📌 Persistent Top Bar

Every `vs` command pins a colored status bar to the **top row** of your terminal. It stays there as you scroll, run commands, and work — you always know which terminal you're in at a glance.

<!-- SCREENSHOT: Show the persistent top bar after scrolling/running some commands -->
<!-- How to take: run "vs backend", then run a few commands so the banner scrolls away but the top bar remains -->
![Persistent top bar](screenshots/top-bar.png)

- The bar redraws automatically on each prompt (survives `clear`, window resizes)
- `vs off` removes the bar and restores normal scrolling

---

## 🧠 Smart Auto-Detect

This is the magic. 🪄

```bash
vs-auto
```

It figures out what you're working on by scanning:

| Signal | Example | Result |
|--------|---------|--------|
| 📁 Directory name | `cd api-server/` | → `backend` 🔵 |
| 📝 Recent files | Touched `.py` files in last 10 min | → `backend` 🔵 |
| 📝 Recent files | Editing `.ipynb` notebooks | → `data` 🟣 |
| 📝 Recent files | Changed `styles.css`, `App.tsx` | → `frontend` 💜 |
| 🔀 Git diff | Uncommitted changes to `.html` files | → `frontend` 💜 |
| 🐳 DevOps files | Changed `Dockerfile` or `deploy.yml` | → `devops` 🔴 |

It **scores each category** and picks the winner. Same project, different day, different files — it adapts to what you're _actually doing right now_.

```bash
vs-dir    # fast mode — just checks directory name, no file scanning
```

### 🎸 Learning Mode

Don't know what you're working on yet? Let vibe-style figure it out in real time.

```bash
vs-learn
```

```
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      🎸 tuning up... 🎸
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  listening to your workflow...
```

It hooks into your shell and watches every command you run — no polling, no background processes. Run `python app.py` and it scores that as backend. Run `npm run dev` and it scores frontend. Recent commands count more (2-minute half-life), so it adapts as your focus shifts.

At startup it also takes a snapshot of your environment (`$VIRTUAL_ENV`, `package.json`, active servers on ports, recent shell history) for a baseline.

The moment it's confident (winner ≥ 15 points, clear lead, at least 2 real-time signals):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                🎶 song learned! → backend 🎶
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Plays a shred riff, locks in the style, and you're off. 🔥

```bash
vs-learn        # start learning
vs-learn-stop   # stop early (hooks removed, no cleanup needed)
```

---

## 🎨 The Full Preset List

```
  🔵 ● backend       — APIs, servers, Python/Go/Rust
  💜 ● frontend      — HTML, CSS, React, Vue
  🔴 ● devops        — Docker, CI/CD, deploys
  🟣 ● data          — notebooks, pandas, ML
  🟢 ● marketing     — emails, campaigns, copy
  🩷 ● design        — assets, Figma, SVGs
  🩵 ● research      — papers, LaTeX, citations
```

Custom labels get a **deterministic color from the text** — so `"fixing auth"` is always the same color. No randomness. Pure vibes. 🎵

---

## 🎸 Guitar Alerts

Your terminal doesn't just look different — it **sounds** different. Bundled synth guitar tones play when you need attention.

```bash
vs-riff                    # play a random riff
vs-riff power-chord        # 🔊 fat E5 power chord
vs-riff shred-run          # 🔊 ascending shred lick
vs-riff pinch-harmonic     # 🔊 squealy harmonic
vs-riff wah-sweep          # 🔊 wah pedal sweep
vs-riff drop-d-chug        # 🔊 palm-muted chug

vs-alert "Deploy done!"    # riff + message
vs-alert "Tests passed!" shred-run  # specific riff + message

vs-unmute                  # riff plays every time you style
vs-mute                    # silence (but why would you)
```

### 🎵 Available riffs

| Riff | Sound | Best for |
|------|-------|----------|
| `power-chord` | Fat distorted E5 | Task complete, deploy done |
| `shred-run` | Fast ascending notes | Tests passing, build success |
| `pinch-harmonic` | Squealy harmonic | Notification, needs input |
| `wah-sweep` | Wah pedal sweep | New session, switching context |
| `drop-d-chug` | Palm-muted chug | Error, something broke |

---

## 🤖 Claude Code Integration

vibe-style was built for Claude Code. Auto-style terminals and get guitar alerts when Claude needs you.

### Auto-style on session start

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "source ~/vibe-style/vibe-style.sh && vs-auto"
      }
    ]
  }
}
```

Fork a session for backend work → it's blue.
Fork for frontend → it's magenta.
No thinking required. 🧘

### 🎸 Riff when Claude needs your attention

```json
{
  "hooks": {
    "Notification": [
      {
        "command": "source ~/vibe-style/vibe-style.sh && vs-riff power-chord"
      }
    ]
  }
}
```

You're in another tab, Claude finishes a task — **POWER CHORD**. You know exactly which terminal and what just happened.

### Full setup (tab icons + guitar alerts)

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/vibe-style/claude-hook.sh start" }] }
    ],
    "PostToolUse": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/vibe-style/claude-hook.sh resume" }] }
    ],
    "Stop": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/vibe-style/claude-hook.sh stop && afplay -v 0.1 ~/vibe-style/sounds/power-chord.wav &" }] }
    ],
    "Notification": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/vibe-style/claude-hook.sh notify && afplay -v 0.1 ~/vibe-style/sounds/pinch-harmonic.wav &" }] }
    ],
    "SubagentStop": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "afplay -v 0.1 ~/vibe-style/sounds/drop-d-chug.wav &" }] }
    ]
  }
}
```

| Hook | Tab icon | Sound | Meaning |
|------|----------|-------|---------|
| `SessionStart` | ⚡ | — | Claude session started |
| `PostToolUse` | ⚡ | — | Claude is working |
| `Stop` | ✅ | power chord | Claude finished, your turn |
| `Notification` | 🔥 | pinch harmonic | Claude needs your input |
| `SubagentStop` | — | drop-d chug | Subagent completed |

---

## 🎸 Why "vibe-style"?

Because `vs backend` is two keystrokes away from changing your whole terminal mood. It's not just a label — it's a _vibe_.

You wouldn't wear the same outfit to a rock concert and a board meeting. Why should all your terminals look the same? 🕶️

---

## 🖥️ Works In

- ✅ VS Code integrated terminal (tab names update automatically — see below)
- ✅ iTerm2
- ✅ Warp
- ✅ Alacritty / Kitty / any ANSI 256-color terminal

### VS Code tab names

The installer auto-configures VS Code to show vibe-style labels in terminal tabs (e.g. "⚡ backend" instead of "node").

> **Requires VS Code 1.86+.** The `${sequence}` variable for terminal tab titles was added in January 2024. If your tabs aren't updating, check your version (**Code → About**) and update from [code.visualstudio.com](https://code.visualstudio.com).

<!-- SCREENSHOT: Show the VS Code terminal tab list with styled names like "⚡ backend", "⚡ frontend" -->
<!-- How to take: open 3+ terminals, style each one, screenshot the tab list on the right side of the terminal panel -->
![VS Code tab names](screenshots/tab-names.png)

If you need to set it manually, add to your VS Code `settings.json` (**Cmd+Shift+P** → "Preferences: Open User Settings (JSON)"):

```json
{
  "terminal.integrated.tabs.title": "${sequence} - ${process}",
  "terminal.integrated.tabs.description": ""
}
```

## 📋 Requirements

- zsh (default on macOS)
- VS Code 1.86+ (for terminal tab names)
- macOS (for `afplay` guitar alerts — sounds are optional on other OSes)
- A mass quantity of mass vibes 🎷

## 📄 License

MIT — do whatever you want with it. Rock on. 🤘

---

<p align="center">
  <i>🎶 Now go <a href="https://youtu.be/rK_d5g3pBb8?si=-b9JAP7ChT9subnJ&t=30">through the fire and flames</a> and open 5 terminals 🎶</i>
</p>
