# DeepSeek TUI — Team Configuration Snippet
#
# Copy the sections you want into ~\.deepseek\config.toml
# (merge with your existing config; these are ADDITIONS, not replacements)
#
# This file: docs/CONFIG_TEAM.md — full documentation at docs/TEAM_GUIDE.md

# ── Memory: persistent preferences across sessions ──────────────────────
[memory]
enabled = true
# memory_path = "~/.deepseek/memory.md"  # default, uncomment to customize

# ── Hooks: auto-checkpoint and safety net ───────────────────────────────
[hooks]
enabled = true

# Hook 1: Auto-commit WIP on session start (never lose uncommitted changes)
[[hooks.hooks]]
event = "session_start"
command = "powershell -NoProfile -Command \"cd '%DEEPSEEK_WORKSPACE%'; git add -A; git commit -m 'checkpoint: auto-save session start' --allow-empty 2>$null; Write-Host 'Checkpoint saved'\""
name = "auto-checkpoint-start"
background = true
continue_on_error = true
timeout_secs = 15

# Hook 2: Auto-commit before destructive shell commands
[[hooks.hooks]]
event = "tool_call_before"
command = "powershell -NoProfile -Command \"cd '%DEEPSEEK_WORKSPACE%'; git add -A; git commit -m 'checkpoint: before %DEEPSEEK_TOOL_NAME%' --allow-empty 2>$null; Write-Host 'Pre-tool checkpoint'\""
condition = { type = "tool_name", name = "exec_shell" }
name = "pre-shell-checkpoint"
background = true
continue_on_error = true
timeout_secs = 15

# Hook 3: Log tool executions for audit trail
[[hooks.hooks]]
event = "tool_call_after"
command = "powershell -NoProfile -Command \"$msg = '[%DATE% %TIME%] Tool={0} Success={1}' -f $env:DEEPSEEK_TOOL_NAME, $env:DEEPSEEK_TOOL_SUCCESS; Add-Content -Path '%USERPROFILE%\\.deepseek\\tool-audit.log' -Value $msg\""
name = "audit-log"
background = true
continue_on_error = true

# ── Launcher setup action replicates these (for new team members) ──────
# The Setup action in launch.ps1 runs:
#   deepseek setup --tools --plugins
#   deepseek mcp init
#   deepseek config set default_text_model auto
#   deepseek config set reasoning_effort auto
#   deepseek config set features.shell_tool true
#   deepseek config set features.subagents true
#   deepseek config set features.web_search true
#   deepseek config set features.apply_patch true
#   deepseek config set features.mcp true
#   deepseek config set features.exec_policy true
