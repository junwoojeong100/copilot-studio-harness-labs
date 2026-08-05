#!/usr/bin/env bash
set -euo pipefail

if ! command -v dotnet >/dev/null 2>&1; then
  echo "Install .NET 10 or later from https://dotnet.microsoft.com/download first." >&2
  exit 1
fi

if [[ -x "$HOME/.dotnet/tools/pac" ]]; then
  dotnet tool update --global Microsoft.PowerApps.CLI.Tool
else
  dotnet tool install --global Microsoft.PowerApps.CLI.Tool
fi

bash "$(dirname "$0")/pac.sh" help >/dev/null
echo "Power Platform CLI is ready."

