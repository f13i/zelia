# Headroom fork

**Date:** 2026-06-01
**Branch:** `claude/project-headroom-fork-mMkyF`

## What & why

We "forked" [chopratejas/headroom](https://github.com/chopratejas/headroom)
(Apache 2.0) — the token-compression layer for AI agents from the Register
article — for our own use. Instead of vendoring the 118 MB Python/Rust/Node
source into this content-ops repo, we did a **lean integration**: a
`tools/headroom/` folder holding our config + wrapper scripts, and we install
the published `headroom-ai` package from PyPI/npm.

This was a deliberate choice (user picked "Lean integration" over vendoring full
source or mirroring everything incl. ~26 MB of demo GIFs). Keeps the repo small
and lets us track upstream by version bump.

## Where things live

- `tools/headroom/` — README, `setup.sh`, `wrap.sh`, `proxy.sh`, `headroom.env`,
  `models.json`, `UPSTREAM.md`, `LICENSE-UPSTREAM`, `NOTICE-UPSTREAM`.
- `.claude/skills/headroom/SKILL.md` — `/headroom` skill, registered in AGENTS.md index.

## Our config defaults (headroom.env)

Local bind only, `token` mode, telemetry **off**, $50/day soft budget,
`models.json` with limits for Claude Opus/Sonnet/Haiku + GPT-4o.

## Quirks

- Headroom config is **env-var + constructor based** — there is no single TOML
  config file it auto-loads. `models.json` is the one file it reads (from
  `$HEADROOM_CONFIG_DIR/models.json` or `HEADROOM_MODEL_LIMITS`).
- Upstream is early (v0.22, "still-raw"). Pinned 0.22.4 / commit
  `304dcc7…`. To sync, follow `tools/headroom/UPSTREAM.md`.
- GitHub MCP in these sessions is scoped to `f13i/zelia` only — can't read/fork
  other repos through it; used direct `git clone` over the network to inspect upstream.
