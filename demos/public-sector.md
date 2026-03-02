# Public Sector & Defense Demo — Document Intelligence & Compliance Automation

> **Target audience:** GSI SAs advising DoD, DHS, HHS, state/local government agencies
> Presenter angle: Speak from direct ATO experience — FedRAMP authorization achieved in 9 months at Motorola Solutions, air-gap deployment at scale

---

## The Story (60-Second Verbal Setup)

> "The conversation I have most often with public sector clients is around document
> processing at volume — forms, grants, policy documents, regulations — and the
> compliance overhead that surrounds anything AI-generated.
>
> The agency I'll describe processes 100,000 government forms per day. Their current
> OCR pipeline has a 4% error rate. That sounds small until you realize 4,000 forms
> per day are going to a manual review queue staffed by contractors at $85 an hour.
>
> But the harder problem isn't the error rate. It's that every model update, every
> change to the pipeline, has to go back through a governance board. Without
> reproducible evaluation results and a full audit trail, they can't get sign-off.
> The model sits in review for months while the paper pile grows.
>
> Let's see what Hermes does with that."

---

## Demo Sequence 1 — OCR Pipeline Error Reduction (Open with this)

**Launch:**
```bash
hermes --toolsets ml
```

**Paste this query at the `⚕ ❯` prompt:**
```
We process 100,000 government forms per day. Our current OCR plus classifier
pipeline has a 4% error rate — that's 4,000 forms per day routed to manual review.
The goal is to get below 1% without adding headcount. How do we get there?
```

**What the agent does:**
- Loads `clip` + `instructor` skills automatically
- Diagnoses error sources: OCR confidence vs classification confidence vs form layout variance
- Recommends a multimodal pipeline: OCR for text extraction, CLIP vision-language model for document image understanding (form type, layout, handwriting detection)
- Uses Instructor with Pydantic for structured form field extraction with strict type validation
- Designs a confidence-based routing system:
  - High confidence (>0.95): auto-approve, no human touch
  - Medium confidence (0.80–0.95): lightweight spot-check queue
  - Low confidence (<0.80): full manual review with extracted fields pre-filled
- Sets up an evaluation benchmark framework to measure error rate improvement by form type and agency
- Projects: combined multimodal pipeline should reduce manual review queue by 70–80%

**SA talking point while agent works:**
> "Notice it loaded the CLIP and Instructor skills without being told to. The agent
> recognized this is a multimodal document problem — text extraction alone won't get
> you to sub-1% on government forms because they have stamps, handwriting, and
> inconsistent layouts. That diagnosis happened in the skill-loading step, before
> the first line of reasoning."
>
> "For a FedRAMP or DoD environment: all of this runs on self-hosted models. CLIP
> and the classifier run on-prem. No form data, no document content, leaves the
> agency boundary. We achieved ATO at Motorola Solutions in 9 months — the
> architecture decisions we're building here are exactly what that process requires."

---

## Demo Sequence 2 — Policy Knowledge Base (Chroma)

**One-shot from terminal (good if TUI feels slow):**
```bash
hermes chat -q "Set up a Chroma knowledge base over 10 years of policy documents so analysts can find precedent decisions using semantic search instead of keyword matching. Documents span multiple agencies, classification levels, and date ranges. Design the chunking strategy, metadata schema, hybrid search config, and access control layer."
```

**What the agent produces:**
- Chroma collection schema with metadata fields: `agency`, `policy_date`, `document_type`, `classification_level`, `section_id`, `superseded_by`, `effective_date`
- Chunking strategy optimized for policy documents:
  - Preserve document hierarchy: title → section → subsection → paragraph
  - Each chunk tagged with its position in the hierarchy (breadcrumb metadata)
  - Overlap strategy: 15% overlap at section boundaries to avoid split-precedent artifacts
  - Minimum chunk size: one complete regulatory paragraph (avoid splitting enumerated clauses)
- Hybrid search configuration:
  - Dense embeddings for semantic similarity on policy intent
  - Sparse BM25 for regulatory citation matching (CFR references, statute numbers)
  - Metadata pre-filters: agency, date range, classification level applied before vector search
- Access control layer:
  - Role-based collection partitioning by classification level
  - Analyst queries routed to their authorized partition only
  - Audit log: every query logged with user ID, timestamp, and returned document IDs
- Example analyst queries the system handles:
  - "Find all precedent decisions where a contractor exceeded budget by more than 15% and the agency approved a contract modification"
  - "What is the most recent policy on remote work reimbursement for GS-12 employees?"

**SA talking point:**
> "Ten years of policy documents in a keyword search system is a liability, not an
> asset. Analysts spend hours reading documents looking for the one paragraph that
> sets precedent. Semantic search turns institutional memory into institutional
> intelligence — the answer surfaces, not just the document.
>
> The access control layer is the part that matters for FedRAMP authorization. Every
> query is logged with full data lineage. The governance board can pull an audit trail
> for any decision that referenced a policy document. That's a requirement, not a
> feature."

---

## Demo Sequence 3 — Reproducible Model Governance

```bash
hermes chat -q "The model governance board needs reproducible evaluation results. Configure lm-evaluation-harness to run automatically on every model update and publish results to W&B with full data lineage — from training data version through eval results to deployment decision. Include the CI/CD pipeline config and a governance report template the board can sign off on."
```

**What the agent produces:**
- lm-evaluation-harness configuration for agency-specific task sets (form classification accuracy, extraction F1, hallucination rate on policy Q&A)
- W&B artifact versioning schema:
  - `training-data-v{n}` artifact → linked to `model-checkpoint-v{n}` → linked to `eval-results-v{n}` → linked to `deployment-decision-v{n}`
  - Full lineage graph: one click from a deployed model to the exact training data and eval scores that justified the deployment
- CI/CD pipeline config (GitHub Actions or GitLab CI):
  - Triggered on every model checkpoint push
  - Runs full eval suite automatically
  - Publishes results to W&B with pass/fail thresholds
  - Blocks deployment if eval scores fall below governance-approved minimums
- Governance report template (Markdown → PDF):
  - Model version, training data provenance, eval task suite, scores vs baselines
  - Delta analysis: what changed from prior version
  - Risk assessment: which error categories increased or decreased
  - Sign-off block: board members, date, approval status
- Suggested governance thresholds for public sector:
  - Form classification accuracy: >= 97%
  - Structured extraction F1: >= 0.94
  - Hallucination rate on policy Q&A: <= 2%

**SA talking point:**
> "Reproducibility is the word that unlocks budget in government. If the governance
> board can't reproduce your eval results six months later, the deployment is at risk
> of being pulled. If the audit shows the model was approved based on an eval run
> that can't be reconstructed, that's a compliance finding.
>
> W&B artifact lineage solves this. Every deployment decision has a provenance chain
> that goes all the way back to the training data. That chain is what the IG needs
> when they ask 'why did the model approve this form?'"

---

## Demo Sequence 4 — Structured Extraction for Grant Processing (Close with this)

```bash
hermes chat -q "Our grant proposal summarizer needs to extract structured data from 200-page PDF submissions: PI name, institution, budget total, budget breakdown by year, project timeline, key objectives, and research keywords. Use Instructor with strict Pydantic validation and show how the pipeline handles edge cases — missing fields, ambiguous budget formats, multi-PI submissions. Include confidence scoring for human review routing."
```

**What the agent produces:**
- Pydantic model for grant schema:

```python
class BudgetYear(BaseModel):
    year: int
    amount: float
    categories: dict[str, float]

class PrincipalInvestigator(BaseModel):
    name: str
    institution: str
    role: Literal["PI", "Co-PI", "Senior Personnel"]

class GrantProposal(BaseModel):
    principal_investigators: list[PrincipalInvestigator]
    budget_total: float
    budget_by_year: list[BudgetYear]
    project_start: date
    project_end: date
    key_objectives: list[str] = Field(min_items=1, max_items=10)
    research_keywords: list[str]
    extraction_confidence: float = Field(ge=0.0, le=1.0)
    review_flags: list[str] = Field(default_factory=list)
```

- Retry-with-feedback loop for extraction failures:
  - First attempt: extract all fields
  - On validation failure: Instructor sends the Pydantic error back to the model with context — "budget_total must be a float, found '$2.4M' — reformat and retry"
  - Maximum 3 retries before flagging for human review with extracted partial data pre-filled
- Edge case handling:
  - Multi-PI submissions: detected by scanning for "Co-PI" or "Senior Personnel" sections, extracted as list
  - Missing fields: `review_flags` populated with specific missing field names, routed to reviewer with pre-filled form
  - Ambiguous budget formats (ranges, "up to X", foreign currencies): flagged with confidence < 0.7, reviewer sees raw text alongside extracted value
- Confidence scoring for routing:
  - Confidence >= 0.92: auto-process, no human review
  - Confidence 0.75–0.92: expedited review queue (pre-filled form, reviewer confirms or corrects)
  - Confidence < 0.75: full manual review, extracted data shown as suggestions only
- Expected throughput improvement: reviewer handles 15 proposals/day manually vs 80/day with AI pre-extraction

**SA talking point:**
> "Grant processing is where structured extraction earns its budget. A program officer
> reviewing 200-page proposals all day isn't extracting insight — they're transcribing
> data. Instructor with Pydantic validation means the extraction either succeeds cleanly
> or tells you exactly why it didn't. There's no silent failure mode.
>
> The retry-with-feedback loop is the key architectural decision. Most extraction
> pipelines fail quietly and ship bad data downstream. This one surfaces the failure
> at the extraction layer, pre-fills the reviewer form with what it could extract,
> and routes to human review with full context. The reviewer is correcting, not
> starting from scratch."

---

## Optional: CLIP-Based Document Routing (Use if time allows)

```bash
hermes chat -q "We receive 15 different form types from 8 different agencies. Routing today is based on header text extraction, which fails when forms are scanned at an angle or have header stamps. Design a CLIP-based visual routing system that classifies forms by layout and visual structure, not text content."
```

**What the agent produces:**
- CLIP embedding pipeline for document images (convert PDF page 1 to image, embed with CLIP)
- Few-shot classification approach: 10–20 example images per form type as reference embeddings
- Cosine similarity routing: incoming form embedded → compared to reference set → routed to highest-similarity form type
- Confidence threshold: below 0.80 similarity → "unknown form type" queue for manual classification + addition to reference set
- Fallback chain: CLIP routing → text-based routing fallback → manual queue
- Expected accuracy: 97%+ routing accuracy vs 89% current text-based routing on degraded scans

---

## Air-Gapped Deployment Note

> For classified or FedRAMP-high environments, use custom endpoint (self-hosted vLLM) + Docker sandbox + SSH execution. No data leaves the perimeter.

```bash
# Point Hermes at a self-hosted vLLM endpoint inside the agency boundary
hermes model --provider custom --base-url https://llm.agency.internal/v1 --model llama-3-70b

# All tool execution runs in Docker sandbox on agency infrastructure
hermes --sandbox docker --sandbox-image agency-approved-container:latest

# SSH execution for remote compute nodes
hermes --sandbox ssh --host compute-node-01.agency.internal
```

> "The FedRAMP authorization question always comes up. The answer is: Hermes is a local
> agent. The model runs where you point it. For IL4 or IL5 workloads, you run Llama 3
> on agency hardware, the Docker sandbox executes on agency infrastructure, and the SSH
> backend runs on your compute nodes. There is no Hermes cloud service. The only data
> that leaves is what you choose to send to W&B — and for classified work, you run W&B
> on-prem as well.
>
> We got FedRAMP ATO in 9 months at Motorola Solutions. The architecture decisions that
> made that possible — air-gap support, local execution, full audit logging — are the
> same decisions baked into this agent."

---

## Skill Self-Creation Moment (Optional — use if time allows)

After Sequence 1 or 2, if the agent writes a SKILL.md, highlight it:

```
# While in TUI, after the OCR pipeline recommendation:
You: "Save the multimodal OCR pipeline design as a reusable skill for our federal clients."

Agent: writes ~/.hermes/skills/document-intelligence/gov-ocr-pipeline/SKILL.md
```

Then demonstrate retrieval:
```
You: "We're starting an engagement with a state DMV processing 50K license applications per day.
Start from our government OCR pipeline playbook."

Agent: loads the skill it just created, adapts recommendations for DMV-specific form types
```

---

## GSI Talking Points — Public Sector & Defense Vertical

| Claim | Evidence from Demo |
|-------|-------------------|
| FedRAMP / ATO alignment | Air-gap deployment, no external API calls required, Docker + SSH sandbox backends |
| Full audit trail | W&B data lineage: training data → eval results → deployment decision, one-click provenance |
| Compliance by design | Every query logged, access control layer on Chroma, governance report template with sign-off block |
| Reproducible governance | lm-evaluation-harness CI/CD: same eval results every run, blocked deployment on threshold failure |
| Reduces manual review burden | Confidence-based routing cuts 70–80% of manual review queue; grant pre-extraction 5x reviewer throughput |
| No silent failure modes | Instructor retry-with-feedback: extraction fails loudly with structured context, not silently with bad data |
| Multi-classification support | CLIP visual routing handles degraded scans, stamps, rotation — not dependent on text extraction |
| Open source (MIT) | No licensing risk for government procurement; portable, auditable, no proprietary lock-in |

---

## Pre-Demo Checklist

- [ ] `hermes doctor` — verify environment is clean
- [ ] `hermes --toolsets ml` — confirm ML skills load (clip, instructor, chroma, lm-evaluation-harness, w&b)
- [ ] Run Sequence 1 once privately — confirm agent output quality before live demo
- [ ] Have one-shot `hermes chat -q "..."` commands ready in a separate terminal window as fallback
- [ ] Pre-install `clip`, `instructor`, `chroma` community skills — slow to load if not cached
- [ ] `chmod 600 ~/.hermes/.env` — don't show API keys on screen
- [ ] If demoing air-gap mode: pre-configure `hermes model --provider custom` to a local endpoint so the switch is one command, not a configuration exercise
- [ ] Have the Pydantic grant schema in a separate file ready to display — the code block is the strongest visual moment in Sequence 4

---

*Vertical: Public Sector & Defense | Last updated: 2026-02-27 | github.com/QbitLoop/hermes*
