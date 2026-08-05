#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/pac"
DIST="$ROOT/dist"

rm -rf "$BUILD/standard-agent" "$BUILD/github-agent"
mkdir -p "$BUILD" "$DIST"

cp -R "$ROOT/generated/standard-agent" "$BUILD/standard-agent"
rm -rf "$BUILD/standard-agent/actions" "$BUILD/standard-agent/workflows"

cp -R "$ROOT/generated/github-agent" "$BUILD/github-agent"
rm -rf "$BUILD/github-agent/actions" "$BUILD/github-agent/workflows"

rm -rf "$DIST/TriageStandardAgent.zip" "$DIST/TriageGitHubHarnessAgent.zip"

bash "$ROOT/scripts/pac.sh" copilot pack \
  --publisher-prefix triage \
  --project-dir "$BUILD/standard-agent" \
  --solution-name TriageStandardAgent \
  --output-path "$DIST"

bash "$ROOT/scripts/pac.sh" copilot pack \
  --publisher-prefix triage \
  --project-dir "$BUILD/github-agent" \
  --solution-name TriageGitHubHarnessAgent \
  --output-path "$DIST"

echo "Agent packages created under $DIST."

