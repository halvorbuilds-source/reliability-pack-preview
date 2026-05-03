#!/usr/bin/env bash
# force-skill-eval.sh — UserPromptSubmit hook
#
# Why this exists
# ---------------
# Claude Code skills activate ~50% of the time at baseline (650-trial study,
# 2026 Q1). The model receives skill descriptions in its system prompt but
# under load it often skips the activation step and proceeds straight to
# implementation. Result: skills you wrote get ignored; you pay for tokens
# you didn't need; output regresses to the unstructured baseline.
#
# What it does
# ------------
# On every UserPromptSubmit, this hook injects an EVALUATE -> ACTIVATE ->
# IMPLEMENT prefix into the model's working context. The prefix forces the
# model to (1) enumerate which installed skills *could* match the prompt,
# (2) commit to one or none, (3) only then begin work. In the 650-trial
# study, this pattern moved activation from ~50% to 94-100%.
#
# Install
# -------
# 1. Copy this file to ~/.claude/hooks/force-skill-eval.sh
# 2. chmod +x ~/.claude/hooks/force-skill-eval.sh
# 3. In ~/.claude/settings.json, register under hooks.UserPromptSubmit
#    (see settings.json in this pack).
#
# Output contract
# ---------------
# stdout is appended to the model's context window before its turn begins.
# Keep it tight: every char here is a char you pay for on every prompt.
# Current footprint: ~480 chars.

set -euo pipefail

# Optional: skip injection for trivial prompts (single word, <12 chars).
# The activation-failure mode only matters when the prompt is doing real
# work; "ls" or "thanks" don't need a 480-char prefix.
USER_PROMPT="${CLAUDE_USER_PROMPT:-}"
PROMPT_LEN=${#USER_PROMPT}
if [ "$PROMPT_LEN" -lt 12 ]; then
  exit 0
fi

cat <<'PREFIX'
[skill-eval]
Before responding, run this three-step protocol silently:

1. EVALUATE — list every installed skill (from your skill registry) whose
   description plausibly covers this prompt. If none match, say "none" and
   proceed normally.
2. ACTIVATE — pick at most one skill to run. If two match, pick the one
   whose description is more specific to this prompt's verb (review > read,
   test > check, refactor > clean).
3. IMPLEMENT — execute the skill's instructions verbatim, OR proceed
   without a skill if step 2 returned "none".

Do not narrate the protocol in your visible output. Just do it, then
answer.
[/skill-eval]
PREFIX
