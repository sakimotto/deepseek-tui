---
name: handoff
description: Session wrap-up and project handover agent. Use when the user says "logoff", "I'm done for today", "hand over", "wrap up", "switch computers", or wants to end a work session cleanly. Creates a HANDOVER.md document, aggregates sub-agent state, commits all remaining work, MANDATORY PUSH to git (so other PCs can pull), and leaves instructions for the next agent session.
---

# Handoff Skill — Clean Session Wrap-Up (Multi-PC Ready)

## When to activate
- User says: "logoff", "I'm done", "wrap up", "hand over", "goodbye", "switch computers", "end session", "close out", "going home"
- User says: "save everything and quit", "push my work", "create handover"
- User says: "I'm switching to my laptop", "continuing on another PC", "moving to my work computer"
- End of a long work session is approaching

## The Handoff Protocol (follow exactly in order)

### Phase 1: Git pull first (catch any changes from other PCs)
Before we audit anything, make sure we have the latest state from origin:
```powershell
git pull origin main --rebase
```
If this fails (no network, no remote), note it and continue — but WARN the user that their other PC won't see these changes until a push succeeds later.
If there are conflicts, abort the rebase (`git rebase --abort`) and flag them for manual resolution.

### Phase 2: Audit current state
Run these commands and capture ALL output:
```powershell
git status
```
```powershell
git diff --stat
```
```powershell
git log --oneline -10
```
Note any unpushed commits, dirty files, stash entries.

### Phase 3: Gather sub-agent state
If sub-agents were spawned during this session (via `agent_open`), capture their state:
- List all sub-agents opened this session (name, task description, status)
- For completed agents: extract key findings, files modified, conclusions
- For running agents: note what they were doing and their current progress
- For failed agents: capture error context for the next session

Format in HANDOVER.md:
```
## Sub-Agent Activity This Session
| Agent | Task | Status | Key Findings |
|-------|------|--------|-------------|
| explorer-1 | Read module structure | completed | Found 3 entry points in lib.rs |
| fixer-2 | Patch approval bug | running | Modified 2 files, needs review |
```

### Phase 4: Summarize what was done this session
Read back through the conversation and compile:

```
## What was accomplished this session
- [Brief item 1 with file references]
- [Brief item 2 with file references]
```

Be specific — mention files changed, features added, bugs fixed, tests written.

### Phase 5: Capture task/project status
Cross-reference any active checklists, durable tasks, and open work:
- Read the current `checklist_write` state (if active)
- Check for durable tasks via `task_list`
- Note any open issues, PRs, or blocked items
- For each: mark status (done / in progress / blocked / pending)

```
## Active Tasks & Checklist
| Item | Status | Notes |
|------|--------|-------|
| Fix deepseek-tui git connection | done | Re-cloned, upstream added, merged to v0.8.38 |
| Enhance handoff skill | done | Added sub-agent aggregation, mandatory push |
```

Copy the full checklist into HANDOVER.md so the next session can pick up exactly where we left off.

### Phase 6: Identify what's NOT done
List explicitly:

```
## What still needs to be done
- [ ] Pending item 1 (priority: high/medium/low)
- [ ] Pending item 2
```

Priority levels:
- **high**: blocks other work, user explicitly asked for it, or it's broken
- **medium**: planned for this session but didn't finish
- **low**: nice-to-have, stretch goal, or mentioned in passing

### Phase 7: Create HANDOVER.md
Write a file called `HANDOVER.md` in the project root with this exact structure:

```markdown
# Project Handover — [Project Name]
**Date:** [current date and time UTC]
**Session ID:** [from DEEPSEEK_SESSION_ID if available]
**Handed over by:** DeepSeek TUI Agent
**Machine:** [hostname if known, otherwise "unknown"]

---

## Quick Resume (for the next PC)
```bash
cd [project-path]
git pull origin main
deepseek --continue
```
The agent will auto-detect this HANDOVER.md and pick up where you left off.

---

## Session Summary
[Phase 4 output — what was accomplished]

## Sub-Agent Activity This Session
[Phase 3 output — agent state table]

## Active Tasks & Checklist
[Phase 5 output — task/project status with checklist]

## Outstanding Work
[Phase 6 output — what still needs to be done, with priorities]

## Current State
- Active branch: [branch name]
- Last commit: [commit SHA + message]
- Uncommitted changes: [yes/no, describe if yes]
- Tests passing: [yes/no/unknown]
- Build status: [passing/failing/unknown]

## Files Modified This Session
[List of files from git diff or your knowledge of edits made]

## Instructions for Next Session
1. On any PC: `cd [project-path] && git pull origin main`
2. Resume with: `deepseek --continue` or `deepseek --resume [SESSION_ID]`
3. The session-saver skill will auto-detect this HANDOVER.md
4. Priority tasks: [list the highest-priority pending items]
5. Key context the next agent needs:
   - [Important architectural decision made]
   - [Pattern that was followed]
   - [Gotcha or known issue to watch for]

## Sub-Agent Recovery
If sub-agents were left running:
- [agent-name]: [status + how to recover]

## Git Status at Handoff
```
[Output of git status]
```

## Recovery
If this handover file is the only record:
- Last known good commit: [SHA]
- Backup branch: [none / backup/handoff-YYYYMMDD]
```

### Phase 8: Commit everything
```powershell
git add -A
```
```powershell
git commit -m "handoff: session wrap-up — [brief summary of what was done]"
```

Include HANDOVER.md in the commit. The commit message should include the session's main accomplishment.

### Phase 9: MANDATORY PUSH (CRITICAL for multi-PC)

THIS STEP IS NOT OPTIONAL WHEN THE USER WORKS ACROSS MULTIPLE PCs.
Without a push, the next PC will NOT see HANDOVER.md.

```powershell
git push origin main
```

If push fails:
- Retry once after 3 seconds
- If still failing: save the branch name, tell the user LOUDLY that other PCs won't get the handover
- Write the handover commit SHA to a note file so it can be pushed manually later
- Never skip this step silently — the user MUST know if push didn't happen

### Phase 10: Create backup branch (extra safety)
```powershell
git branch backup/handoff-$(Get-Date -Format 'yyyyMMdd-HHmmss')
```

### Phase 11: Final report to user
Present a clean summary:

```
Handoff complete

Committed: [SHA] — "[commit message]"
Branch: [branch name]
Pushed to origin: YES (other PCs can now git pull)
   OR
Push FAILED — run manually: git push origin main
Handover: HANDOVER.md (committed)
Tasks captured: [N] active tasks documented

On any PC:
   git pull origin main
   deepseek --continue
   The agent will auto-detect HANDOVER.md
```

### Phase 12: Offer to close
Ask: "Ready to close the session? Your work is saved, HANDOVER.md is written, and [push status]. On your next PC, just git pull and deepseek --continue."

## Multi-PC Workflow Summary

**Ending a session (current PC):**
```
User: "logoff, switching to my laptop"
Agent: runs handoff protocol → writes HANDOVER.md → commits → PUSHES
User: closes terminal
```

**Starting on another PC:**
```
User: opens terminal on laptop
User: cd [project] && git pull origin main   # gets HANDOVER.md + latest code
User: deepseek --continue
Agent: session-saver detects HANDOVER.md → reads it → presents summary → continues work
```

**Critical rule:** The handoff is only useful if PUSH succeeds. If push fails, the next PC sees nothing.

## Failsafe behaviors
- If git remote isn't set, skip push but warn the user loudly (multi-PC won't work)
- If there are merge conflicts in HANDOVER.md, write it to `HANDOVER-[timestamp].md` instead
- If the project isn't a git repo, skip git steps and write HANDOVER.md only — but warn that multi-PC won't work
- If push fails: retry once, then warn explicitly, save the commit SHA
- Always write HANDOVER.md FIRST before git operations, so it exists on disk even if git fails
- Never overwrite an existing HANDOVER.md — use a timestamped variant

## Trigger phrases (user can say any of these)
- "logoff" / "I'm logging off"
- "wrap up" / "wrap it up" / "let's wrap up"
- "hand over" / "create handover"
- "I'm done for today" / "end of day" / "going home"
- "switch computers" / "continue on another PC" / "moving to my laptop"
- "save and quit" / "commit and push everything"
- "I need to go" / "closing for now"
