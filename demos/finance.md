# Financial Services Demo — Real-Time Fraud Detection MLOps

> **Target audience:** GSI SAs advising Visa, Mastercard, JPMorgan Chase, Goldman Sachs
> Presenter angle: Fraud detection at payment-network scale — latency, compliance, and model governance are non-negotiable

---

## The Story (60-Second Verbal Setup)

> "The conversation I have most often with financial services clients is around fraud
> detection — not building the model, but operating it at scale under regulatory scrutiny.
>
> The client I'll describe has a gradient-boosted fraud classifier that was working fine
> at 10K transactions per second. They re-platformed to vLLM to bring in an LLM-based
> reason-code generator, and now they're running 50K transactions per second. Yesterday's
> batch window hit a latency spike — 3x their SLA threshold. Compliance is asking for a
> full audit trail for model v3. And precision dropped 2% this week with no obvious cause.
>
> Three separate fires. Let's see what Hermes does with all three."

---

## Demo Sequence 1 — vLLM Latency Diagnosis (Open with this)

**Launch:**
```bash
hermes --toolsets ml
```

**Paste this query at the `⚕ ❯` prompt:**
```
Our fraud detection model is running on vLLM and scoring 50K transactions per second.
Yesterday during the nightly batch window, inference latency spiked 3x — from 18ms to
55ms. This is above our SLA threshold for card authorization. Walk me through a full
diagnosis of the vLLM latency spike.
```

**What the agent does:**
- Loads `vllm` skill automatically
- Identifies KV cache exhaustion as the primary suspect at high concurrency: explains PagedAttention memory blocks, shows how fragmentation builds during long batch windows
- Walks through continuous batching config — `--max-num-batched-tokens`, `--max-num-seqs`, `--gpu-memory-utilization` flags with specific recommended values for latency-sensitive workloads
- Explains the interaction between batch window timing and KV cache pressure (long sequences accumulate, block table overflows)
- Generates a diagnostic checklist:
  - Check `vllm_gpu_cache_usage_perc` metric — if above 0.92 during spike window, cache pressure confirmed
  - Review `--max-model-len` — truncating to max fraud transaction context length reduces block allocation
  - Enable `--enable-prefix-caching` if transaction preamble is repeated across requests
  - Tune `--swap-space` for CPU offload during burst
- Suggests W&B integration: log latency percentiles (p50/p95/p99) per batch window as custom metrics for drift correlation

**SA talking point while agent works:**
> "Notice it loaded the vLLM skill before responding — not a generic answer about
> inference latency, but PagedAttention block fragmentation, continuous batching
> configuration, and the specific flags to tune. That's the skills system compounding
> expertise. A generalist agent gives you documentation. This gives you the diagnosis."

---

## Demo Sequence 2 — Model Governance and Audit Trail

**One-shot from terminal (good if TUI feels slow):**
```bash
hermes chat -q "Set up a W&B project for fraud model v3 with artifact versioning so compliance can trace every model back to its training data and exact code commit. We need a full audit trail that satisfies SR 11-7 model risk management requirements."
```

**What the agent produces:**
- W&B project initialization config with `entity`, `project`, and `tags` structured for multi-environment tracking (dev / staging / prod)
- Artifact versioning setup: logs training dataset as `wandb.Artifact` with type `dataset`, links to model artifact with explicit `use_artifact()` lineage declaration
- Model registry configuration: promotion workflow from `staging` to `production` alias with required approval gate
- Commit hash capture: `wandb.config.update({"git_commit": subprocess.check_output(["git", "rev-parse", "HEAD"])})` embedded in training script
- Compliance-ready audit trail structure:
  - Model artifact → links to training data artifact → links to feature pipeline artifact
  - Every artifact stores: author, timestamp, git SHA, environment, data hash (SHA-256 of dataset)
- Report template for SR 11-7: model lineage graph export, champion/challenger comparison table, performance benchmark run links

**SA talking point:**
> "SR 11-7 is the Fed's model risk management guidance — every financial institution
> subject to Federal Reserve supervision has to demonstrate they can trace a model
> decision back to the training data and code that produced it. This audit trail is
> not a nice-to-have. It's a regulatory requirement. The agent just built the
> scaffolding for it in 90 seconds."

---

## Demo Sequence 3 — Root Cause Analysis Pipeline

**Paste this query at the `⚕ ❯` prompt:**
```
Our fraud model's precision dropped 2% this week — from 94.1% to 92.3%. That's
$4M in additional false positives at our transaction volume. Build a root cause
analysis plan: check data drift with embedding comparisons in Qdrant, pull the
latest eval scores from lm-evaluation-harness, and compare against last month's
checkpoint in W&B.
```

**What the agent does:**
- Loads `qdrant` + `lm-evaluation-harness` + `w&b` skills
- Produces a structured RCA plan in three phases:

  **Phase 1 — Data Drift Detection (Qdrant)**
  - Queries existing transaction embedding collection; computes cosine similarity distribution between this week's inference batch and last month's baseline sample
  - Flags drift if mean similarity drops below threshold (suggests 0.85 as starting point for fraud feature embeddings)
  - Identifies which feature clusters drifted most: merchant category codes, geographic velocity, device fingerprint vectors
  - Generates Qdrant filter query to isolate the drift cohort for downstream analysis

  **Phase 2 — Model Evaluation (lm-evaluation-harness)**
  - Builds eval harness config targeting fraud classification tasks
  - Compares precision/recall/F1 across current model vs last month's checkpoint on held-out validation set
  - Flags which transaction categories show the sharpest precision degradation
  - Outputs structured JSON comparison table

  **Phase 3 — Checkpoint Comparison (W&B)**
  - Pulls run history for `fraud-model-v3` via W&B API
  - Compares feature importance rankings between current run and last month's baseline run
  - Flags any training data composition changes logged as artifacts
  - Generates hypothesis list ranked by likelihood: merchant category shift, seasonal spending pattern, new card BIN range introduced

**SA talking point:**
> "A 2% precision drop at 50K transactions per second is not a model quality footnote —
> it's a dollar figure. The agent loaded three separate tools, structured the investigation
> across data drift, evaluation benchmarks, and training artifact history, and produced
> a ranked hypothesis list. This is what a senior ML engineer would spend two days building.
> The agent scaffolded it in the time it took me to explain the problem."

---

## Demo Sequence 4 — Constrained Output with Outlines (Close with this)

**One-shot from terminal:**
```bash
hermes chat -q "The fraud reason-code generator is hallucinating invalid codes — it's producing free-form strings like 'suspicious_pattern_detected' instead of our valid ISO 8583 response codes. Show me how to wrap it with Outlines to constrain the output to our valid JSON schema so hallucinated codes are structurally impossible."
```

**What the agent does:**
- Loads `outlines` skill
- Explains constrained decoding: Outlines operates at the token sampling level — invalid tokens are masked before sampling, so the model cannot produce a code that violates the schema regardless of its internal state
- Generates wrapper code:

```python
import outlines
import outlines.models as models
from pydantic import BaseModel
from typing import Literal

# Define valid fraud reason codes as a Literal type
FraudReasonCode = Literal[
    "05",   # Do not honor
    "14",   # Invalid card number
    "41",   # Lost card
    "43",   # Stolen card
    "51",   # Insufficient funds
    "54",   # Expired card
    "57",   # Transaction not permitted
    "62",   # Restricted card
    "91",   # Issuer unavailable
    "96",   # System malfunction
]

class FraudDecision(BaseModel):
    transaction_id: str
    decision: Literal["APPROVE", "DECLINE", "REVIEW"]
    reason_code: FraudReasonCode
    confidence_score: float
    review_flag: bool

# Load model through Outlines
model = models.transformers("fraud-classifier-v3", device="cuda")
generator = outlines.generate.json(model, FraudDecision)

# Inference — output is guaranteed to match FraudDecision schema
result = generator(f"Analyze transaction: {transaction_context}")
# result.reason_code will always be a valid ISO 8583 code
# Hallucinated codes are impossible at the decoding level
```

- Explains the compliance value: every fraud decline reason code logged to the audit trail is guaranteed valid — no post-hoc filtering, no regex sanitization, no runtime exception handling for malformed output
- Notes that Outlines integrates with vLLM's guided decoding backend for production throughput — no latency penalty

**SA talking point:**
> "This is the answer to the hallucination problem in regulated environments. Not prompt
> engineering. Not output filtering. Constrained decoding eliminates the possibility of
> an invalid output at the token sampling level — it's a mathematical guarantee, not a
> best-effort guard. For a bank that has to log every decline reason code to satisfy
> Reg E dispute resolution, that distinction matters enormously."

---

## Optional Sequence A — DSPy Prompt Optimization

> Use this if the audience includes ML engineers who have hand-written prompts in production.

```bash
hermes chat -q "We have a hand-written fraud classification prompt that's been patched 40 times over 18 months. Convert it to a DSPy module with a ChainOfThought signature so we can run systematic prompt optimization against our labeled fraud dataset instead of manually tuning it."
```

**What the agent produces:**
- DSPy `Signature` class that formalizes the fraud classification inputs/outputs: `transaction_context`, `merchant_data`, `velocity_features` → `decision`, `confidence`, `reasoning`
- `ChainOfThought` module wrapping the signature
- `BootstrapFewShot` optimizer config targeting F1 score on labeled validation set
- Migration path: maps existing hand-written prompt fields to DSPy input fields, preserves domain-specific context
- Benchmark harness: runs compiled vs hand-written prompt on holdout set, reports precision/recall delta

**SA talking point:**
> "Every financial client I talk to has a prompt that started as 10 lines and is now
> 400 lines of conditionals. DSPy replaces that with a learnable module — the optimizer
> finds the best prompt automatically, reproducibly, against your actual labeled data.
> You stop patching and start compiling."

---

## Optional Sequence B — Canary Deployment

> Use this if the audience is infrastructure-focused or the demo has momentum after Sequence 1.

```bash
hermes chat -q "We want to canary deploy fraud model v4 at 5% traffic before full cutover. Configure the vLLM load balancer to route 5% of transaction scoring requests to the v4 endpoint, log both model versions' decisions to W&B for comparison, and define the automated rollback condition if v4 precision drops below v3 baseline."
```

**What the agent produces:**
- vLLM load balancer config using `--served-model-name` aliasing to expose both model versions under a single endpoint
- Traffic split implementation: weighted round-robin via Nginx upstream or vLLM's built-in router config (5% to `fraud-v4`, 95% to `fraud-v3`)
- W&B parallel run logging: both versions log `model_version`, `decision`, `confidence_score`, and `transaction_id` to the same project for side-by-side comparison
- Automated rollback trigger: W&B alert rule fires if v4 rolling precision (50K transaction window) drops more than 1.5% below v3 — triggers Modal job that reweights load balancer back to 100% v3
- Champion/challenger dashboard template: real-time precision/recall comparison with statistical significance markers

**SA talking point:**
> "No financial institution cutover to a new fraud model cold — the downside risk is
> asymmetric. Canary deployment with automated rollback is the standard. The agent just
> configured the full pipeline: traffic split, side-by-side logging, and a rollback
> condition with a specific threshold. That's production-grade MLOps, not a prototype."

---

## Cron Scheduling Close (30-second closer)

```bash
# In TUI:
/cron add "*/1 * * * *" "Check vLLM fraud model latency p99 — alert ops if above 30ms for 3 consecutive minutes"

/cron add "0 7 * * *" "Generate daily fraud model health report: precision/recall vs prior day, data drift score from Qdrant, top 5 transaction categories by false positive rate, W&B run comparison link"

/cron add "0 0 * * 0" "Run full model evaluation on weekly holdout set using lm-evaluation-harness, compare against last week's checkpoint, post results to W&B model registry"
```

> "The agent is now running autonomous fraud model operations. Latency is checked every
> minute, the daily health report writes itself, and the weekly eval fires automatically.
> The on-call engineer stops monitoring dashboards and starts responding to structured
> alerts with full context already assembled."

---

## Skill Self-Creation Moment (Optional — use if time allows)

After Sequence 3, if the agent has built the RCA plan:

```
# While in TUI, after the root cause analysis:
You: "Save this RCA framework as a reusable skill for our financial services team."

Agent: writes ~/.hermes/skills/mlops/fraud-model-rca/SKILL.md
```

Then demonstrate retrieval on the next engagement:
```
You: "We have a new client — payment processor, precision dropped 3% after a schema change in their feature pipeline. Start from our fraud RCA playbook."
Agent: loads the skill it just created, references it in reasoning, adapts to new context
```

> "That's institutional knowledge capture. The first time you run this RCA it takes
> an hour. The tenth time the agent runs it from a skill in 90 seconds. Every financial
> client engagement compounds the team's expertise instead of resetting it."

---

## GSI Talking Points — Financial Services Vertical

| Claim | Evidence from Demo |
|-------|-------------------|
| Latency diagnosis at transaction scale | vLLM KV cache diagnosis with specific flags — not generic advice |
| Regulatory compliance built in | SR 11-7 audit trail scaffolded: model → data → code commit lineage |
| Hallucination elimination | Outlines constrained decoding — invalid outputs mathematically impossible |
| Root cause analysis in minutes | Three tools (Qdrant + lm-eval + W&B) coordinated into structured RCA plan |
| Safe model deployment | Canary config with automated rollback trigger and statistical comparison |
| Institutional knowledge capture | RCA skill written once, reused across every fraud model engagement |
| Model-agnostic | vLLM, W&B, Qdrant, DSPy, Outlines — no vendor lock, swap any component |
| NVIDIA alignment | vLLM on A100/H100, NIM endpoints for production inference, Triton for multi-model serving |

---

## Pre-Demo Checklist

- [ ] `hermes doctor` — verify environment is clean
- [ ] `hermes --toolsets ml` — confirm ML skills load: `vllm`, `w&b`, `qdrant`, `outlines`, `lm-evaluation-harness`, `dspy`
- [ ] Run Sequence 1 once privately — confirm vLLM latency diagnosis output quality before live demo
- [ ] Run Sequence 4 once privately — confirm Outlines wrapper code generates correctly
- [ ] Have one-shot `hermes chat -q "..."` commands ready in a separate terminal window as fallback for all four sequences
- [ ] Pre-install community skills that may be slow to load: `hermes skills install outlines`, `hermes skills install lm-evaluation-harness`
- [ ] `chmod 600 ~/.hermes/.env` — do not show API keys on screen
- [ ] Confirm W&B API key is set in `~/.hermes/.env` — Sequences 2 and 3 depend on it
- [ ] Have a one-liner ready explaining SR 11-7 if compliance questions arise from the audience

---

*Vertical: Financial Services | Last updated: 2026-02-27 | github.com/QbitLoop/hermes*
