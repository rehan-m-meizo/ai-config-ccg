#!/usr/bin/env bash
# Per-prompt reminder. Default output suits Claude Code/Codex UserPromptSubmit;
# --antigravity suits Antigravity PreInvocation.
text='Reminder: stay inside this request; read the owning code before editing; end with checks run and results, or say \"not verified\". Suggest a new thread when context is long.'
if [[ "${1:-}" == --antigravity ]]; then
  echo "{\"injectSteps\":[{\"ephemeralMessage\":\"$text\"}]}"
else
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"$text\"}}"
fi
