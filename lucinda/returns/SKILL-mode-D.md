# Wiring: add "Mode D — Returns" to the Lucinda skill

Lucinda's live skill is at `~/.claude/skills/lucinda/SKILL.md`. The returns
subagent is at `.claude/agents/lucinda-returns.md`. To let Lucinda call it,
make two small edits to her `SKILL.md`.

---

## 1. Extend the `description` triggers

Add returns triggers so the skill fires on returns language. Append to the
`description` frontmatter (before the "Do NOT use for f13i" line):

> ... or Farhan says "track my returns", "find my purchases", "what returns are
> coming up", "return the <item>", "renegotiate with <merchant>", or asks about
> purchase/return deadlines.

## 2. Add the Mode D block

Paste this block after **Mode C** in `SKILL.md`:

```markdown
## Mode D — Returns (purchases, return windows, renegotiation)

Trigger: "track my returns", "find my purchases", "what returns are coming up",
"return the <item>", "renegotiate with <merchant>", or the scheduled returns check.

Lucinda **delegates this to the `lucinda-returns` subagent** (Agent tool,
`subagent_type: lucinda-returns`). That agent owns the full workflow; Lucinda
relays its digest/questions to Farhan and passes his replies back.

The returns agent, in one line each:
1. **Sweep** Farhan's email for purchases (Amazon + 3rd party), log each under a
   `Returns/*` Gmail label, and put each return deadline on the calendar (all-day,
   non-blocking). No database — labels + calendar are the record.
2. **Surface** items whose window closes ≤7 days out with an **auto-sent iMessage
   to Farhan** ("Return coming up, need me to do anything? Reply which to
   return / keep"). Farhan only — never Kanwal.
3. **Execute** the returns he picks — Amazon return submission (or exact
   step-by-step) and 3rd-party merchant emails, full-auto after his reply.
4. **Renegotiate** missed/closing windows — draft the exception ask and track the
   merchant thread to resolution.

Autonomy: labeling + calendar + the decision-reminder text auto; deciding *what*
to return always asks Farhan; one reply authorizes that item's execution. Same
hard rules as the rest of Lucinda — never text Kanwal, never touch the f13i or
personal-brain vaults, and **always send merchant email from `fmanjiyani@gmail.com`,
never `me@f13i.com`.**
```

---

## 3. (Optional) install the subagent at user level

For Lucinda to call the subagent outside this repo, copy it to Farhan's
user-level agents dir:

```bash
mkdir -p ~/.claude/agents
cp .claude/agents/lucinda-returns.md ~/.claude/agents/lucinda-returns.md
```

## 4. (Optional) schedule the daily check

Add a scheduled task so returns are swept and deadlines surfaced without being
asked — mirror Lucinda's existing 7:30 CT daycare run:

- Prompt: "Load the lucinda skill and run Mode D — Returns: sweep new purchases,
  then text me any return windows closing in the next 7 days."
- Cron (weekday mornings, 7:30 CT = 12:30 UTC during CDT): `30 12 * * 1-5`
