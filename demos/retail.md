# Retail Demo — Recommendation Engine & Demand Forecasting

> **Vertical demo for NVIDIA GSI conversations**
> Target audience: GSI SAs advising Walmart, Amazon, Target
> Use case focus: Black Friday scaling, product search quality, A/B evaluation, DSPy pipeline design

---

## The Story (60-Second Verbal Setup)

> "The conversation I have most often with retail and e-commerce clients is a version
> of the same crisis: everything works fine for 11 months of the year, and then Black
> Friday arrives. Traffic spikes 10x overnight, the recommendation model falls over,
> and the team is scrambling on the highest-revenue day of the year.
>
> But the capacity problem is only half the story. The other half is that their product
> search is surfacing irrelevant results for long-tail queries — size 14 women's hiking
> boots in green — and they're losing those conversions permanently. Customers don't
> try again; they go to a competitor.
>
> The client I'll describe has both problems simultaneously. A recommendation model
> approaching GPU ceiling three weeks before Black Friday, and a Qdrant collection with
> a chunking strategy that doesn't preserve product attribute relationships.
>
> Let's see what Hermes does with that."

---

## Demo Sequence 1 — Black Friday Scaling Plan (Open with this)

**Launch:**
```bash
hermes --toolsets ml
```

**Paste this query at the `⚕ ❯` prompt:**
```
Our recommendation model is currently running at 87% GPU utilization under normal
traffic. Black Friday is 3 weeks out and we expect 10x normal load. The current
setup is vLLM on a single A100 node. We cannot afford downtime or latency
degradation during the sale window. Design the scaling plan.
```

**What the agent does:**
- Loads `lambda-labs` + `modal` + `wandb` skills automatically
- Calculates baseline utilization headroom: 87% at 1x means the current node saturates at approximately 1.15x traffic — well short of the 10x target
- Designs a tiered burst strategy:
  - Primary: Lambda Labs reserved GPU cluster for predictable base load (cost-optimized, persistent)
  - Overflow: Modal serverless for burst above the Lambda Labs ceiling (pay-per-call, auto-scales to zero post-event)
- Generates cost projection table: Lambda Labs reserved A10G cluster (3-week pre-lease) vs. on-demand H100 burst via Modal
- Configures vLLM replica count, tensor parallelism settings, and request batching parameters for the Lambda Labs nodes
- Sets up W&B alerts: latency P95 > 120ms triggers auto-scale signal to Modal overflow pool
- Writes the entire runbook as a reusable skill: `~/.hermes/skills/mlops/retail-black-friday-scaling/SKILL.md`

**SA talking point while agent works:**
> "It loaded Lambda Labs and Modal skills because it recognized the capacity-plus-cost
> constraint. Lambda Labs for predictable base load — you pre-lease the cluster and get
> a lower rate. Modal for true burst — you pay only for what fires during the peak hours.
> That combination is the right answer for a 3-week runway before a known traffic event.
>
> The runbook it just wrote becomes a skill. Next year's Black Friday prep for this client,
> or for any other retail client, starts from that playbook instead of a blank page."

---

## Demo Sequence 2 — Product Search Quality (Qdrant)

**One-shot from terminal:**
```bash
hermes chat -q "Our product embedding search returns irrelevant results for long-tail queries — things like 'size 14 women's hiking boots green' or 'organic cotton king duvet cover grey stripe'. The Qdrant collection was built with naive text chunking. Rebuild the collection with a chunking strategy that preserves product attribute relationships and improves long-tail query precision."
```

**What the agent produces:**
- Qdrant collection schema redesign with product-attribute-aware chunking:
  - Structured metadata fields as filterable payload: `color`, `size`, `brand`, `category`, `material`, `gender`, `subcategory`
  - Each product document chunked at the attribute level — title + description as the dense vector content, all attributes as metadata filters (not embedded into the vector)
  - Prevents attribute dilution: "green" and "size 14" remain as hard filters, not competing for semantic weight in the vector
- Hybrid search configuration:
  - Dense embeddings (e.g., `text-embedding-3-small` or `nomic-embed-text`) for semantic intent matching
  - Sparse BM25 vectors for exact keyword recall on model numbers, SKUs, and brand names
  - Named vector setup in Qdrant for multi-vector retrieval in a single collection
- Re-indexing strategy without downtime:
  - Build the new collection in parallel under a temporary alias
  - Run both collections in shadow mode for 48 hours, compare query result overlap
  - Atomic alias swap when confidence threshold is met — zero customer-facing downtime
- Example query improvement before/after:
  - Before: "size 14 women's hiking boots green" → returns semantically similar hiking content including men's sizes and wrong colors
  - After: dense retrieval for "hiking boots women's" + hard filter `size=14`, `color=green`, `gender=women` → precise long-tail results

**SA talking point:**
> "The naive chunking mistake is extremely common. Teams embed the full product description
> including all attributes into a single vector, then wonder why size and color queries
> return wrong results. The vector can't distinguish between 'green as the dominant semantic
> concept' and 'green as a filter.'
>
> The fix is architectural: attributes are metadata, not content. Qdrant's payload filtering
> is designed exactly for this. The hybrid search layer handles the cases where the customer
> uses natural language — 'something cozy for winter' — and the metadata filters handle
> the cases where they have specific requirements. You need both."

---

## Demo Sequence 3 — A/B Test Evaluation Framework

```bash
hermes chat -q "Our personalization model A/B test is showing 2% lift in click-through rate but the confidence interval is wide — it spans from -0.5% to +4.5%. The team wants to ship but the statistics don't support it. Set up a proper evaluation framework using lm-evaluation-harness adapted for our custom recommendation metrics: precision@k and NDCG. Include W&B experiment tracking so we can compare model versions systematically."
```

**What the agent produces:**
- lm-evaluation-harness custom task definition for recommendation evaluation:
  - `precision_at_k` task: measures fraction of top-k recommendations that appear in the user's actual purchase or click set
  - `ndcg_at_k` task: normalized discounted cumulative gain, weighted by position — rewards surfacing the best items highest
  - YAML task config that plugs into the harness without modifying core library code
- Statistical significance guidance:
  - Minimum detectable effect size calculation given current traffic volume
  - Required sample size to achieve 80% power at 95% confidence for a 2% lift claim
  - Recommendation: extend the test window or increase traffic allocation to the treatment group before shipping
  - Bayesian alternative framing: probability that treatment beats control given current posterior — often more useful than p-values for business decisions
- W&B experiment tracking integration:
  - `wandb.log` hooks for precision@k and NDCG at the end of each evaluation batch
  - Run comparison table: baseline vs. candidate model side-by-side across all metric cuts (by user segment, by product category, by session length)
  - Automated alert if a new candidate drops below baseline NDCG by more than 0.5% in any major segment

**SA talking point:**
> "The wide confidence interval is telling the team something important: they don't have
> enough data to make the claim they want to make. That's not a statistics problem —
> it's a decision problem. Do you ship and risk that the true effect is negative, or
> do you wait and collect more signal?
>
> What lm-evaluation-harness gives you here is repeatability. Every model candidate runs
> through the same evaluation harness with the same metrics. W&B keeps the history.
> Six months from now, when someone asks why version 3.4 was better than 3.2, you have
> the answer in the run log — not in someone's memory."

---

## Demo Sequence 4 — DSPy Recommendation Pipeline (Close with this)

```bash
hermes chat -q "Design a DSPy pipeline that takes a user's browsing history as input, generates enriched product descriptions for candidate items, ranks candidates by predicted engagement score, and outputs structured JSON for our frontend API. Each step should be independently optimizable so we can tune the ranking module without retraining the description generator."
```

**What the agent produces:**
- DSPy multi-step pipeline design with four independently swappable modules:
  1. `BrowsingHistoryEncoder` — `dspy.Predict` that summarizes browsing history into a preference embedding / intent statement
  2. `ProductDescriptionGenerator` — `dspy.ChainOfThought` that takes candidate product attributes and generates an engagement-optimized description tailored to the inferred user intent
  3. `EngagementRanker` — `dspy.Predict` with a custom metric that scores each candidate by predicted click probability given the intent statement and generated description
  4. `StructuredOutputFormatter` — `dspy.TypedPredictor` with Pydantic schema enforcement for the frontend API contract
- Optimization strategy per module:
  - `EngagementRanker` can be fine-tuned on click data using `dspy.BootstrapFewShot` or `dspy.MIPROv2` without touching the description generator
  - `ProductDescriptionGenerator` can be swapped between model backends (GPT-4o, Hermes-3, Llama 3.1) without changing the ranker
- Output JSON schema for the frontend API contract:
```json
{
  "user_id": "string",
  "session_id": "string",
  "recommendations": [
    {
      "product_id": "string",
      "sku": "string",
      "generated_description": "string",
      "engagement_score": 0.0,
      "rank": 1,
      "attributes": {
        "category": "string",
        "brand": "string",
        "price_usd": 0.0,
        "in_stock": true
      }
    }
  ],
  "pipeline_version": "string",
  "latency_ms": 0
}
```
- Module swap example: shows how replacing `EngagementRanker` with a fine-tuned version requires changing one line in the pipeline definition, not a full redeploy

**SA talking point:**
> "The reason DSPy matters here is composability. Traditional prompt engineering locks
> you into a monolithic system — if you want to improve the ranker, you have to re-evaluate
> everything downstream. DSPy makes each module a unit that can be optimized on its own
> objective.
>
> For a retail client, that means the merchandising team can tune the description generator
> for seasonal language without touching the ranking model. The data science team can
> retrain the ranker on fresh click data without waiting for a full pipeline redeploy.
> That independence is what lets you move fast in production without breaking things."

---

## Skill Self-Creation Moment (Optional — use if time allows)

After Sequence 1, if the agent writes the Black Friday runbook as a SKILL.md, highlight it:

```
# While in TUI, after the scaling plan is generated:
You: "Save what you just built as a reusable skill for our retail team."

Agent: writes ~/.hermes/skills/mlops/retail-black-friday-scaling/SKILL.md
```

Then demonstrate retrieval with a new client scenario:

```
You: "We're onboarding a fashion retailer ahead of their holiday sale. Expected 8x normal
     traffic. Start from our Black Friday scaling playbook."

Agent: loads the skill it just created, references Lambda Labs + Modal strategy,
       adapts cost projections to the new client's baseline GPU utilization
```

> "One engineer's Black Friday war story becomes the whole team's starting point.
> The second engagement with any retail client on a capacity problem takes minutes,
> not weeks."

---

## Outlines Sequence — Product Category Taxonomy Constraints (Optional)

Use this if the audience asks about controlling agent output structure or enforcing business rules on generated content.

**Query:**
```bash
hermes chat -q "Our recommendation engine generates product category tags but sometimes outputs categories that don't exist in our taxonomy. Constrain the DSPy pipeline's category output to only valid values from our taxonomy JSON file. The taxonomy has 847 leaf categories."
```

**What the agent produces:**
- `dspy.TypedPredictor` with a `Literal` type annotation dynamically built from the taxonomy JSON at pipeline initialization time
- Fallback strategy: if the model's top-1 category is invalid, run a Qdrant nearest-neighbor lookup against the taxonomy embedding index to find the closest valid category
- Validation layer: post-output Pydantic model that rejects any response not in the taxonomy before it reaches the API
- Demonstrates constrained generation without fine-tuning — pure prompt + output validation

**SA talking point:**
> "Taxonomy enforcement is a recurring problem in any domain with a controlled vocabulary.
> Healthcare has ICD codes. Finance has instrument classifications. Retail has category trees.
> The DSPy TypedPredictor plus a Qdrant fallback is a clean solution that doesn't require
> retraining the model every time the taxonomy changes — you update the JSON, rebuild the
> type annotation, done."

---

## GSI Talking Points — Retail & E-Commerce Vertical

| Claim | Evidence from Demo |
|-------|-------------------|
| Cost optimization at scale | Lambda Labs reserved + Modal serverless burst — right-sized spend for predictable + spike load; not paying for peak capacity year-round |
| Time-to-Value | Black Friday scaling architecture in under 3 minutes; runbook written and reusable before the client meeting ends |
| Skill reuse across retail clients | Black Friday scaling skill built for Client A, reused for Client B with one adaptation command — accelerates every subsequent retail engagement |
| Search quality without model retraining | Qdrant attribute-aware chunking + hybrid search fixes long-tail precision without a new embedding model |
| Evaluation rigor | lm-evaluation-harness + W&B gives repeatable, auditable model comparisons — replaces ad-hoc A/B guesswork |
| Pipeline composability | DSPy independent module optimization means faster iteration cycles — merchandising and data science teams work in parallel |
| Model-agnostic | Swap inference backend (vLLM → Triton → TensorRT-LLM) and LLM provider without changing the agent or the skill definitions |
| Compliance-ready | SSH sandbox keeps execution on client infrastructure; no product catalog or user data leaves the client environment |

---

## Pre-Demo Checklist

- [ ] `hermes doctor` — verify environment is clean
- [ ] `hermes --toolsets ml` — confirm ML skills load (vllm, modal, lambda-labs, qdrant, wandb, dspy, lm-evaluation-harness)
- [ ] Run Sequence 1 once privately — confirm GPU utilization math and cost projection output quality before live demo
- [ ] Have one-shot `hermes chat -q "..."` commands ready in a separate terminal window as fallback if TUI feels slow
- [ ] Pre-load Lambda Labs and Modal skills if they are slow to initialize: `hermes skills install lambda-labs modal`
- [ ] Prepare a sample product taxonomy JSON (even a 20-entry stub) for the Optional Outlines Sequence
- [ ] `chmod 600 ~/.hermes/.env` — do not expose API keys on screen during demo
- [ ] Confirm W&B project is initialized: `wandb init` in the demo directory

---

*Vertical: Retail & E-Commerce | Last updated: 2026-02-27 | github.com/QbitLoop/hermes*
