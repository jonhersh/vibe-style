# 🎸 vibe-style 🎸

### _Because your terminals deserve a soundtrack_ 🎶🕶️

You've got 4 terminals open. You're flipping between them like a DJ switching tracks. Which one's the backend? Which one's grading? You squint. You scroll. You lose 30 seconds of your life you'll never get back.

**Never again.**

```
🔵 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         ⚡ backend ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟠 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         ⚡ grading ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        ⚡ marketing ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟣 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      ⚡ fixing auth bug ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Each terminal gets its own **color**, its own **banner**, its own **vibe**. 🎷

---

## 🎤 What It Does

| Feature | What You Get |
|---------|-------------|
| 🏷️ **Tab rename** | VS Code terminal tab says "⚡ backend" instead of "zsh" |
| 🎨 **Color banner** | Fat colored bar you can't miss when switching terminals |
| 💬 **Prompt tag** | `[backend] $` — always know where you are |
| 🧠 **Smart detect** | Scans your recent files & git diff to auto-tag |

---

## 🚀 Install (30 seconds)

```bash
git clone https://github.com/jonhersh/vibe-style.git ~/vibe-style
bash ~/vibe-style/install.sh
source ~/.zshrc
```

That's it. Now rip a guitar solo. 🎸🔥

---

## 🎹 Usage

```bash
vs backend          # 🔵 blue
vs marketing        # 🟢 green
vs grading          # 🟠 orange
vs data             # 🟣 purple
vs devops           # 🔴 red
vs frontend         # 💜 magenta
vs design           # 🩷 pink
vs research         # 🩵 teal
```

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

## 🧠 Smart Auto-Detect

This is the magic. 🪄

```bash
vs-auto
```

It figures out what you're working on by scanning:

| Signal | Example | Result |
|--------|---------|--------|
| 📁 Directory name | `cd report-service/` | → `backend` 🔵 |
| 📝 Recent files | Touched `.py` files in last 10 min | → `backend` 🔵 |
| 📝 Recent files | Editing `.ipynb` notebooks | → `data` 🟣 |
| 📝 Recent files | Modified `rubric.xlsx` | → `grading` 🟠 |
| 🔀 Git diff | Uncommitted changes to `.html` files | → `frontend` 💜 |
| 🐳 DevOps files | Changed `Dockerfile` or `deploy.yml` | → `devops` 🔴 |

It **scores each category** and picks the winner. Same project, different day, different files — it adapts to what you're _actually doing right now_.

```bash
vs-dir    # fast mode — just checks directory name, no file scanning
```

---

## 🎨 The Full Preset List

```
  🔵 ● backend       — APIs, servers, Python/Go/Rust
  💜 ● frontend      — HTML, CSS, React, Vue
  🟢 ● marketing     — emails, campaigns, copy
  🟠 ● grading       — rubrics, rosters, assignments
  🟣 ● data          — notebooks, pandas, ML
  🔴 ● devops        — Docker, CI/CD, deploys
  🩷 ● design        — assets, Figma, SVGs
  🩵 ● research      — papers, LaTeX, citations
```

Custom labels get a **deterministic color from the text** — so `"fixing auth"` is always the same color. No randomness. Pure vibes. 🎵

---

## 🤖 Claude Code Integration

Auto-style your terminal when you start a Claude Code session:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "vs-auto"
      }
    ]
  }
}
```

Fork a session for backend work → it's blue.
Fork for marketing → it's green.
No thinking required. 🧘

---

## 🎸 Why "vibe-style"?

Because `vs backend` is two keystrokes away from changing your whole terminal mood. It's not just a label — it's a _vibe_.

You wouldn't wear the same outfit to a rock concert and a board meeting. Why should all your terminals look the same? 🕶️

---

## 🖥️ Works In

- ✅ VS Code integrated terminal
- ✅ iTerm2
- ✅ Warp
- ✅ Alacritty / Kitty / any ANSI 256-color terminal

## 📋 Requirements

- zsh (default on macOS)
- A mass quantity of mass vibes 🎷

## 📄 License

MIT — do whatever you want with it. Rock on. 🤘

---

<p align="center">
  <i>🎶 Now go put on some Van Halen and open 5 terminals 🎶</i>
</p>
