# DeepSeek TUI - Team Setup Guide

Quick-start guide for our development team. One launcher, three choices, zero command memorization.

---

## 5-Minute Setup (Windows)

### Step 1: Install

Open **PowerShell** as administrator and run:

```powershell
npm install -g deepseek-tui
```

Verify:
```powershell
deepseek --version
```

### Step 2: Get Your API Key

1. Go to https://platform.deepseek.com/api_keys
2. Create a key (or ask your team lead for one)
3. Save it with the CLI:
```powershell
deepseek auth set --provider deepseek
```

### Step 3: Clone This Repo

```powershell
git clone https://github.com/sakimotto/deepseek-tui.git
cd deepseek-tui
```

### Step 4: Launch

```powershell
.\launch.ps1
```

---

## The Launcher - Pick Your Setup

When you run `.\launch.ps1`, you get three simple choices:

```
  ========================================
       DeepSeek TUI Launcher
  ========================================

  Pick a mode:
    1. Plan   - Read-only, explore only
    2. Agent  - Interactive, asks before running
    3. YOLO   - Auto-approve everything (use Docker)

  Pick runtime:
    N. Native  - Instant, no Docker needed
    D. Docker  - Sandboxed, safe for YOLO

  Pick a model:
    A. Auto   - Let DeepSeek choose per turn
    P. Pro    - deepseek-v4-pro (best quality)
    F. Flash  - deepseek-v4-flash (fast and cheap)
```

| What you pick | What happens |
|---------------|-------------|
| 1 + N + A | Plan mode, native, auto model - safe exploration |
| 2 + N + A | Agent mode, native, auto model - daily development |
| 3 + D + P | YOLO mode, Docker sandboxed, Pro model - full autonomy |

---

## Modes Explained

| Mode | Best for | Safety |
|------|----------|--------|
| **Plan** | Exploring code, asking questions, architecture review | Read-only, no changes |
| **Agent** | Day-to-day coding with review | Asks before running tools |
| **YOLO** | Full automation, batch tasks | Auto-approves everything |

> Always use **Docker** runtime with YOLO mode. Docker provides a landlock sandbox that prevents destructive commands from affecting your system.

---

## Runtime: Native vs Docker

| | Native | Docker |
|---|--------|--------|
| Startup | Instant | Needs Docker Desktop running |
| Sandbox | None | Linux landlock isolation |
| Best for | Plan / Agent mode | YOLO mode |
| Windows path | `deepseek` | `docker run --rm -it ...` |

To use Docker mode, install [Docker Desktop](https://www.docker.com/products/docker-desktop/) first.

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Tab` | Cycle mode (Plan -> Agent -> YOLO) |
| `Shift+Tab` | Cycle reasoning effort (off -> high -> max) |
| `F1` | Help overlay |
| `Ctrl+K` | Command palette |
| `Ctrl+R` | Resume previous session |
| `Ctrl+S` | Stash current draft |
| `Esc` | Back / dismiss |
| `@path` | Attach file/directory as context |

---

## Team Tips

### Daily workflow
```powershell
cd your-project
deepseek
```
Then ask: `@README.md explain this to me` or `refactor this function for performance`

### Cost management
- Use `/model auto` to let DeepSeek choose Flash (cheap) vs Pro (powerful) per turn
- Flash costs ~$0.14/M input, Pro costs ~$0.435/M input
- Monitor costs in the TUI footer

### Session persistence
- Sessions auto-save to `~\.deepseek\`
- Resume with `Ctrl+R` or `deepseek --continue`
- Sessions survive restarts

### Troubleshooting
```powershell
deepseek doctor          # Check everything is working
deepseek auth status     # See where your key is stored
deepseek --version       # Check version
```

---

## Lessons Learned

1. **Start with Plan mode** - explore unfamiliar code safely before editing
2. **Use @mentions** - attach files for context (`@src/main.rs summarize this`)
3. **Auto model works well** - the routing call picks the right model 90% of the time
4. **Docker for YOLO only** - the sandbox overhead isn't worth it for daily Agent mode
5. **Session saves are your friend** - if the terminal crashes, your work is safe
6. **Reasoning visibility** - press Shift+Tab to see the model think through complex problems
7. **API key rotation** - use `deepseek auth set` to change keys, never edit config.toml manually

---

## For Team Leads

- Distribute API keys via environment or `deepseek auth set`
- Pre-configure `.env` files per project (never commit them!)
- Consider using `deepseek serve --http` for headless CI/CD agent workflows
- See [docs/TOOL_SURFACE.md](docs/TOOL_SURFACE.md) for the full tool catalog
- See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for internals
