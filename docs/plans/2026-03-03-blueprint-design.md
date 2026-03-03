# Hermes Blueprint — Design Document

**Date:** 2026-03-03
**File to create:** `assets/blueprint.html`
**Audience:** GSI Solutions Architects, DevRel Engineers, ML Platform teams
**Purpose:** NVIDIA-blueprint-style architecture flow diagram showing the full Hermes Agent system — orchestration layer, ML lifecycle, and all 24 skills mapped to their pipeline stage

---

## Design System

Match existing site tokens:
- Background: `#0d1117`
- Card/lane: `#161b22`
- Border: `#30363d`
- Font: `Courier New`, monospace
- Icons: Google Material Icons via CDN (one `<link>` in `<head>`)

---

## Layout

Three horizontal swim lanes, left-to-right flow, separated by dashed dividers with left-side lane labels.

```
┌─────────────────────────────────────────────────────────────────┐
│ ORCHESTRATION  │ User → Hermes Core → Skill Loader → Tool Dispatch → LLM → Response
├─────────────────────────────────────────────────────────────────┤  (dashed)
│ ML LIFECYCLE   │ Ingest → Embed → Vision → Train → Eval → Serve → Output → Apply → Monitor
├─────────────────────────────────────────────────────────────────┤  (dashed)
│ SKILLS (24)    │ [tokenizers] [chroma pinecone qdrant] [clip sam] [axolotl unsloth] ...
└─────────────────────────────────────────────────────────────────┘
```

Vertical dotted connector lines drop from each lifecycle stage node down to the skills beneath it.
The Skill Loader in the top lane has a sweep arrow down to the entire skills layer (auto-selection behavior).

---

## Color Coding

Hermes-specific palette — not a replica of NVIDIA:

| Node Type | Shape | Color | Material Icon |
|-----------|-------|-------|---------------|
| Orchestrator (Hermes Core) | Rounded rect | `#58a6ff` blue | `hub` |
| LLM / Model | Hexagon | `#56d364` green | `psychology` |
| Tool / Process | Circle | `#e3b341` amber | `build` |
| Vector DB / Data Store | Diamond | `#bc8cff` purple | `storage` |
| Training node | Rounded rect | `#e3b341` amber | `model_training` |
| Evaluation node | Rounded rect | `#e3b341` amber | `analytics` |
| Serving node | Rounded rect | `#e3b341` amber | `cloud` |
| Industry Vertical | Pill badge | `#ff7b72` coral | `domain` |
| User | Circle | `#8b949e` gray | `person` |
| Output / Response | Circle | `#8b949e` gray | `chat` |

---

## Swim Lane 1: Orchestration (runtime query flow)

```
[User] ──► [Hermes Core]  ──► [Skill Loader] ──► [Tool Dispatch] ──► [LLM Provider] ──► [Response]
 person      hub (blue)         build (amber)      build (amber)       psychology (green)   chat
             ReAct Loop         Auto-selects        Routes to           OpenRouter /
             60 iterations      from 24 skills      right tool          Hermes-3 / Custom
```

Memory feeds into Hermes Core from a side node:
- Session memory
- MEMORY.md (~800t)
- USER.md (~500t)

Sandbox feeds into Tool Dispatch from below:
- Local / Docker / Modal / E2B / SSH

---

## Swim Lane 2: ML Lifecycle (pipeline stages)

Nine stages left to right — each is a labeled box that connects up to the Orchestration lane and down to the Skills lane:

```
Ingest &     Embed &      Vision &     Train        Evaluate     Serve /      Structure    Apply        Monitor
Tokenize     Index        Multimodal                             Infer        Output       (RAG)
```

---

## Swim Lane 3: Skills Layer (all 24, mapped by stage)

| Stage | Skills |
|-------|--------|
| Ingest & Tokenize | `huggingface-tokenizers` |
| Embed & Index | `chroma` · `pinecone` · `qdrant` |
| Vision & Multimodal | `clip` · `segment-anything` |
| Train | `axolotl` · `unsloth` |
| Evaluate | `harness` · `SAELens` · `weights-and-biases` |
| Serve / Infer | `vllm` · `llama-cpp` · `modal` · `lambda-labs` |
| Structure Output | `instructor` · `outlines` · `dspy` |
| Apply (Industry RAG) | `finance-mlops` · `healthcare-mlops` · `telecom-mlops` · `retail-mlops` · `public-sector-mlops` |
| Monitor | `weights-and-biases` · `SAELens` · `ml-paper-writing` |

W&B and SAELens appear at Evaluate and Monitor — labeled with a small "multi-stage" indicator.

---

## Icon Implementation

```html
<head>
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
</head>

<!-- Usage -->
<span class="material-icons" style="font-size:20px;">hub</span>
```

No JS. Icon nodes are `<div>` elements with flexbox centering, Material Icon `<span>`, and a label below.

---

## Node CSS Pattern

```css
.node {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.3rem;
}
.node-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;          /* circle — override per shape */
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
}
.node-icon.blue   { background: #1a3a5c; border: 1.5px solid #58a6ff; color: #58a6ff; }
.node-icon.green  { background: #1a3a2a; border: 1.5px solid #56d364; color: #56d364; }
.node-icon.amber  { background: #3a2e0d; border: 1.5px solid #e3b341; color: #e3b341; }
.node-icon.purple { background: #2a1a3a; border: 1.5px solid #bc8cff; color: #bc8cff; }
.node-icon.coral  { background: #3a1a1a; border: 1.5px solid #ff7b72; color: #ff7b72; }
.node-icon.gray   { background: #21262d; border: 1.5px solid #8b949e; color: #8b949e; }
.node-label {
  font-size: 0.65rem;
  color: #8b949e;
  text-align: center;
  max-width: 72px;
  line-height: 1.3;
}
```

Hexagon shape for LLM nodes via CSS `clip-path: polygon(...)`.

---

## Arrows

CSS borders + `::after` pseudo-elements for horizontal arrows between nodes.
Vertical connectors (lane 2 → lane 3) via dotted `border-left` on a `<div>`.

---

## Page Header

Matches `gsi-handout.html` pattern:
- Badge: "Architecture Blueprint"
- Title: "Hermes Agent — System Architecture"
- Subtitle: "Orchestration · ML Lifecycle · 24 Skills · Powered by NousResearch"
- Link to `guide.html` and `gsi-handout.html`

---

## Footer

```html
<div class="links">
  <a href="guide.html">Field Guide</a>
  <a href="gsi-handout.html">GSI Reference</a>
  <a href="../index.html">Install</a>
  <a href="https://github.com/QbitLoop/hermes">GitHub</a>
</div>
```

---

## Link from index.html

Add to `.links` div:
```html
<a href="assets/blueprint.html">Architecture</a>
```
