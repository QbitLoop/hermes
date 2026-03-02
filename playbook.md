# Hermes Agent — Enterprise MLOps Demo Playbook

> **Purpose**: Stand up NousResearch's Hermes Agent as a persistent MLOps operations assistant for enterprise AI demonstrations. Built for GSI teams (Accenture, Deloitte, Capgemini, Wipro, TCS, Infosys) who advise Fortune 500 clients on ML platform strategy with NVIDIA infrastructure.
>
> **Audience**: Solutions Architects, DevRel Engineers, AI/ML Platform Teams
>
> **What You'll Build**: A terminal-based AI agent with 40+ tools and curated MLOps skills that can answer operational questions, generate configs, orchestrate deployments, and accumulate institutional knowledge — across finance, healthcare, telecom, retail, and public sector verticals.

---

## Part 1 — Environment Setup

### 1.1 Prerequisites

| Requirement | Minimum                  | Recommended                           |
|-------------|--------------------------|---------------------------------------|
| OS          | macOS / Linux / WSL2     | Ubuntu 22.04+ or macOS 14+            |
| RAM         | 4 GB                     | 16 GB                                 |
| Storage     | 2 GB free                | 10 GB (for skills + session logs)     |
| GPU         | Not required for agent   | Required only for local model serving |
| Network     | Outbound HTTPS           | Same                                  |
| Python      | Auto-installed by script | 3.11+                                 |

> **Key insight**: The agent itself is a lightweight Python CLI that calls LLM APIs over HTTP. No GPU needed to run the agent. GPU only matters when you ask it to actually train models or serve inference endpoints.

### 1.2 One-Liner Install

**Linux / macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

**Windows (PowerShell — WSL2 strongly recommended instead):**

```powershell
irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | iex
```

**What this does automatically:**

- Installs `uv` (fast Python package manager)
- Pulls Python 3.11 (user-local, no sudo)
- Clones repo + submodules to `~/.hermes/hermes-agent`
- Creates virtual environment + installs all dependencies
- Creates `~/.local/bin/hermes` symlink
- Launches interactive setup wizard

### 1.3 Post-Install Configuration

```bash
# Reload your shell
source ~/.bashrc   # or source ~/.zshrc

# Run the setup wizard
hermes setup
```

**Choose your LLM provider:**

| Provider            | Best For                            | Cost Model    |
|---------------------|-------------------------------------|---------------|
| **OpenRouter**      | Multi-model flexibility, demos      | Pay-per-token |
| **Nous Portal**     | Heavy daily use, Hermes-3 optimized | Subscription  |
| **Custom endpoint** | Self-hosted vLLM/SGLang, air-gapped | Your infra    |

For demos, **OpenRouter** is recommended — you get access to 200+ models and can switch on the fly:

```bash
hermes model   # change model anytime, no code changes
```

### 1.4 Verify Installation

```bash
hermes doctor   # checks environment, API keys, tools
hermes tools    # lists all available toolsets
```

### 1.5 Launch with ML Skills

```bash
# Launch the TUI with ML toolset loaded
hermes --toolsets ml

# Or for a quick one-shot test
hermes chat -q "List all available ML skills and their capabilities"
```

You should see the TUI with the `⚕ ❯` prompt and the ML skill categories: **ML Infrastructure**, **ML Tools & Utilities**, and **Research**.

---

## Part 2 — Understanding the Architecture

### 2.1 How Hermes Agent Works

```
┌──────────────────────────────────────────────────────────┐
│                    HERMES AGENT TUI                       │
│              (Terminal User Interface)                     │
│                                                          │
│  You type natural language ──► Agent reasons ──► Tools    │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │   MEMORY    │  │    SKILLS    │  │     TOOLS       │ │
│  │             │  │              │  │                 │ │
│  │ MEMORY.md   │  │ SKILL.md     │  │ web_search      │ │
│  │ (~800 tok)  │  │ files per    │  │ terminal        │ │
│  │             │  │ capability   │  │ read/write_file │ │
│  │ USER.md     │  │              │  │ vision_analyze  │ │
│  │ (~500 tok)  │  │ 40+ bundled  │  │ browser_*       │ │
│  │             │  │ Community    │  │ mixture_of_     │ │
│  │ Persists    │  │ hub install  │  │   agents        │ │
│  │ across      │  │              │  │ cron/schedule   │ │
│  │ sessions    │  │ Agent can    │  │ subagent spawn  │ │
│  │             │  │ self-create  │  │ ...40+ more     │ │
│  └─────────────┘  └──────────────┘  └─────────────────┘ │
│                                                          │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              SANDBOX BACKENDS                        │ │
│  │  Local │ Docker │ SSH │ Singularity │ Modal          │ │
│  └──────────────────────────────────────────────────────┘ │
│                           │                               │
│                           ▼                               │
│              LLM API (OpenRouter / Nous / Custom)         │
└──────────────────────────────────────────────────────────┘
```

### 2.2 The ReAct Loop

Every query follows the Observation → Reasoning → Action cycle:

1. **Observation**: Agent reads terminal output, file contents, tool results
2. **Reasoning**: Analyzes current state against the goal
3. **Action**: Executes a tool call (terminal command, file write, web search, etc.)
4. **Repeat**: Until task is complete or max iterations reached

The agent is configured for up to 60 iterations per task (`HERMES_MAX_ITERATIONS=60`).

### 2.3 Multi-Level Memory

| Layer             | File                    | Budget              | Purpose                                        |
|-------------------|-------------------------|---------------------|------------------------------------------------|
| **Session**       | In-context              | Conversation window | Current task context                           |
| **Persistent**    | `~/.hermes/MEMORY.md`   | ~800 tokens         | Environment facts, conventions, things learned |
| **User Profile**  | `~/.hermes/USER.md`     | ~500 tokens         | Preferences, communication style              |
| **Procedural**    | `~/.hermes/skills/*.md` | Unlimited           | Reusable workflow knowledge (SKILL.md files)   |
| **Session Archive**| `~/.hermes/sessions/`  | Unlimited           | Full conversation logs for debugging           |

The agent manages its own memory via the `memory` tool — add, replace, remove, read. When the budget is full, it consolidates or replaces entries.

### 2.4 Skills System

Skills follow the **agentskills.io** open format — portable `SKILL.md` files compatible with Claude Code, VS Code, Cursor, Goose, and Amp.

```
~/.hermes/skills/
├── mlops/
│   ├── axolotl/
│   │   ├── SKILL.md            # Main instructions (required)
│   │   ├── references/         # Additional docs
│   │   └── templates/          # Output formats
│   └── vllm/
│       └── SKILL.md
├── devops/
│   └── deploy-k8s/             # Agent-created skill
│       ├── SKILL.md
│       └── references/
├── .hub/
│   ├── lock.json               # Installed skill provenance
│   ├── quarantine/             # Pending security review
│   └── audit.log               # Security scan history
└── .bundled_manifest
```

**Key commands:**

```bash
hermes skills search <topic>     # Find community skills
hermes skills install <skill>    # Add a skill
hermes --toolsets skills -q "What skills do you have?"
```

The agent can also **self-create skills** via the `skill_manage` tool: when it solves a complex workflow, it writes a SKILL.md for future reuse.

---

## Part 3 — Enterprise MLOps Skill Categories

These are the bundled ML skills visible in the TUI, mapped to enterprise use cases.

### 3.1 ML Infrastructure Skills

| Skill             | What It Knows                             | Enterprise Use Case                                         |
|-------------------|-------------------------------------------|-------------------------------------------------------------|
| **lambda-labs**   | Reserved/on-demand GPU cloud instances    | Capacity planning, burst compute for training jobs          |
| **modal**         | Serverless GPU platform                   | Ephemeral inference endpoints, batch processing             |
| **weights-and-biases** | Experiment tracking with automatic logging | Model governance, audit trails, hyperparameter optimization |

### 3.2 ML Tools & Utilities Skills

| Skill          | What It Knows                              | Enterprise Use Case                                                      |
|----------------|--------------------------------------------|--------------------------------------------------------------------------|
| **chroma**     | Embedding database for AI applications     | Knowledge bases, document retrieval, compliance search                   |
| **clip**       | Vision-language models (OpenAI)            | Multimodal search, image classification, fraud detection on visual data  |
| **dspy**       | Declarative programming for AI systems     | Prompt optimization, reproducible AI pipelines                           |
| **instructor** | Extract structured data from LLM responses | Schema-validated outputs, reliable API responses                         |
| **outlines**   | Guarantee valid JSON/XML/code generation   | Constrained decoding, compliance-safe outputs                            |
| **qdrant**     | Vector similarity search for RAG           | Retrieval-augmented generation, semantic search at scale                 |
| **vllm**       | High-throughput LLM serving                | Production inference, continuous batching, p99 latency control           |

### 3.3 Research Skills

| Skill                     | What It Knows                            | Enterprise Use Case                                            |
|---------------------------|------------------------------------------|----------------------------------------------------------------|
| **lm-evaluation-harness** | Evaluate LLMs across 60+ benchmarks      | Model selection, governance reviews, pre-deployment validation |
| **ml-paper-writing**      | Write publication-ready ML papers        | Internal tech reports, methodology documentation               |
| **saelens**               | Sparse Autoencoder training and analysis | Feature interpretability, model explainability for regulators  |

---

## Part 4 — Industry Vertical Demo Scenarios

### 4.1 Financial Services (Visa, Mastercard, JPMorgan, Goldman Sachs)

**Scenario: Real-Time Fraud Detection MLOps**

```
You: "We're running a fraud detection model on vLLM that scores 50K transactions
per second. Latency spiked 3x during yesterday's batch window. Walk me through
the diagnosis."

Agent will:
→ Load vLLM skill for serving architecture knowledge
→ Explain KV cache pressure, PagedAttention tuning, continuous batching config
→ Generate a diagnostic checklist with specific vLLM flags to check
→ Suggest W&B integration for latency monitoring dashboards
→ Write the diagnosis as a skill for next time
```

**Sample queries for this vertical:**

```
"Set up a W&B project for fraud model v3 with artifact versioning so compliance
can trace every model back to its training data and the exact code commit."

"Our precision dropped 2% this week. Build a root cause analysis plan: check data
drift with embedding comparisons in Qdrant, pull latest eval scores from
lm-evaluation-harness, and compare against last month's checkpoint."

"The fraud reason-code generator is hallucinating invalid codes. Show me how to
wrap it with Outlines to constrain output to our valid JSON schema."

"Convert our hand-written fraud classification prompt to a DSPy module with
chain-of-thought. Optimize against our labeled dataset and compare accuracy."

"We need a canary deployment: 5% traffic to new model, 95% to production.
Generate the vLLM load balancer config and monitoring alerts."

"Prepare the quarterly model review: for each production model, outline what
eval scores, training lineage from W&B, and serving metrics I need to compile."
```

### 4.2 Healthcare & Life Sciences (UnitedHealth, Pfizer, Mayo Clinic)

**Scenario: Clinical NLP Pipeline Operations**

```
You: "We're building a RAG system over 2M clinical trial documents for our
research team. They need to query regulatory requirements and drug interaction
data in natural language. Design the architecture."

Agent will:
→ Load Qdrant + Chroma skills for vector store comparison
→ Recommend chunking strategy for medical documents (overlap, metadata)
→ Suggest Instructor for structured extraction of drug entities
→ Outline HIPAA-compliant deployment topology
→ Generate skeleton configs for the full pipeline
```

**Sample queries:**

```
"Compare Qdrant vs Chroma for a 2M document medical knowledge base. Consider
query latency, metadata filtering (by drug, trial phase, date), and
horizontal scaling."

"Our clinical note summarizer needs to output structured FHIR-compatible JSON.
Show me how Instructor + Pydantic models can guarantee valid output every time."

"Set up lm-evaluation-harness to benchmark three candidate models on our custom
medical QA dataset. I need accuracy, hallucination rate, and latency."

"The radiology report classifier needs to handle X-ray images alongside text.
Design a CLIP-based multimodal pipeline that combines image features with
clinical metadata."

"Build a DSPy pipeline: raw clinical note → entity extraction → risk scoring →
human-readable summary. Each step should be independently swappable."
```

### 4.3 Telecommunications (AT&T, Verizon, T-Mobile, Motorola Solutions)

**Scenario: Network Anomaly Detection & Predictive Maintenance**

```
You: "We have a model that predicts cell tower failures 48 hours in advance based
on telemetry data. It's currently running on a single GPU. We need to scale it
to cover 50K towers with 5-minute inference cycles. Plan the deployment."

Agent will:
→ Load vLLM + Modal skills for serving architecture
→ Calculate throughput requirements (50K towers / 5 min = ~167 inferences/sec)
→ Recommend batch inference strategy with Modal serverless
→ Design monitoring with W&B for model drift on telemetry features
→ Generate capacity planning spreadsheet
```

**Sample queries:**

```
"Our network anomaly model drifts when seasonal traffic patterns change. Set up
an automated retraining pipeline triggered by drift detection in the embedding
space using Qdrant similarity thresholds."

"We need to serve a mixture-of-experts model for real-time call quality prediction.
Compare vLLM continuous batching vs dedicated GPU instances on Lambda Labs for
this workload profile."

"Generate a sparse autoencoder analysis (SAELens) of our network fault predictor
to identify which telemetry features drive failure predictions. The NOC team
needs interpretable explanations."

"Build a RAG system over 5 years of incident reports so field engineers can query
past failure patterns by equipment type, geography, and weather conditions."
```

### 4.4 Retail & E-Commerce (Walmart, Amazon, Target)

**Scenario: Recommendation Engine & Demand Forecasting**

```
You: "Black Friday is in 3 weeks. Our recommendation model needs to handle 10x
normal traffic. Current vLLM setup is at 87% GPU utilization. What's the plan?"

Agent will:
→ Load Lambda Labs + Modal skills for burst compute
→ Calculate required GPU capacity for 10x traffic
→ Design auto-scaling strategy with cost projections
→ Set up W&B alerts for latency degradation
→ Generate runbook as a reusable skill document
```

**Sample queries:**

```
"Our product embedding search returns irrelevant results for long-tail queries.
Rebuild the Qdrant collection with a better chunking strategy that preserves
product attribute relationships."

"The personalization model's A/B test shows 2% lift but the confidence interval
is wide. Set up a proper evaluation framework with lm-evaluation-harness
adapted for our custom recommendation metrics."

"Design a DSPy pipeline that takes user browsing history → generates product
descriptions → ranks by predicted engagement → outputs structured JSON for
the frontend API."

"We need to constrain our product description generator to only output valid
product categories from our taxonomy. Show me the Outlines setup."
```

### 4.5 Public Sector & Defense

**Scenario: Document Intelligence & Compliance Automation**

```
You: "We're processing 100K government forms per day. The current OCR + classifier
pipeline has a 4% error rate that requires manual review. How do we get to <1%?"

Agent will:
→ Load CLIP skill for document image analysis
→ Recommend multimodal pipeline combining OCR with vision-language models
→ Use Instructor for structured form field extraction
→ Design confidence-based routing (auto-approve vs human review)
→ Set up evaluation benchmarks for the new pipeline
```

**Sample queries:**

```
"Build a CLIP-based document classifier that routes incoming forms to the correct
processing pipeline based on visual layout, not just text content."

"Our grant proposal summarizer needs to extract structured data: PI name, budget,
timeline, key objectives. Use Instructor with strict Pydantic validation."

"Set up a Chroma knowledge base over 10 years of policy documents so analysts can
find precedent decisions using semantic search instead of keyword matching."

"The model governance board needs reproducible evaluation results. Configure
lm-evaluation-harness to run automatically on every model update and publish
results to W&B with full data lineage."
```

---

## Part 5 — Running the Demo

### 5.1 Quick Demo Launch

```bash
# Full ML toolset — shows everything from the screenshot
hermes --toolsets ml
```

### 5.2 Useful Slash Commands During Demo

```
/help                    # Show all commands
/tools                   # List loaded tools
/skills                  # Browse skills
/model                   # Switch LLM model on the fly
/clear                   # Clear conversation
/retry                   # Retry last response
/undo                    # Undo last message
/cron                    # Manage scheduled jobs
/quit                    # Exit
```

### 5.3 Impressive Demo Sequences

**Show persistent memory:**

```
# Session 1
You: "I'm working on a fraud detection model using Llama 3.1 8B fine-tuned with
LoRA on our transaction dataset. We serve on 4x A100s via vLLM."

# Session 2 (new session, agent remembers)
You: "What was our model setup again?"
Agent: recalls from MEMORY.md — model, hardware, serving config
```

**Show skill self-creation:**

```
You: "Set up a complete vLLM deployment with health checks, load balancing,
and auto-restart on failure."

# Agent works through it, then:
Agent: "I've saved this as a skill for future use."

# Later:
You: "Deploy vLLM again for the new model."
Agent: loads the skill it created, executes faster
```

**Show cron scheduling:**

```
/cron add "0 9 * * *" "Check all production model endpoints for latency
degradation and report anomalies"

/cron add "0 6 * * 1" "Generate weekly MLOps status report: model versions,
eval scores, infrastructure utilization, incidents"
```

**Show cross-platform (if gateway configured):**

```bash
# In another terminal, start the gateway
hermes gateway

# Now interact via Telegram, Discord, Slack, or WhatsApp
# Start a conversation on Telegram, continue in the TUI
```

### 5.4 One-Shot Demo Queries (Copy-Paste Ready)

These work immediately after `hermes --toolsets ml`:

```bash
# Infrastructure planning
hermes chat -q "I need to serve a 70B parameter model with p99 latency under
100ms at 1000 concurrent requests. Design the infrastructure using vLLM on
Lambda Labs A100 instances. Include cost estimates."

# Experiment tracking setup
hermes chat -q "Set up a W&B experiment tracking project for a recommendation
model. Include hyperparameter sweep config, artifact versioning, and custom
metrics for precision@k and NDCG."

# Evaluation pipeline
hermes chat -q "Create an evaluation plan using lm-evaluation-harness to compare
Llama 3.1 8B, Mistral 7B, and our fine-tuned model on a custom classification
benchmark. Include the config files."

# RAG architecture
hermes chat -q "Design a production RAG pipeline using Qdrant for a legal document
knowledge base with 500K documents. Include chunking strategy, metadata schema,
hybrid search config, and retrieval evaluation methodology."

# Structured output
hermes chat -q "Our API returns free-text JSON that breaks downstream consumers.
Show me how to use Outlines + Instructor together to guarantee schema-valid
responses with typed Pydantic models."
```

---

## Part 6 — Advanced Configuration

### 6.1 Connect Messaging Platforms

```bash
# Configure in ~/.hermes/.env
TELEGRAM_BOT_TOKEN=your_token_from_botfather
TELEGRAM_ALLOWED_USERS=your_user_id

DISCORD_BOT_TOKEN=your_token_from_developer_portal
DISCORD_ALLOWED_USERS=your_user_id

# Launch gateway
hermes gateway install   # systemd service (persistent)
hermes gateway           # or foreground for testing
```

### 6.2 SSH Sandbox (Remote GPU Execution)

```bash
# Agent runs locally, executes on remote GPU box
hermes config set TERMINAL_SANDBOX=ssh
hermes config set SSH_HOST=gpu-server.example.com
hermes config set SSH_USER=mlops
hermes config set SSH_KEY=~/.ssh/id_ed25519
```

### 6.3 Docker Sandbox (Isolated Execution)

```bash
hermes config set TERMINAL_SANDBOX=docker
# Gets: read-only root, dropped capabilities, PID limits, namespace isolation
```

### 6.4 Modal Sandbox (Serverless GPU)

```bash
hermes config set MODAL_TOKEN_ID=your_id
hermes config set MODAL_TOKEN_SECRET=your_secret
# Agent can dispatch GPU workloads to Modal serverless
```

### 6.5 Browser Automation (Browserbase)

```bash
hermes config set BROWSERBASE_API_KEY=your_key
hermes config set BROWSERBASE_PROJECT_ID=your_project
# Enables: browser_navigate, browser_click, browser_type, browser_snapshot, etc.
```

---

## Part 7 — Custom Skills for Your Org

### 7.1 Creating a Custom SKILL.md

```bash
mkdir -p ~/.hermes/skills/mlops/your-custom-skill
```

Create `~/.hermes/skills/mlops/your-custom-skill/SKILL.md`:

```markdown
---
name: your-custom-skill
description: "Brief description of what this skill teaches the agent"
version: "1.0.0"
tags: ["mlops", "deployment", "your-org"]
---

# Your Custom Skill Name

## Overview
What this skill enables the agent to do.

## Prerequisites
- Tools, access, or configuration needed

## Procedures

### Procedure 1: Common Task
Step-by-step instructions the agent follows.

### Procedure 2: Another Task
More instructions.

## Pitfalls
- Known issues and how to avoid them

## References
- Links to documentation
```

### 7.2 Installing Community Skills

```bash
hermes skills search kubernetes
hermes skills search "model deployment"
hermes skills install <skill-name>
```

Skills are quarantined on install until reviewed — new skills don't get full access until you approve them.

### 7.3 Recommended Additional Skills for Enterprise MLOps

Browse and install from agentskills.io, GitHub, ClawHub, LobeHub, or the Claude Code Marketplace:

- **Kubernetes / Helm** — container orchestration for model serving
- **Terraform / Pulumi** — infrastructure as code for GPU clusters
- **MLflow** — model registry and lifecycle management
- **Prometheus / Grafana** — monitoring and alerting
- **Great Expectations** — data quality validation
- **Feature Store (Feast)** — feature engineering and serving
- **Airflow / Prefect** — workflow orchestration
- **NVIDIA Triton** — multi-model inference server

---

## Part 8 — Security & Compliance Notes

### 8.1 What's Safe for Testing

- Agent calls LLM APIs (OpenRouter/Nous) over HTTPS — no data stored on their side beyond API terms
- Skills are local markdown files — no data leaves your machine
- Session logs stored locally in `~/.hermes/sessions/`
- Docker sandbox provides isolation for code execution
- SSH sandbox keeps execution on your controlled infrastructure

### 8.2 What to Be Careful About

- **Gateway mode** exposes the agent to messaging platforms — lock down allowed users
- **Terminal tool** can execute arbitrary commands — use Docker or SSH sandbox in production
- **API keys** stored in `~/.hermes/.env` — `chmod 600` this file
- **Memory files** may accumulate sensitive context — review `MEMORY.md` and `USER.md` periodically
- **Community skills** go through quarantine, but review before approving

### 8.3 For Enterprise / Regulated Environments

- Use a **custom endpoint** (self-hosted vLLM/SGLang) to keep all LLM inference on-premises
- Use **Docker sandbox** with read-only root for all code execution
- Disable **gateway mode** unless messaging platforms are approved
- Audit `~/.hermes/sessions/` logs for compliance
- Consider air-gapped deployment with local models for sensitive data

---

## Part 9 — Troubleshooting

```bash
hermes doctor              # Full environment diagnostic
hermes --version           # Check version
hermes config show         # View current configuration
```

**Common issues:**

| Problem                     | Fix                                                             |
|-----------------------------|----------------------------------------------------------------|
| `hermes: command not found` | `source ~/.bashrc` or add `~/.local/bin` to PATH              |
| API key errors              | `hermes setup` to reconfigure provider                        |
| Skills not loading          | `hermes --toolsets ml` to explicitly load ML toolset          |
| Slow responses              | Try a faster/smaller model via `hermes model`                 |
| Terminal sandbox failures   | Check Docker is running or SSH connectivity                   |
| Memory full                 | Agent auto-consolidates, or manually edit `~/.hermes/MEMORY.md` |

---

## Part 10 — GSI Demo Talking Points

When presenting this to GSI teams advising enterprise clients:

1. **Model-agnostic**: No vendor lock-in. Switch between Nous, OpenAI, Anthropic, Mistral, or self-hosted models with one command. This matters when clients have existing model agreements.
2. **Institutional knowledge capture**: The skill system means the first deployment is manual, the second is semi-automated, and the tenth is a one-command operation. This is how you reduce Time-to-Value for ML platform buildouts.
3. **Cross-platform operations**: Start a conversation about a production incident on Telegram from your phone, continue the investigation in your terminal, hand it off to a colleague on Discord. The agent maintains context across all of them.
4. **Compliance-ready architecture**: Five sandbox backends, session logging, skill quarantine, and support for air-gapped deployments with self-hosted models. This maps directly to regulated industry requirements.
5. **Open source (MIT)**: No licensing risk. Clients can fork, customize, and embed. The agentskills.io format is already adopted by Microsoft, Anthropic, and others — skills are portable across agent frameworks.
6. **Dual-use for training**: The same agent architecture powers Nous Research's own RL training pipeline. It can generate thousands of tool-calling trajectories for fine-tuning custom models — meaning clients can eventually train domain-specific agents on their own data.

---

## Quick Reference Card

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Setup
hermes setup              # Configure LLM provider
hermes doctor             # Verify everything works

# Run
hermes                    # Launch TUI
hermes --toolsets ml      # Launch with ML skills
hermes chat -q "..."      # One-shot query
hermes --continue         # Resume last session

# Skills
hermes skills search ...  # Find skills
hermes skills install ... # Add skills
/skills                   # Browse in TUI

# Gateway (messaging)
hermes gateway            # Start (foreground)
hermes gateway install    # Start (systemd service)

# Scheduling
hermes cron add "0 9 * * *" "Daily MLOps status check"
hermes cron list          # View jobs
hermes cron status        # Check gateway

# Model management
hermes model              # Switch LLM model

# Maintenance
hermes doctor             # Diagnostics
hermes config show        # View config
```

---

*Last updated: February 2026 | Hermes Agent v1.0 | github.com/NousResearch/hermes-agent*
