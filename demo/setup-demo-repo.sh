#!/usr/bin/env bash
set -euo pipefail

# Setup script for VBI Demo
# Creates a clean GitHub repo for the bootstrap demo

REPO_NAME="${1:-mcp-api-wrapper-demo}"
REPO_OWNER="${2:-}"

echo "=== VBI Demo Repo Setup ==="
echo ""

# Determine repo owner
if [[ -z "$REPO_OWNER" ]]; then
    REPO_OWNER=$(gh api user --jq '.login' 2>/dev/null) || {
        echo "Error: Could not determine GitHub username."
        echo "Usage: ./setup-demo-repo.sh [repo-name] [owner]"
        echo "  e.g. ./setup-demo-repo.sh mcp-api-wrapper-demo paulmona"
        exit 1
    }
fi

FULL_REPO="${REPO_OWNER}/${REPO_NAME}"
echo "Target repo: ${FULL_REPO}"
echo ""

# Check if repo already exists
if gh repo view "$FULL_REPO" &>/dev/null; then
    echo "Repo ${FULL_REPO} already exists."
    read -p "Delete and recreate it? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deleting ${FULL_REPO}..."
        gh repo delete "$FULL_REPO" --yes
        sleep 2
    else
        echo "Aborting. Use reset-demo.sh to clean existing repo instead."
        exit 0
    fi
fi

# Create the repo
echo "Creating ${FULL_REPO}..."
gh repo create "$FULL_REPO" \
    --public \
    --description "Demo: MCP server wrapping internal APIs (VBI workflow demo)" \
    --clone=false

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Repo created: https://github.com/${FULL_REPO}"
echo ""
echo "Next steps:"
echo "  1. Copy demo/sample-prd.md into your Notion PRDs database"
echo "  2. Set Status = Approved, GitHub Ready = false"
echo "  3. Run the demo:"
echo "     /vbi-prd-ready PRD-DEMO-001"
echo "     /vbi-bootstrap PRD-DEMO-001 ${FULL_REPO}"
