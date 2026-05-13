---
name: team-workflow
description: Standardized full-stack development workflow for the Zervi team. Use when building features, refactoring, debugging, or doing code reviews. Ensures consistent patterns: pre-flight checks, branching strategy, testing, and documentation.
---

# Team Workflow Skill

## When to activate
- User asks to build a feature, fix a bug, refactor code, or review changes
- User asks for architectural guidance or code quality review
- User is working on any full-stack application (Next.js, Node, React, TypeScript, Python)

## Pre-flight (before any code change)
1. Run `git status` to check current branch and uncommitted changes
2. If there are uncommitted changes from BEFORE this session, suggest stashing or committing them
3. Confirm the target branch (e.g. `main`, `develop`, `feat/*`)
4. If this is a new feature, create a branch: `git checkout -b feat/<slug>`

## During work
1. **Plan first** — outline what files will change and why before touching code
2. **Small diffs** — make focused changes, 1-3 files per turn, never batch unrelated edits
3. **Test after change** — run relevant tests after every file edit
4. **TypeScript strict** — run `tsc --noEmit` after TypeScript changes
5. **Commit meaningful units** — each commit should pass tests and be reviewable alone

## After work
1. Run the full test suite: `npm test` or `cargo test`
2. Run the linter: `npm run lint` or `cargo clippy`
3. Create a PR with a descriptive title and body
4. Reference any related issues with `#issue-number`

## Code quality checklist
- [ ] No `any` types in TypeScript (use proper types or `unknown`)
- [ ] No `unwrap()` in Rust without a comment explaining why it's safe
- [ ] Error handling on all async calls
- [ ] No hardcoded secrets, URLs, or magic numbers
- [ ] Imports are sorted and unused imports removed
- [ ] New functions have doc comments

## Stack-specific rules

### TypeScript / React
- Use functional components with hooks
- State management: prefer React context or Zustand over Redux
- API calls go through a service layer, never direct in components
- Environment variables: `VITE_` prefix for Vite, never expose server-side keys

### Python
- Use type hints on all function signatures
- Prefer `pathlib` over `os.path`
- Use `async/await` for I/O-bound operations
- Log with `logging` module, not `print()`

### Rust
- Follow the existing module pattern in the workspace
- Use `thiserror` for error types
- Prefer `&str` over `String` for function parameters
- Document public APIs with `///` comments

## Session hygiene
- After every successful tool execution, verify the result
- If a tool fails, explain why before retrying
- Keep the user informed of progress with brief status updates
- When blocked, ask the user a specific, actionable question
