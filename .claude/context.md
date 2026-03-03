# Hermes Project — Session Context

## Current Goal

Transform the Hermes Agent playbook into a live, demo-ready GSI presentation asset.
The playbook exists as source material — the work now is curating, refining, and
packaging it for an actual GSI audience (SAs, DevRel, ML Platform teams).

## Current Phase

**Phase 4: In Progress** (2026-03-03)
- [x] Project directory + memory system initialized (2026-02-27)
- [x] Full 10-part playbook saved as playbook.md
- [x] 5 per-vertical demo scripts created (demos/)
- [x] install.sh built + live at hermes.qbitloop.com
- [x] GitHub repo created: github.com/QbitLoop/hermes
- [x] GitHub Pages enabled: hermes.qbitloop.com
- [x] GSI handout built: hermes.qbitloop.com/assets/gsi-handout.html
- [x] SA field guide built: hermes.qbitloop.com/assets/guide.html (3 real screenshots, 5 sections)
- [x] NousResearch attribution added to index + guide with repo link
- [ ] Blueprint architecture visual: assets/blueprint.html (NVIDIA-style flow diagram)

## Strategic Context

This is for the **NVIDIA GSI DevRel interview (JR1995349, late March 2026)**.
Hermes Agent serves as a concrete, tangible demo of agentic MLOps tooling —
the kind of thing GSI partners (Accenture, Deloitte, Capgemini) would deploy
for Fortune 500 ML platform engagements.

It complements the AI-Q GSI Research Assistant demo (aiq-gsi-demo repo on Brev L40S)
as a second demo artifact showing different dimensions of AI-native operations.

## Key Decisions Made

- **Source material**: Full 10-part playbook provided by user (2026-02-27)
- **Structure**: CLAUDE.md memory system (not hybrid-init) — appropriate scale
- **Demo strategy**: 5 industry verticals × 4-6 copy-paste queries each
- **LLM provider for demos**: OpenRouter (flexibility, no lock-in narrative)

## Open Questions

1. Should `demos/` be self-contained scripts or links back to `playbook.md` sections?
2. Does the user want a visual one-pager (HTML, Brand-WHFT) for GSI handouts?
3. Which vertical should be the primary "hero" demo for the NVIDIA interview?
4. Is there a live Hermes installation to test queries against, or is this doc-only?

## Files To Create

```
demos/finance.md
demos/healthcare.md
demos/telecom.md           ← likely hero demo (Motorola Solutions angle)
demos/retail.md
demos/public-sector.md
assets/architecture.md     ← architecture diagram notes
```

---
*Last updated: 2026-03-01 | Phase 3 complete — all deliverables live*
