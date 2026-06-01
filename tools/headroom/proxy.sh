#!/usr/bin/env bash
# Run the Headroom drop-in proxy with our shared settings.
# Point any OpenAI/Anthropic-compatible client at http://$HEADROOM_HOST:$HEADROOM_PORT
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "$here/headroom.env"

if ! command -v headroom >/dev/null 2>&1; then
  echo "headroom not found — run ./setup.sh first." >&2
  exit 1
fi

echo "→ headroom proxy on http://$HEADROOM_HOST:$HEADROOM_PORT  (mode=$HEADROOM_MODE)"
exec headroom proxy --port "$HEADROOM_PORT" "$@"
