# Hermes Guide — Content Notes

## Tool Call Explanations (for "How It Works" section)

When you send a prompt, Hermes shows its reasoning in real time via tool calls:

| Call | What it means |
|------|--------------|
| `📚 skill finance` | Loaded the `finance-mlops` SKILL.md — now knows fraud detection patterns, SR 11-7 model risk rules, vLLM workflows |
| `📚 skill weights-and-biases` | Loaded W&B skill — uses experiment tracking to find when model drift started |
| `📚 skill vllm` | Loaded vLLM skill — for diagnosing the inference serving layer |
| `📚 skill instructor` | Loaded Instructor skill — for structured output when extracting model diagnostics |
| `💡 computing... (48.2s)` | Synthesizing all loaded skills into a coherent diagnosis plan |

**Key insight for the guide:** The agent pulled 4 relevant skills automatically from one plain-English prompt. No one told it to load W&B or vLLM — it reasoned that a fraud detection outage would involve those tools. This is the **institutional knowledge capture** talking point in action.

---

## Screenshots Captured

| File | What it shows |
|------|--------------|
| `assets/Hermes-Agent.png` | Hero shot — TUI startup, tools + skills panel, pixel art banner |
| `assets/screenshots/02-mlops-skills.png` | Agent response listing all 24 MLOps skills with descriptions |

---

## Demo Queries Tested

### MLOps Skills Overview
```
What MLOps skills do I have installed and what can each one do?
```
Result: Clean categorized list of 24 skills across Training, Inference, Vector DBs, Vision, Eval, Industry verticals.

### Fraud Detection Diagnosis
```
A fraud model in production started missing transactions — false negative rate jumped from 2% to 8% overnight. Walk me through how you'd diagnose and fix this using the finance-mlops skill.
```
Result: Agent auto-loaded finance, weights-and-biases, vllm, instructor skills — then produced full diagnosis workflow.

---

## Demo Response: Fraud Detection Diagnosis

**Prompt used:**
```
A fraud model in production started missing transactions — false negative rate jumped from 2% to 8% overnight. Walk me through how you'd diagnose and fix this using the finance-mlops skill.
```

**Skills auto-loaded by agent:** finance-mlops, weights-and-biases, vllm, instructor

**Response structure (4 phases):**
- Phase 1: Triage — 5 root cause checks (feature pipeline, model swap, threshold shift, data drift, label lag)
- Phase 2: Fix for each root cause (fallback model, retrain, vLLM timeout handling)
- Phase 3: SR 11-7 governance & W&B artifact documentation
- Phase 4: Prevention — Modal scheduled monitoring, W&B alerts, canary deployment

**Tool assignment summary (from response):**

| Step | Tool | Why |
|------|------|-----|
| Feature drift detection | W&B | Log PSI, compare distributions, governance artifacts |
| Model version audit | W&B Registry | Check who deployed what, when |
| Serving diagnostics | vLLM metrics | Latency, cache usage, throughput |
| FN cluster analysis | Instructor | Structured extraction of new fraud pattern |
| Threshold re-tuning | W&B Sweeps | Bayesian optimization of threshold + class weights |
| Burst retraining | Modal | Spin up GPUs for fast retrain |
| Incident documentation | W&B Artifacts | SR 11-7 compliant audit trail |
| Ongoing monitoring | Modal + W&B | Scheduled feature health checks + automated alerts |

**Key quote for guide:**
> "NEVER let a system failure (timeout, null feature, broken pipeline) default to 'NOT FRAUD'. If anything in the pipeline is uncertain, route to the MANUAL REVIEW QUEUE."

---

---

## Demo Response: Telecom Hero Demo (HERO CONTENT)

**Prompt used:**
```
I manage 50,000 cell towers for a major carrier. Three towers in the Chicago cluster showed anomalous traffic patterns at 2am. Walk me through how you'd diagnose this using the telecom-mlops skill.
```

**Skills auto-loaded:** telecom-mlops, SAELens, Modal, Qdrant, Instructor

**Response structure (6 phases):**
- Phase 1: Identify the 3 towers — adjacency check, metadata pull
- Phase 2: KPI snapshot — 5 anomaly fingerprints (backhaul failure, signaling storm, config push, SIM farm, RF interference)
- Phase 3: SAELens deep diagnosis on Modal — feature decomposition showing CHI-4412 backhaul_saturation at 15.3x
- Phase 4: Incident RAG via Qdrant — finds similar fiber cut 4 months ago, same tower, same crew
- Phase 5: What-if cascade analysis — predicts 18% drop rate at morning rush if unresolved
- Phase 6: Auto-generates structured work order via Instructor

**Key quote for guide:**
> "Traditional monitoring tells you '3 towers are red.' This tells you CHI-4412 backhaul died, the same fiber that got cut in November, neighbors are absorbing traffic, and you have until 7 AM before the cluster collapses — here's the work order."

**Timeline summary (SCREENSHOT THIS):**

| Time | Action | Tool |
|------|--------|------|
| 02:00 AM | Alert fires on 3 towers | Monitoring system |
| 02:02 | Pull tower metadata + adjacency | Tower DB |
| 02:05 | KPI snapshot, identify fingerprint | KPI pipeline |
| 02:10 | SAELens diagnosis → "CHI-4412 backhaul failure" | Modal + SAELens |
| 02:15 | Incident RAG → "Fiber cut Nov, same tower" | Qdrant |
| 02:20 | Cascade prediction → "18% drop rate by 7 AM" | SAELens steering |
| 02:25 | Work order generated + dispatched | Instructor |
| 02:30 | Microwave backup activated | NOC manual action |
| 04:15 | Fiber splice complete | Field crew |
| 04:30 | All KPIs return to baseline | Monitoring confirms |
| **Total diagnose** | **10 minutes** | SAELens + Qdrant |
| **Total mitigate** | **30 minutes** | Microwave backup |
| **Total resolve** | **2h 15m** | Fiber repair |
| **Morning rush** | **AVOIDED** | |

---

## Pending Screenshots

| # | What to capture | Command/prompt |
|---|----------------|---------------|
| 3 | Full fraud diagnosis response | (already running) |
| 4 | Telecom hero demo | `I manage 50,000 cell towers for a major carrier. Three towers in the Chicago cluster showed anomalous traffic patterns at 2am. Walk me through how you'd diagnose this using the telecom-mlops skill.` |
| 5 | `hermes skills` list | `/skills` in TUI |
