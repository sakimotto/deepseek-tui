---
name: handoff
description: Session wrap-up and project handover agent. Use when the user says "logoff", "I'm done for today", "hand over", "wrap up", "switch computers", or wants to end a work session cleanly. Creates a HANDOVER.md document, commits all remaining work, pushes to git, and leaves instructions for the next agent session.
---

# Handoff Skill — Clean Session Wrap-Up

## When to activate
- User says: "logoff", "I'm done", "wrap up", "hand over", "goodbye", "switch computers", "end session", "close out", "going home"
- User says: "save everything and quit", "push my work", "create handover"
- End of a long work session is approaching

## The Handoff Protocol (follow exactly in order)

### Phase 1: Audit current state
Run these commands and capture ALL output:
```powershell
git status
```
```powershell
git diff --stat
```
```powershell
git log --oneline -5
```
Note any unpushed commits.

### Phase 2: Summarize what was done this session
Read back through the conversation and compile:

```
## What was accomplished this session
- [Brief item 1 with file references]
- [Brief item 2 with file references]
- ...
```

Be specific — mention files changed, features added, bugs fixed, tests written.

### Phase 3: Identify what's NOT done
List explicitly:

```
## What still needs to be done
- [ ] Pending item 1 (priority: high/medium/low)
- [ ] Pending item 2
- [ ] ...
```

If there was a checklist written earlier, cross-reference it. Mark items as [x] done, [ ] pending.

### Phase 4: Create HANDOVER.md
Write a file called `HANDOVER.md` in the project root with this exact structure:

```markdown
# Project Handover — [Project Name]
**Date:** [current date and time UTC]
**Session ID:** [from DEEPSEEK_SESSION_ID if available]
**Handed over by:** [user name if known, otherwise "DeepSeek TUI Agent"]

---

## Session Summary
[Phase 2 output — what was accomplished]

## Outstanding Work
[Phase 3 output — what still needs to be done]

## Current State
- Active branch: [branch name]
- Last commit: [commit SHA + message]
- Uncommitted changes: [yes/no, describe if yes]
- Tests passing: [yes/no/unknown]
- Build status: [passing/failing/unknown]

## Files Modified This Session
[List of files from git diff or your knowledge of edits made]

## Instructions for Next Session
1. Resume with: `deepseek --continue` or `deepseek --resume [SESSION_ID]`
2. Start by reading this HANDOVER.md: `@HANDOVER.md`
3. Priority tasks: [list the highest-priority pending items]
4. Key context the next agent needs:
   - [Important architectural decision made]
   - [Pattern that was followed]
   - [Gotcha or known issue to watch for]

## Git Status at Handoff
```
[Output of git status]
```

## Recovery
If this handover file is the only record:
- Last known good commit: [SHA]
- Backup branch: [none / backup/handoff-YYYYMMDD]
```

### Phase 5: Commit everything
```powershell
git add -A
```
```powershell
git commit -m "handoff: session wrap-up — [brief summary of what was done]"
```

Include HANDOVER.md in the commit. The commit message should include the session's main accomplishment.

### Phase 6: Create a backup branch (safety)
```powershell
git branch backup/handoff-$(Get-Date -Format 'yyyyMMdd-HHmmss')
```
This creates a named recovery point even if something goes wrong later.

### Phase 7: Push
```powershell
git push origin [current-branch]
```

If push fails (no remote, no permissions), tell the user and save the branch name.

### Phase 8: Final report to user
Present a clean summary:

```
✅ Handoff complete

📦 Committed: [SHA] — "[commit message]"
🌿 Branch: [branch name] (pushed ✓ / not pushed ⚠️)
📄 Handover: HANDOVER.md (committed)

⏭️ Next session:
   deepseek --continue
   @HANDOVER.md
```

### Phase 9: Offer to close
Ask: "Ready to close the session? Your work is saved and pushed."

## Failsafe behaviors
- If git remote isn't set, skip push but warn the user loudly
- If there are merge conflicts in HANDOVER.md, write it to `HANDOVER-$(date).md` instead
- If the project isn't a git repo, skip git steps and write HANDOVER.md only
- Always write HANDOVER.md FIRST before git operations, so it exists even if git fails

## Trigger phrases (user can say any of these)
- "logoff" / "I'm logging off"
- "wrap up" / "wrap it up" / "let's wrap up"
- "hand over" / "create handover"
- "I'm done for today" / "end of day" / "going home"
- "switch computers" / "continue on another PC"
- "save and quit" / "commit and push everything"
