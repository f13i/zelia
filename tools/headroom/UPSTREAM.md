# Upstream pin

We track [chopratejas/headroom](https://github.com/chopratejas/headroom) and
install the published package rather than vendoring its source.

| Field | Value |
|-------|-------|
| Upstream repo | https://github.com/chopratejas/headroom |
| License | Apache 2.0 |
| Pinned version | `headroom-ai` **0.22.4** |
| Pinned commit | `304dcc78047bc744fc2f7656b484ec54dc271354` |
| Pinned on | 2026-06-01 |
| PyPI | https://pypi.org/project/headroom-ai/ |
| npm | https://www.npmjs.com/package/headroom-ai |

Headroom is early (v0.22, "still-raw" per upstream). Pin a known-good version in
`setup.sh` if a release breaks us, rather than always tracking latest.

## Syncing to a newer upstream

1. Check upstream releases / CHANGELOG: https://github.com/chopratejas/headroom/releases
2. Bump the version in this file and (if pinned) in `setup.sh`.
3. Re-run `./setup.sh` and `headroom stats` / a smoke test on a real workload.
4. If the config surface changed, reconcile `headroom.env` and `models.json`
   against https://headroom-docs.vercel.app/docs/configuration.
5. Commit with the new version + commit SHA recorded above.

## What we changed vs. upstream

Nothing in the upstream code — this is config-and-wrappers only:

- `headroom.env` — our defaults: local bind, `token` mode, telemetry off, $50/day budget.
- `models.json` — context limits for the models we use (Claude Opus/Sonnet/Haiku, GPT-4o).
- `setup.sh` / `wrap.sh` / `proxy.sh` — load our env, then call the upstream CLI.
- `.claude/skills/headroom/` — a skill so agents in this repo know how to use it.
