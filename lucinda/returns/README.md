# Lucinda — Returns Module

Extends Lucinda (family chief of staff) to track purchases and returns end to end:
find every purchase in email → log it → text Farhan before each return deadline →
execute the returns he picks → renegotiate the ones that slip.

## What's here

| File | What it is |
|---|---|
| `PRD.md` | Product spec — problem, locked decisions, workflows, autonomy, risks |
| `../../.claude/agents/lucinda-returns.md` | The subagent Lucinda calls (Claude Code agent) |
| `SKILL-mode-D.md` | The "Mode D — Returns" block + how to wire it into Lucinda's live `SKILL.md` |

## How it works (30-second version)

1. **Sweep** — scans Gmail for purchases (Amazon + 3rd party).
2. **Log** — one `Returns/*` Gmail label per item + an all-day, non-blocking
   calendar deadline. **Ledger = labels + calendar. No database.**
3. **Surface** — auto-texts Farhan when a window closes ≤7 days out:
   *"Return coming up, need me to do anything? Reply which to return / keep."*
4. **Execute** — his reply drives it: submits the Amazon return / emails the
   merchant, full-auto per item after his OK.
5. **Renegotiate** — missed windows get a drafted exception ask, and Lucinda
   tracks the merchant thread to resolution.

## Locked decisions

- Track **all** purchases, flag **every** closing window; Farhan decides what to return.
- **Full-auto execution** after one reply; the *decision* to return always asks him.
- **Gmail labels + Calendar only** — no purchase data in the repo.
- Renegotiation = **draft + track the back-and-forth** to done.
- All outbound sends from **`fmanjiyani@gmail.com`**, never `me@f13i.com`.
- Never texts Kanwal. Never touches the f13i or personal-brain vaults.

## Install

See `SKILL-mode-D.md` — two edits to `~/.claude/skills/lucinda/SKILL.md`, copy the
subagent to `~/.claude/agents/`, and (optional) schedule the weekday-morning check.

## Try it

- "Lucinda, track my returns" → backfill sweep + calendar deadlines.
- "What returns are coming up?" → the decision text.
- "Return the black purse" → execution.
- "Renegotiate with Nordstrom on the purse" → drafted exception + thread tracking.
