# 🎸 vibe-style 🎸

### _Because your terminals deserve a soundtrack_ 🎶🕶️

You've got 4 terminals open. You're flipping between them like a DJ switching tracks. Which one's the backend? Which one's the frontend? Which one's running that migration? You squint. You scroll. You lose 30 seconds of your life you'll never get back.

**Never again.**

```
🔵 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         ⚡ backend ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💜 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        ⚡ frontend ⚡
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         ⚡ devops ⚡
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

It watches your file activity every 10 seconds. The moment it's confident:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                🎶 song learned! → backend 🎶
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Plays a shred riff, locks in the style, and you're off. 🔥

```bash
vs-learn      # default: checks every 10 seconds
vs-learn 5    # impatient: checks every 5 seconds
vs-learn 20   # chill: checks every 20 seconds
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

### Full setup (both hooks)

```json
{
  "hooks": {
    "SessionStart": [
      { "command": "source ~/vibe-style/vibe-style.sh && vs-auto" }
    ],
    "Notification": [
      { "command": "source ~/vibe-style/vibe-style.sh && vs-riff power-chord" }
    ]
  }
}
```

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
  <i>🎶 Now go <a href="https://youtu.be/rK_d5g3pBb8?si=-b9JAP7ChT9subnJ&t=30">through the fire and flames</a> and open 5 terminals 🎶</i>
</p>
