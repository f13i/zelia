<p align="center">
  <img src="brand/logo/sylph-icon.png" width="120" alt="sylph" />
</p>

<h1 align="center">Sylph</h1>

<p align="center">
  The open-source company brain.<br/>
  Run your entire company with AI agents, skills, and a self-improving context.
</p>

<p align="center">
  Created by <a href="https://getnao.io">nao Labs</a> (YC X25) to run our company.
</p>

## What is this?

Sylph is a repo to help you build your company brain: a repo of all your context by domains, skills to perform actions with or for you, agents that will act as real AI employees (the [Sylphs](https://en.wikipedia.org/wiki/Sylph)), and a core principle: a self-improving loop.

It is agent agnostic, can be used in [Claude Code](https://claude.ai/code), [Codex](https://openai.com/codex), [Cursor](https://cursor.sh), or any AI coding agent that can work on a git repo. 

I wrote the full story of how it works and how I built it on my substack here: [I built a company brain to run my YC startup](https://thenewaiorder.substack.com/p/i-built-a-company-brain-to-run-my).

## What you can do with sylph

Sylph works with all domains of your company: product, marketing, sales, legal, recruiting, etc.

You can:
* **Automate processes**: creating content, events, brand assets, product issues, outbound campaigns etc.
* **Gather information**: run reports on client activity, product activity, or domain progress on your roadmap
* **Plan work**: structure scattered to-dos and client feedback into weekly and daily todos
* **Have agents working for you**: run agents in the background to gather information and prepare tasks for you
* **Build and auto-improve your knowledge base**: every domain knowledge is stored in the repo and is auto-enriched
* **Create any new skill you need**: with `/sylph-create-skill`
* **Collaborate with your team**: use the same repo for all your team to work on common knowledge

## Sylph main concepts

**CAO**: Chief Agent Officer - that's you.

**AGENTS.md**: The single source of truth for all agents, explaining how to work in the company brain.

**CONTEXT.md**: Your company's identity - what you do, who you serve, how the product works, etc.

**Domain context**: Each business domain has its own folder. This is where domain-specific knowledge lives and grows.

**Skills**: Processes to perform a task according to your company context. They all end with a self-improving loop.

**Agents**: AI employees with defined roles, routines, and assigned skills. Like superheroes with specific superpowers!

**Connectors**: MCP integrations that give agents access to external tools.

**Self-learning**: The core principle. After you approve an output, the skill diffs what it drafted vs what you kept, and rewrites its own rules to match your edits. Every cycle makes the next one better.

## Quick start

### 1. Fork this repo

```bash
gh repo fork getnao/sylph --clone
cd sylph
```

### 2. Run the setup skill

Open the repo in your AI agent and run:

```
/sylph-setup
```
This will personalize sylph to your own personal and company context.


### 3. Set up skills

Skills are pre-configured but can be personalized to your own setup - just set them up as you need them.

```
/sylph-setup-skill linkedin
```

### 4. Configure your agents

Agents in the repo are already pre-configured, but you can personalize their tasks and scopes with this skill:

```
/sylph-setup-agent chief-of-staff
```

### 5. Try it

```
/linkedin-writer Write a post about [topic]
/create-campaign Target Series A data teams
/hr-screening Screen applications for senior engineer
/investor-update Draft the May update
```

## Directory structure

```
AGENTS.md           - canonical instructions for all agents
CONTEXT.md          - global company description and context

.claude/
  skills/           - all skills for your company

agents/             - AI employees with defined routines and skill assignments

tools/              - operational tooling the agents/operators run (e.g. headroom)

domain folders:
brand/              - brand assets, guidelines, voice
content/            - all content by channel
sales/              - outbound sequences, proposals, CRM
customer-success/   - meeting follow-ups, user research
product/            - roadmap, issues
finance/            - investor updates
partnerships/       - consulting, freelance, influencer
events/             - hackathons, meetups, remote
admin/              - internal ops (email, Slack, CRM)
hr/                 - hiring, screening
legal/              - contracts and legal
compliance/         - compliance notes
```

## Skills

Skills are detailed, self-improving instruction files. They live in `.claude/skills/` and are invoked via slash commands.

| Domain | Skills | What they do |
|--------|--------|-------------|
| `content` | `linkedin`, `blog`, `substack`, `newsletter`, `x`, `reddit`, `website`, `slack-community` | Content creation per channel |
| `sales` | `create-campaign`, `crm`, `customer-report` | Outbound campaigns, CRM, client briefs |
| `brand` | `brand-guidelines`, `brand-designer` | Brand assets and guidelines |
| `finance` | `investor-update` | Investor updates |
| `hr` | `hr-screening` | Application screening |
| `product` | `create-issue` | GitHub issue creation |
| `events` | `event-manager` | Event creation and management |
| `legal` | `create-contract`, `review-contract` | Contract drafting and review |
| `ops` | `zero-inbox` | Inbox triage |
| `writing` | `email-writer` | Email drafting |
| `tools` | `headroom` | Compress agent context to cut LLM token spend 60–95% |
| `sylph` | `sylph-setup`, `sylph-setup-agent`, `sylph-setup-skill`, `sylph-create-skill` | Initial setup, agent configuration, per-domain setup, skill creation |

## Agents

Agents are AI employees that run on schedules. Each has a role definition and a recurring routine.

| Agent | What it does | Cadence |
|-------|-------------|---------|
| **Chief of Staff** | Inbox triage, project pulse, weekly planning, daily briefing | Daily |
| **CMO** | Content planning, drafting, docs maintenance, release comms | Daily |
| **Product Manager** | Issue creation from feedback, PR monitoring, daily recap | Daily |
| **Customer Success** | Follow-up drafting from CSM backlog | Weekly |
| **Head of Data** | Analytics reports, metric monitoring | Daily |
| **Head of Sales** | Pipeline management, outbound campaigns | Weekly |
| **Executive Assistant** | Admin, HR, finance, accounting ops | Daily |
| **Brand Designer** | Visual and motion assets | On-demand |

## Tools

Operational tooling the agents and operators run lives in `tools/`. These aren't
skills — they're real programs you install and run from the command line.

### Headroom — cut your token bill

[Headroom](https://github.com/chopratejas/headroom) (Apache 2.0) is a
context-compression layer for AI agents. It compresses everything an agent reads
— tool outputs, logs, RAG chunks, files, conversation history — *before* it
reaches the LLM, for 60–95% fewer tokens with the same answers. Compression is
reversible: originals stay on your machine and the model retrieves them on demand.

This matters here because Sylph agents constantly read bulky context (meeting
transcripts, CRM dumps, logs, MCP/JSON tool outputs). Headroom strips the
redundant tokens before you pay for them. It runs **locally** — no data leaves
your machine, and we ship it with telemetry off.

We run it as a lean integration in [`tools/headroom/`](tools/headroom/): we
install the published `headroom-ai` package and keep only our config + wrappers
in-repo (so we're not vendoring a 118 MB project).

**Use it:**

```bash
cd tools/headroom
./setup.sh                 # once: installs headroom-ai[all] + our config
./wrap.sh claude           # wrap a coding agent (claude|codex|cursor|aider|copilot|gemini)
./proxy.sh                 # OR a drop-in proxy on :8787 for any OpenAI/Anthropic client
headroom stats             # see tokens/$ saved
```

Inside the repo, any agent can be told *"run this through Headroom"* and will
follow the [`/headroom`](.claude/skills/headroom/SKILL.md) skill. Our defaults
(mode, port, $50/day budget, telemetry) live in `tools/headroom/headroom.env`;
the upstream version we pin to and how to sync it live in
`tools/headroom/UPSTREAM.md`. Requires **Python 3.10+**.

## Customization guide

You can add new domains by creating folders in the folder root.
You can create new skills & agents with the `/sylph-setup-skill <name>` skill.

## Why "Sylph"?

Sylphs are invisible spirits of the air - creatures that shape the world without being seen. They were made famous by the ballet [La Sylphide](https://www.youtube.com/watch?v=G2zqQs6Ez3U) (the author may or may not be a ballet nerd). That's what this repo does: AI agents running your company behind the scenes, while you stay in control.


## Security
This repo contains **no backend, no tracking, no telemetry, and no network calls.** It's just markdown files that AI agents read. No code phones home, no data is sent anywhere, and no credentials are bundled. See [`SECURITY.md`](SECURITY.md) for the full audit and verification commands you can run yourself.

## License

MIT - use it however you want.
