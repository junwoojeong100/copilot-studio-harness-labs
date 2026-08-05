#!/usr/bin/env bash
set -euo pipefail

if ! command -v dotnet >/dev/null 2>&1; then
  echo "dotnet is required. Install .NET 10 or later first." >&2
  exit 1
fi

PAC_BIN="${PAC_BIN:-$HOME/.dotnet/tools/pac}"
if [[ ! -x "$PAC_BIN" ]]; then
  echo "Power Platform CLI is not installed. Run: bash scripts/install-pac.sh" >&2
  exit 1
fi

if command -v brew >/dev/null 2>&1; then
  DOTNET_ROOT="${DOTNET_ROOT:-$(brew --prefix dotnet)/libexec}"
fi

export DOTNET_ROOT
exec "$PAC_BIN" "$@"

