# Reliability Pack — Free Preview

Most Claude Code skills activate ~50% of the time. Mine activate ~94%.

This is the **free preview** — the activation hook + one sample skill. Drop them into `~/.claude/`, restart Claude Code, and skill activation jumps immediately.

The full pack (`6 skills + 4 subagents + the hook + CLAUDE.md template + 30-page PLAYBOOK`) is `$49` here: **https://halvorbuilds.gumroad.com/l/buedv**

---

## What's in this repo

```
hooks/
  force-skill-eval.sh    # The activation hook. Forces EVALUATE → ACTIVATE → IMPLEMENT.
skills/
  code-review.md         # 1 of 6 skills from the full pack. Directive description pattern.
CLAUDE.md.template       # The <200-line drop-in template that primes the hook.
```

## Install

```bash
git clone https://github.com/halvorbuilds-source/reliability-pack-preview
cd reliability-pack-preview
cp hooks/force-skill-eval.sh ~/.claude/hooks/
cp skills/code-review.md ~/.claude/skills/
cp CLAUDE.md.template ~/CLAUDE.md   # or merge into your existing
chmod +x ~/.claude/hooks/force-skill-eval.sh
```

Then merge the `force-skill-eval.sh` hook into your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "command": "~/.claude/hooks/force-skill-eval.sh" }
    ]
  }
}
```

Restart Claude Code. The hook fires before every prompt.

## Verify it works

Send a prompt like *"review this file for bugs"*. With the hook + the `code-review` skill installed, you should see Claude run the **EVALUATE → ACTIVATE → IMPLEMENT** cycle visibly in its response, and explicitly invoke the `code-review` skill.

If you get the cycle but the skill doesn't fire, that's the description-budget problem — the full pack's PLAYBOOK §3 walks through diagnosing it.

## Why activation matters

Skill activation isn't a model intelligence problem. It's a routing problem. Most "AI dropped me" moments are actually "AI didn't activate the skill that would've not-dropped me."

Three things that move the needle, all in this preview:

1. **Directive descriptions** — `USE WHEN debugging a failing test` beats `for debugging`. Look at how `skills/code-review.md` is structured.
2. **A pre-prompt hook** that forces eval-before-act. That's `force-skill-eval.sh`.
3. **A `CLAUDE.md` under ~200 lines** so the delegation table stays in attention. The template is exactly that.

The full pack adds 5 more skills, 4 scoped subagents, the full settings.json, and a 30-page PLAYBOOK with 8 failure modes + cited fixes for each. **`$49` — https://halvorbuilds.gumroad.com/l/buedv**

## License

MIT. Use freely. Attribution welcome but not required.

If this saved you debugging time, the full pack is the thank-you.
