#!/usr/bin/env bash
set -euo pipefail

# Publish demo framework to paulmona/workflow-demo
#
# Run from the paulmona/claude repo root:
#   ./demo/publish-to-demo-repo.sh
#
# This script:
#   1. Clones workflow-demo into a temp directory
#   2. Copies the demo framework files
#   3. Commits and pushes

DEMO_REPO="${1:-paulmona/workflow-demo}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMPDIR=$(mktemp -d)

echo "=== Publish Demo Framework ==="
echo "Source:      ${SOURCE_ROOT}"
echo "Target repo: ${DEMO_REPO}"
echo "Temp dir:    ${TMPDIR}"
echo ""

# Clone target repo
echo "--- Cloning ${DEMO_REPO} ---"
gh repo clone "${DEMO_REPO}" "${TMPDIR}/workflow-demo"
cd "${TMPDIR}/workflow-demo"

# Create directory structure
mkdir -p demo

# Copy demo files
echo "--- Copying demo framework files ---"
cp "${SOURCE_ROOT}/demo/runbook.md"          demo/
cp "${SOURCE_ROOT}/demo/sample-prd.md"       demo/
cp "${SOURCE_ROOT}/demo/setup-demo-repo.sh"  demo/
cp "${SOURCE_ROOT}/demo/reset-demo.sh"       demo/
chmod +x demo/setup-demo-repo.sh demo/reset-demo.sh

# Copy the demo README (this is the repo's main README)
cp "${SOURCE_ROOT}/demo/demo-README.md"      README.md

echo ""
echo "--- Files staged ---"
ls -la
ls -la demo/
echo ""

# Commit and push
git add -A
git status

read -p "Commit and push to ${DEMO_REPO}? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git commit -m "Add VBI workflow demo framework

Includes:
- Demo runbook with talking points and timing
- Sample PRD (MCP API wrapper project)
- Setup and reset scripts for demo repo lifecycle
- README with prerequisites and quick start guide"

    git push
    echo ""
    echo "=== Published ==="
    echo "View at: https://github.com/${DEMO_REPO}"
else
    echo "Aborted. Files are staged in ${TMPDIR}/workflow-demo if you want to review."
fi
