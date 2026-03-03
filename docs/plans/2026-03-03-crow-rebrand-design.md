# Crow Rebrand — Design Document

**Date:** 2026-03-03
**Audience:** Internal — implementation reference
**Purpose:** Full rebrand from "Hermes" to "Crow" across all site files, logo integration, CLI alias, domain migration, and GitHub repo rename.

---

## Summary

The QbitLoop enterprise MLOps overlay is being rebranded from "Hermes Agent" to "Crow Agent". The underlying NousResearch hermes-agent binary is unchanged — Crow is the brand layer on top. A `crow` CLI wrapper is added so users type `crow chat -q "..."`.

---

## Brand Identity

| Element | Value |
|---------|-------|
| Brand name | Crow |
| Logo file | `assets/Crow.qbitloop.com.png` (RGBA transparent, 3.6MB) |
| Logo accent color | `#D4A017` (gold beak) — new brand accent |
| Existing blue accent | `#58a6ff` — retained for links and node icons |
| Badge background | `#D4A017` (replaces `#1f6feb` blue on badges) |
| Logo placement | Left of h1, ~80px tall, vertically centered |
| Attribution | "Built on NousResearch hermes-agent" — unchanged |

---

## Logo Placement (all 4 HTML pages)

```html
<div class="brand-header">
  <img src="crow-logo.png" alt="Crow" class="brand-logo">
  <div>
    <div class="badge">Enterprise MLOps Edition</div>
    <h1>Crow Agent</h1>
    <p class="sub">...</p>
  </div>
</div>
```

CSS:
```css
.brand-header { display: flex; align-items: center; gap: 1.25rem; margin-bottom: 2rem; }
.brand-logo { height: 80px; width: auto; flex-shrink: 0; }
```

Logo filename on disk: `assets/crow-logo.png` (rename from `Crow.qbitloop.com.png` for clean URLs).

---

## Files Changed

### HTML pages (text + logo)
| File | Changes |
|------|---------|
| `index.html` | Title, h1, sub text, badge — all "Hermes" → "Crow". Add logo. Badge color → `#D4A017`. |
| `assets/guide.html` | Same. All "Hermes Agent" → "Crow Agent". Logo added. |
| `assets/gsi-handout.html` | Same. |
| `assets/blueprint.html` | Same. Page title + h1 only (no badge on this page). |

### Demo commands (all 4 HTML pages + demos/)
`hermes chat -q` → `crow chat -q` everywhere it appears as a user-facing command.

### CLI installer
`install.sh` — append crow wrapper after existing install:
```bash
# Crow CLI alias
cat > /usr/local/bin/crow << 'EOF'
#!/bin/bash
hermes "$@"
EOF
chmod +x /usr/local/bin/crow
echo "  ✓ crow command installed"
```

### Domain
`CNAME` file: `hermes.qbitloop.com` → `crow.qbitloop.com`

### Project memory
`CLAUDE.md`, `.claude/context.md`, `.claude/todos.md` — update project name references.

---

## GitHub Repo Rename

```bash
gh repo rename crow --repo QbitLoop/hermes
```

GitHub automatically creates a permanent redirect from `github.com/QbitLoop/hermes` → `github.com/QbitLoop/crow`. All existing links continue to work.

---

## Execution Order (CRITICAL)

```
Step 1: Rename logo file (Crow.qbitloop.com.png → crow-logo.png)
Step 2: Update all 4 HTML pages (text + logo integration + badge color)
Step 3: Update install.sh (crow wrapper)
Step 4: Update CNAME file
Step 5: Update CLAUDE.md + .claude/ memory files
Step 6: Commit all changes
Step 7: Rename GitHub repo (gh repo rename)
Step 8: Push to GitHub
Step 9: ★ STOP — USER EDITS GODADDY ★
         Edit CNAME record: hermes → crow (target stays qbitloop.github.io)
Step 10: Verify crow.qbitloop.com is live
```

---

## What Does NOT Change

- NousResearch attribution: "Built on NousResearch hermes-agent" — kept verbatim
- Underlying `hermes` binary — unchanged, `crow` is a wrapper
- Screenshots (`Hermes-Agent.png`, `02-mlops-skills.png`, `03-telecom-timeline.png`) — kept as-is (they show the actual TUI)
- GitHub Dark design tokens — unchanged
- All tool names in blueprint (vllm, chroma, W&B etc.) — unchanged
