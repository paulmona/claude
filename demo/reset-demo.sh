#!/usr/bin/env bash
set -euo pipefail

# Reset script for VBI Demo
# Cleans up GitHub milestones, issues, and labels so the demo can be run again
#
# Usage: ./reset-demo.sh owner/repo
#   e.g. ./reset-demo.sh paulmona/mcp-api-wrapper-demo

REPO="${1:-}"

if [[ -z "$REPO" ]]; then
    echo "Usage: ./reset-demo.sh owner/repo"
    echo "  e.g. ./reset-demo.sh paulmona/mcp-api-wrapper-demo"
    exit 1
fi

echo "=== VBI Demo Reset ==="
echo "Target repo: ${REPO}"
echo ""
echo "This will delete ALL issues, milestones, and custom labels from ${REPO}."
read -p "Are you sure? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 0
fi

echo ""

# Close and delete all issues
echo "--- Closing all issues ---"
ISSUE_NUMBERS=$(gh issue list --repo "$REPO" --state all --limit 500 --json number --jq '.[].number' 2>/dev/null || echo "")

if [[ -n "$ISSUE_NUMBERS" ]]; then
    issue_count=$(echo "$ISSUE_NUMBERS" | wc -l)
    echo "Found ${issue_count} issues to delete."

    for num in $ISSUE_NUMBERS; do
        echo "  Deleting issue #${num}..."
        gh api -X DELETE "repos/${REPO}/issues/${num}" 2>/dev/null || \
            gh issue close "$REPO" --repo "$REPO" "$num" 2>/dev/null || true
    done
    echo "Issues cleaned up."
else
    echo "No issues found."
fi

echo ""

# Delete all milestones
echo "--- Deleting milestones ---"
MILESTONE_NUMBERS=$(gh api "repos/${REPO}/milestones?state=all" --jq '.[].number' 2>/dev/null || echo "")

if [[ -n "$MILESTONE_NUMBERS" ]]; then
    milestone_count=$(echo "$MILESTONE_NUMBERS" | wc -l)
    echo "Found ${milestone_count} milestones to delete."

    for num in $MILESTONE_NUMBERS; do
        echo "  Deleting milestone #${num}..."
        gh api -X DELETE "repos/${REPO}/milestones/${num}" 2>/dev/null || true
    done
    echo "Milestones deleted."
else
    echo "No milestones found."
fi

echo ""

# Delete custom labels (keep GitHub defaults)
echo "--- Deleting custom labels ---"
DEFAULT_LABELS="bug|documentation|duplicate|enhancement|good first issue|help wanted|invalid|question|wontfix"

LABELS=$(gh label list --repo "$REPO" --limit 200 --json name --jq '.[].name' 2>/dev/null || echo "")

if [[ -n "$LABELS" ]]; then
    while IFS= read -r label; do
        if echo "$label" | grep -qiE "^(${DEFAULT_LABELS})$"; then
            echo "  Keeping default label: ${label}"
        else
            echo "  Deleting label: ${label}..."
            gh label delete "$label" --repo "$REPO" --yes 2>/dev/null || true
        fi
    done <<< "$LABELS"
    echo "Labels cleaned up."
else
    echo "No labels found."
fi

echo ""

# Delete CLAUDE.md if it exists in the repo
echo "--- Checking for CLAUDE.md ---"
if gh api "repos/${REPO}/contents/CLAUDE.md" &>/dev/null; then
    SHA=$(gh api "repos/${REPO}/contents/CLAUDE.md" --jq '.sha')
    echo "  Deleting CLAUDE.md..."
    gh api -X DELETE "repos/${REPO}/contents/CLAUDE.md" \
        -f message="Reset: remove CLAUDE.md for demo" \
        -f sha="$SHA" 2>/dev/null || true
    echo "  CLAUDE.md deleted."
else
    echo "  No CLAUDE.md found."
fi

echo ""
echo "=== Reset Complete ==="
echo ""
echo "The repo ${REPO} is clean and ready for a fresh /vbi-bootstrap."
echo ""
echo "Don't forget to also reset in Notion:"
echo "  - Set GitHub Ready = false on the demo PRD"
