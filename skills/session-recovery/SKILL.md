---
name: session-recovery
description: Step-by-step session recovery wizard. Use when a DeepSeek TUI session crashed, the terminal closed unexpectedly, or the user needs to find and restore lost work. Provides exact commands for the user to run outside the TUI.
---

# Session Recovery Skill — Recovery Wizard

## When to activate
- User says "my session crashed", "I lost my chat", "my terminal closed", "how do I get back to where I was"
- User says "resume", "recover", "restore", "continue where I left off"
- User ran `deepseek sessions` and doesn't know which session to pick

## The recovery wizard

### Step 1: List available sessions
```powershell
deepseek sessions
```

Sessions are listed by ID with:
- Message count (more messages = longer conversation = probably the one you want)
- Timestamp (how long ago)
- Session ID (the hash like `1126c9a9`)

### Step 2: Pick the right session
- **Most messages** → probably your main working session
- **"just now"** or **"3m ago"** → the one that just crashed
- If unsure, try the one with the most messages first

### Step 3: Resume it
```powershell
deepseek --resume <SESSION_ID>
```
Example: `deepseek --resume 1126c9a9`

**Do NOT use `deepseek resume --last`** — this fails on Windows due to path formatting differences. Use `--resume` (double-dash flag) with the explicit session ID.

### Step 4: If that doesn't work — continue from workspace
```powershell
cd "path\to\your-project"
deepseek --continue
```

This resumes whatever was last active in that specific project folder.

### Step 5: If nothing works — start fresh, recover git state
```powershell
deepseek
```
When the TUI asks "Resume previous session?", answer **Yes**.

## Recovering lost file changes (git-based recovery)
If DeepSeek TUI was editing files and crashed mid-edit:

```powershell
git status                    # Any modified files?
git stash list                # Any stashed changes?
git reflog                    # Recent HEAD movements
git diff                      # Uncommitted changes still on disk?
```

## Using the DeepSeek TUI built-in rollback
Inside the TUI (after you resume or start fresh):
- `/restore` — list available rollback points
- `/restore <turn>` — roll back to a specific turn
- The TUI creates side-git snapshots (outside your real `.git`) before every turn

## Prevention
To avoid data loss in the future:
1. The `session-saver` skill auto-commits on session start
2. Enable user memory: type `# remember to checkpoint before destructive operations`
3. Use hooks to auto-commit on tool calls (see `docs/CONFIG_TEAM.md`)

## Cheat sheet for the user
| Situation | Command |
|-----------|---------|
| Resume last session | `deepseek --continue` |
| Resume specific session | `deepseek --resume <ID>` |
| List all sessions | `deepseek sessions` |
| Recover git state | `git stash list; git status` |
| Rollback inside TUI | `/restore` |
| Fork a session | `deepseek fork <ID>` |
