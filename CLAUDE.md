# Hermes Agent — Claude Code Instructions

## Project Overview

**Hermes Agent** is an enterprise MLOps demo playbook for NousResearch's Hermes Agent.
Goal: Stand up a terminal-based AI agent with 40+ tools and curated MLOps skills for
GSI partner demonstrations (Accenture, Deloitte, Capgemini, Wipro, TCS, Infosys).

**Primary audience**: Solutions Architects and DevRel Engineers advising Fortune 500 clients.

---

## Memory Protocol

> CRITICAL: Always read memory files at the start of every session.

```
SESSION START  →  Read .claude/context.md + .claude/todos.md + .claude/insights.md
DURING WORK    →  Update todos.md after EACH completed task
                  Append to insights.md when discovering new patterns or blockers
COMPACTION     →  Re-read context.md → todos.md → resume without asking
SESSION END    →  Update all three files before stopping
```

---

## Project Structure

```
Hermes/
├── CLAUDE.md                   # This file
├── playbook.md                 # Source playbook (full demo guide)
├── .claude/
│   ├── context.md              # Current phase and goals
│   ├── todos.md                # Task checklist (compaction lifeline)
│   └── insights.md             # Learnings, gotchas, demo notes
├── demos/                      # Per-vertical demo scripts (to be created)
│   ├── finance.md
│   ├── healthcare.md
│   ├── telecom.md
│   ├── retail.md
│   └── public-sector.md
├── skills/                     # Custom SKILL.md files for enterprise verticals
└── assets/                     # Diagrams, screenshots, one-pagers
```

---

## Key Reference Points

### Hermes Agent Commands
```bash
hermes --toolsets ml            # Launch TUI with ML skills
hermes chat -q "..."            # One-shot query (good for demos)
hermes doctor                   # Diagnostics
hermes model                    # Switch LLM on the fly
hermes skills search <topic>    # Community skills
hermes gateway                  # Start messaging platform bridge
```

### LLM Provider Strategy
- **OpenRouter** — recommended for demos (200+ models, switch on the fly)
- **Nous Portal** — heavy daily use, Hermes-3 optimized
- **Custom endpoint** — air-gapped/self-hosted for regulated clients

### Demo Agent Persona
- Model: Hermes-3 via OpenRouter (or Llama 3.1 70B as fallback)
- Max iterations: 60 per task
- Memory budget: ~800 tokens (MEMORY.md) + ~500 tokens (USER.md)

---

## GSI Demo Talking Points (commit to memory)

1. **Model-agnostic** — no vendor lock-in, switch providers in one command
2. **Institutional knowledge capture** — skills compound: 1st deploy is manual, 10th is one command
3. **Cross-platform ops** — Telegram → TUI → Discord, agent maintains context
4. **Compliance-ready** — 5 sandbox backends, session logging, skill quarantine, air-gap support
5. **Open source (MIT)** — no licensing risk, portable agentskills.io format
6. **Dual-use for training** — same agent architecture powers Nous RL training pipeline

---

## Industry Verticals Covered

| Vertical | Key Firms | Primary Demo Scenario |
|----------|-----------|----------------------|
| Financial Services | Visa, JPMorgan, Goldman | Fraud detection MLOps, vLLM latency diagnosis |
| Healthcare | UnitedHealth, Pfizer, Mayo | Clinical RAG over 2M documents |
| Telecommunications | AT&T, Verizon, Motorola Solutions | Network anomaly detection at 50K towers |
| Retail | Walmart, Amazon, Target | Black Friday 10x traffic scaling |
| Public Sector | DoD, federal agencies | Document intelligence, 100K forms/day |

---

## Conventions

- Save demo scripts under `demos/<vertical>.md`
- Custom skills go under `skills/<category>/<skill-name>/SKILL.md`
- Copy-paste ready queries should be in code blocks, not prose
- All one-shot hermes queries should be tested before adding to playbook

---

## Owner Context

Built by **Waseem Habib** for the NVIDIA GSI DevRel interview (JR1995349, late March 2026).
This demo positions Hermes as a concrete example of agentic MLOps tooling that GSI partners
can adopt and customize for their Fortune 500 engagements.
