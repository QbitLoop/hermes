#!/usr/bin/env bash
# =============================================================================
# Hermes Agent — Enterprise MLOps Edition
# hermes.qbitloop.com
#
# Usage:
#   curl -fsSL https://hermes.qbitloop.com/install.sh | bash
#
# What this does:
#   1. Installs NousResearch Hermes Agent (Python CLI + TUI)
#   2. Configures enterprise MLOps environment
#   3. Pre-seeds memory with vertical context
#   4. Installs enterprise skill stubs (finance, healthcare, telecom, retail, gov)
# =============================================================================

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
BOLD='\033[1m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     Hermes Agent — Enterprise MLOps Edition          ║${NC}"
echo -e "${BOLD}${BLUE}║     hermes.qbitloop.com  ·  Powered by NousResearch  ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Platform check ────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="macos" ;;
  *)        echo -e "${RED}✗ Unsupported OS: $OS. Use Linux, macOS, or WSL2.${NC}"; exit 1 ;;
esac
echo -e "${CYAN}→ Platform detected: $PLATFORM${NC}"

# ── Step 1: Install Hermes base from NousResearch ────────────────────────────
echo ""
echo -e "${YELLOW}[1/4] Installing Hermes Agent base...${NC}"
echo -e "      Source: github.com/NousResearch/hermes-agent"
echo ""

if ! curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash; then
  echo -e "${RED}✗ Hermes base install failed.${NC}"
  echo -e "  Try manually: https://github.com/NousResearch/hermes-agent"
  exit 1
fi

# Reload PATH so hermes is available immediately
export PATH="$HOME/.local/bin:$PATH"

echo -e "${GREEN}✓ Hermes Agent base installed${NC}"

# ── Step 2: Create enterprise directory structure ─────────────────────────────
echo ""
echo -e "${YELLOW}[2/4] Setting up enterprise environment...${NC}"

HERMES_HOME="$HOME/.hermes"
SKILLS_DIR="$HERMES_HOME/skills/mlops"
SESSIONS_DIR="$HERMES_HOME/sessions"

mkdir -p "$SKILLS_DIR/finance"
mkdir -p "$SKILLS_DIR/healthcare"
mkdir -p "$SKILLS_DIR/telecom"
mkdir -p "$SKILLS_DIR/retail"
mkdir -p "$SKILLS_DIR/public-sector"
mkdir -p "$SESSIONS_DIR"

echo -e "  ${CYAN}✓ Skills directories created${NC}"

# ── Step 3: Pre-seed MEMORY.md with enterprise context ───────────────────────
MEMORY_FILE="$HERMES_HOME/MEMORY.md"

if [ ! -f "$MEMORY_FILE" ]; then
cat > "$MEMORY_FILE" << 'MEMORY_EOF'
# Hermes Agent — Enterprise Memory

## Edition
Enterprise MLOps (QbitLoop)
Installed via: hermes.qbitloop.com
Powered by: NousResearch Hermes Agent

## Loaded Skill Verticals
- Finance: fraud detection, vLLM latency, W&B governance, Outlines constrained output
- Healthcare: clinical RAG, FHIR structured output, CLIP radiology, HIPAA topology
- Telecom: network anomaly detection, 50K tower scale, SAELens interpretability
- Retail: demand forecasting, Black Friday scaling, Qdrant product search
- Public Sector: document intelligence, FedRAMP/ATO, policy knowledge base

## Default Toolset
Launch with: hermes --toolsets ml
Recommended provider: OpenRouter (multi-model, demo-optimized)

## Key Skills Available
vllm, qdrant, chroma, modal, lambda-labs, weights-and-biases,
instructor, outlines, dspy, clip, saelens, lm-evaluation-harness

## Architecture Notes
- Agent runs on CPU — no GPU required for the agent itself
- GPU only needed for local model serving (vLLM/SGLang)
- ReAct loop: up to 60 iterations per task
- Memory budget: ~800 tokens persistent (MEMORY.md), ~500 tokens user (USER.md)
- Skills: unlimited (SKILL.md files, agentskills.io format)

## Sandbox Options (for enterprise/regulated clients)
- Docker: hermes config set TERMINAL_SANDBOX=docker
- SSH:    hermes config set TERMINAL_SANDBOX=ssh
- Modal:  hermes config set TERMINAL_SANDBOX=modal
MEMORY_EOF
  echo -e "  ${CYAN}✓ MEMORY.md seeded with enterprise context${NC}"
else
  echo -e "  ${CYAN}→ MEMORY.md already exists, skipping (preserving existing memory)${NC}"
fi

# ── Step 4: Install enterprise skill stubs ────────────────────────────────────
echo ""
echo -e "${YELLOW}[3/4] Installing enterprise MLOps skill stubs...${NC}"

install_skill_stub() {
  local vertical="$1"
  local skill_name="$2"
  local description="$3"
  local skill_file="$SKILLS_DIR/$vertical/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    cat > "$skill_file" << SKILL_EOF
---
name: $vertical-mlops
description: "$description"
version: "1.0.0"
tags: ["mlops", "$vertical", "enterprise", "qbitloop"]
---

# $skill_name

## Overview
$description

## Quick Start
Ask the agent about any $vertical MLOps challenge. The agent will load
domain-specific knowledge for this vertical automatically.

## Covered Capabilities
$(echo "$3" | sed 's/, /\n- /g' | sed 's/^/- /')

## Reference
Full demo playbook: https://hermes.qbitloop.com
Source: github.com/QbitLoop/hermes
SKILL_EOF
    echo -e "  ${CYAN}✓ $vertical skill stub installed${NC}"
  else
    echo -e "  ${CYAN}→ $vertical skill already present, skipping${NC}"
  fi
}

install_skill_stub "finance"       "Financial Services MLOps"  "Fraud detection, vLLM latency diagnosis, W&B governance, model risk (SR 11-7), constrained output"
install_skill_stub "healthcare"    "Healthcare MLOps"           "Clinical RAG, FHIR structured output, CLIP radiology, HIPAA-compliant topology, drug entity extraction"
install_skill_stub "telecom"       "Telecommunications MLOps"   "Network anomaly detection, 50K tower scale, Modal burst inference, SAELens interpretability, incident RAG"
install_skill_stub "retail"        "Retail & E-Commerce MLOps"  "Black Friday scaling, Lambda Labs burst, Qdrant product search, DSPy recommendation pipeline"
install_skill_stub "public-sector" "Public Sector MLOps"        "Document intelligence, FedRAMP/ATO compliance, policy knowledge base, air-gapped deployment"

# ── Step 5: Final verification ────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[4/4] Verifying installation...${NC}"

if command -v hermes &> /dev/null; then
  HERMES_VERSION=$(hermes --version 2>/dev/null || echo "unknown")
  echo -e "  ${GREEN}✓ hermes found: $HERMES_VERSION${NC}"
else
  echo -e "  ${YELLOW}→ hermes not yet in PATH — run: source ~/.zshrc  (or ~/.bashrc)${NC}"
  echo -e "    Then verify with: hermes doctor${NC}"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║  Hermes Agent — Enterprise MLOps Edition is ready.  ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Launch:${NC}          hermes --toolsets ml"
echo -e "  ${BOLD}Verify:${NC}          hermes doctor"
echo -e "  ${BOLD}Demo query:${NC}      hermes chat -q 'List all MLOps skills and capabilities'"
echo -e "  ${BOLD}Switch model:${NC}    hermes model"
echo -e "  ${BOLD}Docs:${NC}            https://hermes.qbitloop.com"
echo ""
echo -e "  Verticals ready: Finance · Healthcare · Telecom · Retail · Public Sector"
echo ""
