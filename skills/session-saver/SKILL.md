---
name: session-saver
description: Automatic checkpoint and session recovery agent. Use when work needs to be saved, when a session might crash, or when resuming from an earlier session. Creates git snapshots, saves work-in-progress, and provides recovery paths. Acts as a file management and safety-net agent.
---

# Session Saver Skill — Auto-Checkpoint & Recovery

## When to activate
- User mentions saving work, checkpoints, backups, or recovering a session
- After significant file edits (3+ files changed or 50+ lines modified)
- Before running potentially destructive commands (schema changes, mass refactors, deletions)
- When the user says "save my work", "checkpoint", or "I'm worried about losing changes"
- When the user's session history shows a previous crash

## Core behaviors

### Auto-save on session start
1. Run `git status --short` to check for dirty state
2. If there are uncommitted changes from a previous session, create a WIP commit:
   ```
   git add -A
   git commit -m "checkpoint: auto-save before session $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
   ```
3. If the repo is clean, note it and continue

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
1. Display the last 3 commit messages
2. Show current `git status`
3. Ask: "Continue from here or restore a previous checkpoint?"
4. If restoring: `git checkout <commit-sha> -- <file>` for specific files, or full reset

## Explicit triggers (the user can say any of these)
- "save my work" → create checkpoint commit
- "checkpoint" → create checkpoint commit
- "what did I do last time" → show recent git log + session summary
- "restore my work" → run recovery flow
- "I lost my changes" → run full recovery flow
- "is my work safe" → verify no uncommitted changes exist
- "commit everything" → add all, commit with descriptive message
- "clean up" → check for temp files, orphaned branches, stash cleanup
