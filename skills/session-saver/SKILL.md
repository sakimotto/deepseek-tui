---
name: session-saver
description: Automatic checkpoint and session recovery agent. Use when work needs to be saved, when a session might crash, or when resuming from an earlier session. Creates git snapshots, saves work-in-progress, provides recovery paths, and auto-detects HANDOVER.md from previous sessions. Acts as a file management and safety-net agent.
---

# Session Saver Skill — Auto-Checkpoint, Recovery & Multi-PC Resume

## When to activate
- User mentions saving work, checkpoints, backups, or recovering a session
- After significant file edits (3+ files changed or 50+ lines modified)
- Before running potentially destructive commands (schema changes, mass refactors, deletions)
- When the user says "save my work", "checkpoint", or "I'm worried about losing changes"
- When the user's session history shows a previous crash
- **AUTOMATICALLY on session start** — check for HANDOVER.md

---

## Multi-PC Resume (runs automatically on session start)

### Step 1: Git pull to catch up from other PCs
```powershell
git pull origin main --rebase
```
If this fails (no network, no remote), skip gracefully — the session still works locally.
If there are conflicts, abort rebase and flag them.

### Step 2: Check for HANDOVER.md
Look for `HANDOVER.md` in the project root. If it exists:
1. Read the first 80 lines
2. Extract: date, session summary, active tasks, outstanding work, priority items
3. Present a compact summary to the user:

```
📋 Handover detected from [date] ([time ago])

✅ Accomplished:
- [item 1]
- [item 2]
- [item 3]

⏳ Still in progress:
- [ ] [high-priority item 1]
- [ ] [medium-priority item 2]

📊 [N] tasks documented, [M] pending

Continue from here? (y/n)
```

If user says YES: load the full HANDOVER.md context and pick up the work.
If user says NO: note it and start fresh, but keep HANDOVER.md for reference.
If user says "summarize" or "what was I doing": re-read and present the full outstanding work list.

### Step 3: If no HANDOVER.md but there's uncommitted work
```
⚠️ Found uncommitted changes from a previous session:
[list of dirty files]

Save these as a checkpoint commit? (y/n)
```

### Step 4: If everything is clean and no handover
Start normally. No special action needed.

---

## Core behaviors

### Auto-save on session start
1. Run `git status --short` to check for dirty state
2. If there are uncommitted changes from a previous session, create a WIP commit:
   ```
   git add -A
   git commit -m "checkpoint: auto-save before session $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
   ```
3. If the repo is clean, note it and continue
4. **Always do this BEFORE checking HANDOVER.md** — capture any uncommitted work first

### Checkpoint during work
When the user asks to checkpoint, or after every significant edit cycle:
1. `git add -A`
2. `git commit -m "checkpoint: <brief description of what was done>"`
3. Confirm the commit SHA and brief summary

### Crash recovery
When the user says a session crashed or they need to recover work:
1. First, check: `git stash list` — is there stashed work?
2. Check: `git log --oneline -10` — find checkpoint commits
3. Check for orphaned work: `git fsck --lost-found`
4. If files are modified but not committed: `git stash push -m "recovery-stash-$(date -u +%Y%m%d-%H%M%S)"`
5. Report what was found and ask the user what to restore

### File management (the "file management agent")
1. Every time you write or edit a file, note the path and what changed
2. Keep a running summary of files touched this session
3. Before the user says "I'm done", ask: "Should I commit these changes?"
4. Never leave the working tree dirty without warning the user

### Resume wizard
When resuming a session:
1. **First: Run Multi-PC Resume flow above** (git pull + HANDOVER.md check)
2. Display the last 3 commit messages
3. Show current `git status`
4. If HANDOVER.md exists: "Continue from handoff or start fresh?"
5. If no HANDOVER.md: "Continue from here or restore a previous checkpoint?"
6. If restoring: `git checkout <commit-sha> -- <file>` for specific files, or full reset

---

## Multi-PC Workflow Integration

This skill works together with the `handoff` skill:

**Ending a session:**
- User says "logoff" → handoff skill runs → writes HANDOVER.md → commits → pushes to origin
- HANDOVER.md is now on GitHub

**Starting on any PC (home, work, laptop):**
- User opens terminal, `cd` to project
- User runs `deepseek --continue`
- **session-saver activates automatically**:
  1. Git pull (gets HANDOVER.md + latest code from other PC)
  2. Detects HANDOVER.md
  3. Presents summary: "Here's where you left off..."
  4. User confirms → work continues seamlessly

**Key rule:** This only works if the `handoff` skill's push succeeded. If push failed on the previous PC, this PC won't see HANDOVER.md. In that case, fall back to normal resume.

---

## Explicit triggers (the user can say any of these)
- "save my work" → create checkpoint commit
- "checkpoint" → create checkpoint commit
- "what did I do last time" → show recent git log + HANDOVER.md if exists
- "what was I working on" → check HANDOVER.md, show active tasks
- "restore my work" → run recovery flow
- "I lost my changes" → run full recovery flow
- "is my work safe" → verify no uncommitted changes exist
- "commit everything" → add all, commit with descriptive message
- "clean up" → check for temp files, orphaned branches, stash cleanup

## End-of-session handoff
When the user signals they're done working ("logoff", "hand over", "wrap up", "I'm done", "switch computers"), **delegate to the `handoff` skill** — it creates a comprehensive HANDOVER.md, aggregates sub-agent state, commits all work, runs a MANDATORY push to origin, and gives the next agent clear instructions for any PC.

To activate: `load_skill name=handoff`
