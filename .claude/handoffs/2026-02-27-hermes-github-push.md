# Hermes Agent — GitHub Push & Pages Setup

## 1. Primary Request and Intent

Waseem is building the **Hermes Agent Enterprise MLOps Demo Playbook** at `/Users/w/Desktop/AI2026-C/Publisher/Hermes/` — a full demo toolkit for NousResearch's Hermes Agent targeting GSI partner conversations (Accenture, Deloitte, Capgemini, etc.) as part of his NVIDIA GSI DevRel interview (JR1995349, late March 2026).

All content is complete. The final step before this handoff is **pushing to GitHub as a public repo** and **enabling GitHub Pages** so `hermes.qbitloop.com` serves the landing page and install script live.

The user was SSH'd into their machine and could not run the interactive `gh auth login` command. They will do it from their actual terminal.

## 2. Key Technical Concepts

- **NousResearch Hermes Agent** — terminal-based AI agent, ReAct loop, 40+ tools, agentskills.io SKILL.md format
- **GitHub Pages** — serving `hermes.qbitloop.com` via CNAME → `qbitloop.github.io`
- **DNS already configured** — CNAME record: `hermes` → `qbitloop.github.io.` (1hr TTL, already live)
- **install.sh** — 4-phase enterprise installer: NousResearch base → env setup → MEMORY.md seed → vertical skill stubs
- **5 demo verticals** — Finance, Healthcare, Telecom (hero), Retail, Public Sector
- **gh CLI** — used for repo creation and Pages API call; token was expired at handoff

## 3. Files and Code Sections

### All staged files (git init done on `main`, all 14 files staged, no commits yet):
```
/Users/w/Desktop/AI2026-C/Publisher/Hermes/
├── CLAUDE.md
├── CNAME                        ← contains: hermes.qbitloop.com
├── .gitignore
├── index.html                   ← landing page for hermes.qbitloop.com
├── install.sh                   ← 4-phase enterprise installer (executable)
├── playbook.md                  ← full 10-part source playbook
├── demos/
│   ├── telecom.md               ← HERO DEMO for NVIDIA interview
│   ├── finance.md
│   ├── healthcare.md
│   ├── retail.md
│   └── public-sector.md
└── .claude/
    ├── context.md
    ├── todos.md
    ├── insights.md
    └── handoffs/
        └── 2026-02-27-hermes-github-push.md  ← this file
```

## 4. Problem Solving

- **gh CLI token expired** — blocked the push. User must run `gh auth login` interactively.
- **Private vs Public** — user confirmed PUBLIC repo so GitHub Pages works on free plan.
- **DNS** — already configured by user before handoff. CNAME file is in repo root.

## 5. Pending Tasks

| # | Task | Status |
|---|------|--------|
| 3 | Create public GitHub repo `QbitLoop/hermes` and push | Blocked on `gh auth login` |
| 8 | `install.sh` for `hermes.qbitloop.com` | Done locally, needs push |
| 9 | Architecture notes / HTML one-pager (GSI handout) | Not started |

## 6. Current Work — EXACT COMMANDS TO RUN

Everything is staged. Run these 3 commands in order from a local (non-SSH) terminal:

```bash
# Step 1 — Re-authenticate gh CLI (browser-based, interactive)
gh auth login
# → GitHub.com → HTTPS → Login with a web browser

# Step 2 — Create public repo and push all 14 staged files
cd /Users/w/Desktop/AI2026-C/Publisher/Hermes
gh repo create QbitLoop/hermes --public --source=. --remote=origin --push

# Step 3 — Enable GitHub Pages (root of main branch)
gh api repos/QbitLoop/hermes/pages \
  --method POST \
  --field source='{"branch":"main","path":"/"}' \
  --field build_type="legacy"
```

After step 3, `hermes.qbitloop.com` goes live within ~5 minutes.

## 7. Next Step

After the push is confirmed live, the remaining optional task is **Task #9** — an HTML architecture one-pager / GSI handout using Brand-MSI or Brand-WHFT design system. Use `/pickup 2026-02-27-hermes-github-push` to resume.
