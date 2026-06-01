---
name: headroom
description: Compress what an AI agent reads — tool outputs, logs, RAG chunks, files, conversation history — before it hits the LLM, to cut token spend 60–95% with the same answers. Use when running coding agents, when a workload is burning tokens on bulky context (transcripts, logs, CRM dumps, MCP/JSON outputs), or when asked to "run this through Headroom" / "reduce token cost".
---

# Headroom

Our fork/integration lives in `tools/headroom/`. It wraps the upstream
[chopratejas/headroom](https://github.com/chopratejas/headroom) (Apache 2.0)
with our config so token compression is one command. Everything runs locally;
telemetry is off.

## When to reach for it

- Running a coding agent daily (Claude Code, Codex, Cursor, Aider, Copilot).
- A task feeds the LLM bulky, repetitive context: server logs (~90% trimmable),
  MCP/JSON tool outputs (~70% redundant), DB rows, file trees, RAG chunks.
- Someone asks to cut token cost / "run it through Headroom" / measure savings.

Skip it for: single short prompts, or sandboxes where local processes can't run.

## How to run it

```bash
cd tools/headroom
./setup.sh                 # once: installs headroom-ai[all] + our config
./wrap.sh claude           # wrap an agent (claude|codex|cursor|aider|copilot|gemini)
./proxy.sh                 # OR a drop-in proxy on :8787 for any OpenAI/Anthropic client
headroom stats             # see tokens/$ saved
```

Inline in our own code:

```python
from headroom import compress
compressed = compress(messages, model="claude-sonnet-4-6")
```

## Modes (set in `tools/headroom/headroom.env`)

- `token` (default) — fewest tokens.
- `cache` — optimize provider KV-cache hit rate.
- `audit` — observe only; use first on a new workload to measure the baseline.

## Notes

- Compression is **reversible** (CCR): originals are kept locally and the LLM
  retrieves them on demand via the Headroom MCP — so trimming context is safe.
- Pinned version + how to sync upstream: `tools/headroom/UPSTREAM.md`.
- Full config reference: https://headroom-docs.vercel.app/docs/configuration
