# Hermes Project — Insights & Findings

> APPEND ONLY — do not delete previous entries.
> Each entry should note source and date.

---

## Architecture Insights

*Source: playbook.md (user-provided) | 2026-02-27*

- **Agent is lightweight** — no GPU required to run Hermes itself. GPU only matters when
  the agent dispatches training or inference workloads. This is a key GSI talking point:
  low barrier to demo, no hardware dependency.

- **ReAct loop capped at 60 iterations** — longer tasks are handled, but multi-hour
  ML training jobs need cron scheduling, not a single agent turn.

- **Memory is tiered** — Session (ephemeral) → Persistent MEMORY.md (~800 tok) →
  USER.md (~500 tok) → Skills (unlimited SKILL.md files). The agent self-manages its
  own MEMORY.md via the `memory` tool. This is architecturally analogous to the COALA
  framework (episodic + procedural memory).

- **Skills are portable** — agentskills.io format works across Claude Code, VS Code,
  Cursor, Goose, and Amp. MIT license. This matters for GSI adoption narrative:
  no lock-in to Hermes agent specifically.

---

## Demo Strategy Insights

*Source: playbook.md (Parts 4–5) | 2026-02-27*

- **Hero demo candidate: Telecom vertical** — The Motorola Solutions angle (50K tower
  anomaly detection) gives Waseem direct personal credibility. He can speak to the
  domain from ASSIST AI and DDaaS experience. Strong fit for NVIDIA GSI interview.

- **Best "wow moment" sequence** — Persistent memory demo (Session 1 → Session 2) is
  the most viscerally impressive for non-technical GSI stakeholders. Show this early.

- **Skill self-creation** is the second strongest moment — agent solving a workflow,
  then writing a SKILL.md for future use. Maps to the "institutional knowledge capture"
  talking point.

- **Cron scheduling** demonstrates async/autonomous operations — not just a chatbot.
  Frame this as "the agent runs your MLOps on a schedule without babysitting."

---

## GSI Positioning Insights

*Source: playbook (Part 10) | 2026-02-27*

- GSI firms care about **Time-to-Value** reduction for their ML platform buildouts.
  The skills compounding story (1st deploy manual → 10th is one command) directly
  speaks to this.

- **Compliance** framing is table stakes for regulated industries. Five sandbox backends
  + session logging + skill quarantine covers the standard checklist. Lead with Docker
  sandbox for isolation, mention air-gap support for DoD/federal.

- **Dual-use for training** — Nous uses same architecture for RL trajectory generation.
  This is the "ceiling" pitch: clients start with ops agent, graduate to training custom
  domain-specific agents on their own data. Strong NVIDIA NIM integration story here.

---

## Warnings & Gotchas

- Community skills go through quarantine — don't demo `hermes skills install` live
  without pre-installing and approving skills beforehand.
- Gateway mode (Telegram/Discord bridge) requires pre-configured bot tokens.
  Set up and test before any live demo.
- `hermes doctor` is the fastest way to surface broken config — always run this
  before a demo, not during.

---

## Remote Install Architecture

*Decided: 2026-02-27*

- Subdomain: `hermes.qbitloop.com` — cleaner than path-based URL
- Pattern: `curl -fsSL https://hermes.qbitloop.com/install.sh | bash`
- Two-phase install: (1) NousResearch base install, (2) QbitLoop enterprise MLOps skills overlay
- Host options: GitHub Pages with CNAME `hermes.qbitloop.com` → `qbitloop.github.io/hermes`
- The install.sh wrapper is the demo's own "wow moment" — one command, fully configured

## Open Research

- Is there a live Hermes installation available to test queries? (Not confirmed yet)
- What's the current version of hermes-agent on GitHub? (Check before finalizing install docs)
- Does OpenRouter support Hermes-3 natively, or does it need Nous Portal?

---
*Last updated: 2026-02-27*
