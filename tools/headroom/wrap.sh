#!/usr/bin/env bash
# Wrap a coding agent with Headroom using our shared settings.
# Usage: ./wrap.sh <agent> [extra headroom args]
#   agent: claude | codex | cursor | aider | copilot | gemini
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "$here/headroom.env"

agent="${1:-claude}"
shift || true

if ! command -v headroom >/dev/null 2>&1; then
  echo "headroom not found — run ./setup.sh first." >&2
  exit 1
fi

echo "→ headroom wrap $agent  (mode=$HEADROOM_MODE, telemetry=$HEADROOM_TELEMETRY)"
exec headroom wrap "$agent" "$@"
