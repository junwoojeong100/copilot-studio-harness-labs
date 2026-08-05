#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/generated/TriageWorkflowSolution/src"
DIST="$ROOT/dist"

mkdir -p "$DIST"
rm -f "$DIST/triage-workflows.zip" "$DIST/triage-workflows-pack.log"

cp \
  "$ROOT/generated/standard-agent/workflows/ClassifyIssue-0d6fe1bc-4f73-4d24-97fd-d52a8df08481/workflow.json" \
  "$SOURCE/Workflows/ClassifyIssueStandard-0D6FE1BC-4F73-4D24-97FD-D52A8DF08481.json"

cp \
  "$ROOT/generated/github-agent/workflows/ClassifyIssue-b28bf51a-c2b7-4f7a-af53-cfd72134b92a/workflow.json" \
  "$SOURCE/Workflows/ClassifyIssueGitHubHarness-B28BF51A-C2B7-4F7A-AF53-CFD72134B92A.json"

bash "$ROOT/scripts/pac.sh" solution pack \
  --zipfile "$DIST/triage-workflows.zip" \
  --folder "$SOURCE" \
  --packagetype Unmanaged \
  --log "$DIST/triage-workflows-pack.log" \
  --errorlevel Info

echo "Workflow package created: $DIST/triage-workflows.zip"
