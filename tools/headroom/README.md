# Headroom — our fork/integration

> The context-compression layer for AI agents. Compresses everything our agents
> read — tool outputs, logs, RAG chunks, files, and conversation history — before
> it reaches the LLM. Same answers, 60–95% fewer tokens.

This folder is **our lean fork** of [chopratejas/headroom](https://github.com/chopratejas/headroom)
(Apache 2.0). We don't vendor the upstream source here — it's a 118 MB
Python/Rust/Node project that ships on PyPI/npm. Instead this folder holds **our
config, our wrapper scripts, and the version we pin to**, so every agent and
operator in this repo runs Headroom the same way against the same settings.

Why we run it: this repo's whole workflow is AI agents reading large contexts
(meeting transcripts, logs, CRM dumps, MCP tool outputs, RAG chunks). Headroom
sits in front of the LLM and strips the redundant tokens before we pay for them.
On the upstream benchmarks that's 47–92% fewer tokens on real agent workloads
with no measured accuracy loss.

## What's here

| File | Purpose |
|------|---------|
| `setup.sh` | Install `headroom-ai[all]` and lay down our config dir |
| `wrap.sh` | Load our env, then `headroom wrap <agent>` (claude, codex, cursor, …) |
| `proxy.sh` | Load our env, run the drop-in proxy on our port |
| `headroom.env` | Our shared settings (mode, port, budget, telemetry off, stateless) |
| `models.json` | Context limits for the models we actually use |
| `UPSTREAM.md` | The exact upstream commit/version we pin to + how to sync |

There's also a `/headroom` skill (`.claude/skills/headroom/`) so any agent in this
repo can be told "run this through Headroom" and know exactly how.

## Quick start

```bash
cd tools/headroom

# 1 — install Headroom + lay down config (~/.headroom/config)
./setup.sh

# 2a — wrap a coding agent (recommended for day-to-day)
./wrap.sh claude          # also: codex, cursor, aider, copilot, gemini

# 2b — or run the drop-in proxy and point any OpenAI/Anthropic client at it
./proxy.sh                # serves http://127.0.0.1:8787

# 3 — see what we saved
headroom stats
```

Requires **Python 3.10+**. Everything runs **locally** — our data never leaves the
machine, and we ship with telemetry **off** (see `headroom.env`).

## Inline library use (in our own Python/TS tools)

```python
from headroom import compress
compressed = compress(messages, model="claude-sonnet-4-6")
```

```ts
import { compress } from "headroom-ai";
const out = await compress(messages, { model: "claude-sonnet-4-6" });
```

## Docs

Upstream docs: <https://headroom-docs.vercel.app/docs> ·
LLM-readable index: <https://headroom-docs.vercel.app/llms.txt>

## License & attribution

Headroom is Apache 2.0, © its authors. This folder adds only our configuration
and wrappers — see `UPSTREAM.md` for the pinned version and `LICENSE-UPSTREAM`
note. We keep upstream attribution intact.
