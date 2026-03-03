# Crow Rebrand Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename the entire Hermes Agent project to "Crow Agent" — all HTML pages, CLI alias, domain, and GitHub repo — with the Crow logo integrated on every page.

**Architecture:** Text replacement across 4 HTML files + install.sh + CNAME. Logo (`assets/crow-logo.png`) added to all HTML pages with a flex header layout. Gold badge color `#D4A017` replaces `#1f6feb` blue on badges. `crow` CLI wrapper installed alongside `hermes` binary. GitHub repo renamed last before push. GoDaddy DNS edited by user as final step.

**Tech Stack:** HTML5, CSS, Bash (install.sh), GitHub CLI (`gh`), Git.

**Design reference:** `docs/plans/2026-03-03-crow-rebrand-design.md`

---

### Task 1: Rename logo file

**Files:**
- Rename: `assets/Crow.qbitloop.com.png` → `assets/crow-logo.png`

**Step 1: Copy to clean filename**

```bash
cp /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/Crow.qbitloop.com.png \
   /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/crow-logo.png
```

**Step 2: Verify**

```bash
ls -lh /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/crow-logo.png
```

Expected: file exists, ~3.6MB

**Step 3: Verify transparency**

```bash
python3 -c "
from PIL import Image
img = Image.open('/Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/crow-logo.png')
print('Mode:', img.mode)
print('Size:', img.size)
"
```

Expected: `Mode: RGBA`

**Step 4: Commit**

```bash
cd /Users/w/Desktop/AI2026-C/Publisher/Hermes
git add assets/crow-logo.png
git commit -m "feat: add crow-logo.png (RGBA transparent)"
```

---

### Task 2: Update index.html

**Files:**
- Modify: `index.html`

**Step 1: Add brand-header CSS to the `<style>` block**

Find:
```css
    .badge {
```

Insert immediately before it:
```css
    .brand-header {
      display: flex;
      align-items: center;
      gap: 1.25rem;
      margin-bottom: 2rem;
    }
    .brand-logo {
      height: 80px;
      width: auto;
      flex-shrink: 0;
    }
```

**Step 2: Change badge background color**

Find:
```css
    .badge {
      display: inline-block;
      background: #1f6feb;
```

Replace with:
```css
    .badge {
      display: inline-block;
      background: #D4A017;
```

**Step 3: Update `<title>`**

Find:
```html
  <title>Hermes Agent — Enterprise MLOps Edition</title>
```

Replace with:
```html
  <title>Crow Agent — Enterprise MLOps Edition</title>
```

**Step 4: Replace header block with brand-header**

Find:
```html
    <div class="badge">Enterprise MLOps Edition</div>
    <h1>Hermes Agent</h1>
    <p class="sub">Terminal AI agent with 40+ tools and curated MLOps skills<br>Built on <a href="https://github.com/NousResearch/hermes-agent" style="color:#58a6ff;text-decoration:none;">NousResearch hermes-agent</a> · Enterprise MLOps overlay by QbitLoop</p>
```

Replace with:
```html
    <div class="brand-header">
      <img src="assets/crow-logo.png" alt="Crow" class="brand-logo">
      <div>
        <div class="badge">Enterprise MLOps Edition</div>
        <h1>Crow Agent</h1>
        <p class="sub">Terminal AI agent with 40+ tools and curated MLOps skills<br>Built on <a href="https://github.com/NousResearch/hermes-agent" style="color:#58a6ff;text-decoration:none;">NousResearch hermes-agent</a> · Enterprise MLOps overlay by QbitLoop</p>
      </div>
    </div>
```

**Step 5: Verify in browser**

```bash
open /Users/w/Desktop/AI2026-C/Publisher/Hermes/index.html
```

Expected: Crow logo left of "Crow Agent" title, gold badge, logo has no white box around it.

**Step 6: Commit**

```bash
git add index.html
git commit -m "feat: crow rebrand — index.html (logo, gold badge, rename)"
```

---

### Task 3: Update assets/guide.html

**Files:**
- Modify: `assets/guide.html`

**Step 1: Add brand-header CSS**

Find:
```css
    .badge {
```

Insert immediately before it:
```css
    .brand-header {
      display: flex;
      align-items: center;
      gap: 1.25rem;
      margin-bottom: 2rem;
    }
    .brand-logo {
      height: 80px;
      width: auto;
      flex-shrink: 0;
    }
```

**Step 2: Change badge background to gold**

Find in `assets/guide.html`:
```css
      background: #1f6feb;
```

Replace with:
```css
      background: #D4A017;
```

**Step 3: Update `<title>`**

Find:
```html
  <title>Hermes Agent — Enterprise Guide</title>
```

Replace with:
```html
  <title>Crow Agent — Enterprise Guide</title>
```

**Step 4: Replace header block**

Find:
```html
  <div class="badge">Enterprise MLOps Edition</div>
  <h1>Hermes Agent — Field Guide</h1>
  <p class="sub">
    A terminal AI agent with 40+ tools and 51 industry skills.<br>
    Built on <a href="https://github.com/NousResearch/hermes-agent" style="color:#58a6ff;text-decoration:none;">NousResearch hermes-agent</a> · Enterprise MLOps overlay by QbitLoop
  </p>
```

Replace with:
```html
  <div class="brand-header">
    <img src="crow-logo.png" alt="Crow" class="brand-logo">
    <div>
      <div class="badge">Enterprise MLOps Edition</div>
      <h1>Crow Agent — Field Guide</h1>
      <p class="sub">
        A terminal AI agent with 40+ tools and 51 industry skills.<br>
        Built on <a href="https://github.com/NousResearch/hermes-agent" style="color:#58a6ff;text-decoration:none;">NousResearch hermes-agent</a> · Enterprise MLOps overlay by QbitLoop
      </p>
    </div>
  </div>
```

**Step 5: Replace all `hermes chat -q` demo commands with `crow chat -q`**

There are multiple demo commands in the verticals section and get-started section. Replace ALL instances:

Find (replace_all): `hermes chat -q`
Replace with: `crow chat -q`

Also find: `hermes` in the get-started steps (step 3 and 4 code blocks):

Find:
```html
          <div class="code-block">hermes</div>
```
Replace with:
```html
          <div class="code-block">crow</div>
```

Find:
```html
            hermes chat -q "What MLOps skills do I have installed and what can each one do?"
```
Replace with:
```html
            crow chat -q "What MLOps skills do I have installed and what can each one do?"
```

Find:
```html
            hermes chat -q "I manage 50,000 cell towers. Three towers in the Chicago cluster showed anomalous traffic patterns at 2am. Walk me through how you'd diagnose this using the telecom-mlops skill."
```
Replace with:
```html
            crow chat -q "I manage 50,000 cell towers. Three towers in the Chicago cluster showed anomalous traffic patterns at 2am. Walk me through how you'd diagnose this using the telecom-mlops skill."
```

**Step 6: Verify in browser**

```bash
open /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/guide.html
```

Expected: Logo left of "Crow Agent — Field Guide", gold badge, all demo commands show `crow chat -q`.

**Step 7: Commit**

```bash
git add assets/guide.html
git commit -m "feat: crow rebrand — guide.html (logo, rename, crow commands)"
```

---

### Task 4: Update assets/gsi-handout.html

**Files:**
- Modify: `assets/gsi-handout.html`

**Step 1: Add brand-header CSS**

Find in `assets/gsi-handout.html`:
```css
    .badge {
```

Insert immediately before it:
```css
    .brand-header {
      display: flex;
      align-items: center;
      gap: 1.25rem;
      margin-bottom: 1.5rem;
    }
    .brand-logo {
      height: 80px;
      width: auto;
      flex-shrink: 0;
    }
```

**Step 2: Change badge background to gold**

Find:
```css
      background: #1f6feb;
```

Replace with:
```css
      background: #D4A017;
```

**Step 3: Update `<title>`**

Find:
```html
  <title>Hermes Agent — GSI Reference</title>
```

Replace with:
```html
  <title>Crow Agent — GSI Reference</title>
```

**Step 4: Replace header block**

Find:
```html
<div class="badge">Enterprise MLOps Edition</div>
<h1>Hermes Agent — GSI Reference</h1>
<p class="sub">Architecture · Industry Verticals · Key Commands · Powered by NousResearch</p>
```

Replace with:
```html
<div class="brand-header">
  <img src="crow-logo.png" alt="Crow" class="brand-logo">
  <div>
    <div class="badge">Enterprise MLOps Edition</div>
    <h1>Crow Agent — GSI Reference</h1>
    <p class="sub">Architecture · Industry Verticals · Key Commands · Powered by NousResearch</p>
  </div>
</div>
```

**Step 5: Replace install command**

Find:
```html
  <div class="install-cmd"><span>curl</span> -fsSL https://hermes.qbitloop.com/install.sh | bash</div>
```

Replace with:
```html
  <div class="install-cmd"><span>curl</span> -fsSL https://crow.qbitloop.com/install.sh | bash</div>
```

**Step 6: Replace all `hermes chat -q` with `crow chat -q`**

Find (replace_all): `hermes chat -q`
Replace with: `crow chat -q`

**Step 7: Verify in browser**

```bash
open /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/gsi-handout.html
```

Expected: Logo + "Crow Agent — GSI Reference", gold badge, install command shows crow.qbitloop.com.

**Step 8: Commit**

```bash
git add assets/gsi-handout.html
git commit -m "feat: crow rebrand — gsi-handout.html (logo, rename, crow commands)"
```

---

### Task 5: Update assets/blueprint.html

**Files:**
- Modify: `assets/blueprint.html`

**Step 1: Add brand-header CSS**

Find in `assets/blueprint.html`:
```css
    /* header */
    .badge {
```

Insert immediately before it:
```css
    /* brand header */
    .brand-header {
      display: flex;
      align-items: center;
      gap: 1.25rem;
      margin-bottom: 2rem;
    }
    .brand-logo {
      height: 80px;
      width: auto;
      flex-shrink: 0;
    }
```

**Step 2: Update `<title>`**

Find:
```html
  <title>Hermes Agent — System Architecture</title>
```

Replace with:
```html
  <title>Crow Agent — System Architecture</title>
```

**Step 3: Replace header block**

Find:
```html
  <div class="badge">Architecture Blueprint</div>
  <h1>Hermes Agent — System Architecture</h1>
  <p class="sub">
    Orchestration · ML Lifecycle · 24 Skills ·
    Built on <a href="https://github.com/NousResearch/hermes-agent">NousResearch hermes-agent</a>
  </p>
```

Replace with:
```html
  <div class="brand-header">
    <img src="crow-logo.png" alt="Crow" class="brand-logo">
    <div>
      <div class="badge">Architecture Blueprint</div>
      <h1>Crow Agent — System Architecture</h1>
      <p class="sub">
        Orchestration · ML Lifecycle · 24 Skills ·
        Built on <a href="https://github.com/NousResearch/hermes-agent">NousResearch hermes-agent</a>
      </p>
    </div>
  </div>
```

**Step 4: Change badge color**

Find in `assets/blueprint.html`:
```css
      background: #1f6feb;
```

Replace with:
```css
      background: #D4A017;
```

**Step 5: Verify in browser**

```bash
open /Users/w/Desktop/AI2026-C/Publisher/Hermes/assets/blueprint.html
```

Expected: Crow logo left of "Crow Agent — System Architecture", gold badge, 3-lane diagram unchanged below.

**Step 6: Commit**

```bash
git add assets/blueprint.html
git commit -m "feat: crow rebrand — blueprint.html (logo, rename, gold badge)"
```

---

### Task 6: Update install.sh + CNAME

**Files:**
- Modify: `install.sh`
- Modify: `CNAME`

**Step 1: Read current install.sh end**

```bash
tail -20 /Users/w/Desktop/AI2026-C/Publisher/Hermes/install.sh
```

**Step 2: Append crow wrapper to install.sh**

Add at the end of `install.sh`:

```bash
# Install crow CLI wrapper
if command -v hermes &> /dev/null; then
    CROW_BIN="/usr/local/bin/crow"
    cat > "$CROW_BIN" << 'CROWEOF'
#!/bin/bash
hermes "$@"
CROWEOF
    chmod +x "$CROW_BIN"
    echo "  ✓ crow command installed → hermes"
fi
```

**Step 3: Update CNAME file**

Overwrite with single line:
```
crow.qbitloop.com
```

**Step 4: Verify CNAME**

```bash
cat /Users/w/Desktop/AI2026-C/Publisher/Hermes/CNAME
```

Expected: `crow.qbitloop.com`

**Step 5: Commit**

```bash
git add install.sh CNAME
git commit -m "feat: crow CLI wrapper in install.sh + CNAME updated to crow.qbitloop.com"
```

---

### Task 7: Update CLAUDE.md and memory files

**Files:**
- Modify: `CLAUDE.md`
- Modify: `.claude/context.md`
- Modify: `.claude/todos.md`

**Step 1: Update CLAUDE.md project name**

Find:
```
# Hermes Agent — Claude Code Instructions

## Project Overview

**Hermes Agent** is an enterprise MLOps demo playbook for NousResearch's Hermes Agent.
```

Replace with:
```
# Crow Agent — Claude Code Instructions

## Project Overview

**Crow Agent** is an enterprise MLOps demo playbook built on NousResearch's Hermes Agent.
```

**Step 2: Update .claude/context.md**

Find:
```
## Current Goal

Transform the Hermes Agent playbook into a live, demo-ready GSI presentation asset.
```

Replace with:
```
## Current Goal

Transform the Crow Agent playbook into a live, demo-ready GSI presentation asset.
```

**Step 3: Add rebrand task to .claude/todos.md**

Add to Phase 4 completed tasks:
```
- [x] Rebrand Hermes → Crow — all HTML pages, logo, CLI wrapper, CNAME — 2026-03-03
```

**Step 4: Commit**

```bash
git add CLAUDE.md .claude/context.md .claude/todos.md
git commit -m "chore: crow rebrand — update CLAUDE.md and project memory"
```

---

### Task 8: Rename GitHub repo + push

> ⚠️ **AFTER this task, tell the user to edit GoDaddy before anything else.**

**Step 1: Rename the GitHub repo**

```bash
cd /Users/w/Desktop/AI2026-C/Publisher/Hermes
gh repo rename crow --repo QbitLoop/hermes
```

Expected output: `✓ Renamed repository QbitLoop/hermes to QbitLoop/crow`

GitHub automatically creates a permanent redirect from `github.com/QbitLoop/hermes`.

**Step 2: Update remote URL in local git config**

```bash
git remote set-url origin https://github.com/QbitLoop/crow.git
git remote -v
```

Expected:
```
origin  https://github.com/QbitLoop/crow.git (fetch)
origin  https://github.com/QbitLoop/crow.git (push)
```

**Step 3: Push all commits**

```bash
git push origin main
```

**Step 4: Verify GitHub Pages is building**

```bash
gh repo view QbitLoop/crow --web
```

Opens browser — check Actions tab for Pages build status.

---

### Task 9: GoDaddy DNS — USER ACTION REQUIRED

> ★ **STOP. The user must do this step manually. Do not proceed until confirmed.** ★

**Tell the user:**

> Go to GoDaddy → My Products → qbitloop.com → DNS Management
>
> Find the existing CNAME record:
> - **Name:** `hermes`
> - **Value:** `qbitloop.github.io`
>
> Edit it — change **only the Name field** from `hermes` to `crow`. Leave the value unchanged.
> Save.
>
> Then come back and confirm so we can verify the site is live.

**After user confirms — verify:**

```bash
curl -I https://crow.qbitloop.com
```

Expected: `HTTP/2 200` (may take 1–5 minutes for DNS to propagate)

---

### Task 10: Final verification + memory update

**Step 1: Check all pages load**

```bash
curl -sI https://crow.qbitloop.com | head -5
curl -sI https://crow.qbitloop.com/assets/guide.html | head -5
curl -sI https://crow.qbitloop.com/assets/blueprint.html | head -5
curl -sI https://crow.qbitloop.com/assets/gsi-handout.html | head -5
```

Expected: All return `HTTP/2 200`

**Step 2: Update persistent memory**

In `/Users/w/.claude/projects/-Users-w-Desktop-AI2026-C-Publisher/memory/MEMORY.md`:

- Change all "Hermes" → "Crow" in the Live URLs section
- Update repo reference to `QbitLoop/crow`
- Note rebrand complete

**Step 3: Final commit**

```bash
git add .
git commit -m "chore: crow rebrand complete — memory updated"
git push origin main
```
