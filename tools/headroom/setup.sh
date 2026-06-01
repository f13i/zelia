#!/usr/bin/env bash
# Install Headroom and lay down our config. Idempotent — safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "$here/headroom.env"

echo "→ Installing headroom-ai[all] (Python 3.10+ required)…"
if command -v uv >/dev/null 2>&1; then
  uv pip install --upgrade "headroom-ai[all]"
else
  python3 -m pip install --upgrade "headroom-ai[all]"
fi

# Copy our models.json into the canonical config dir so it's picked up even
# when the env file isn't sourced (e.g. inline library use).
config_dir="${HEADROOM_CONFIG_DIR:-$HOME/.headroom/config}"
mkdir -p "$config_dir"
cp "$here/models.json" "$config_dir/models.json"
echo "→ Wrote $config_dir/models.json"

echo "→ Headroom version: $(headroom --version 2>/dev/null || echo 'installed')"
echo
echo "Done. Next:"
echo "  ./wrap.sh claude     # wrap a coding agent"
echo "  ./proxy.sh           # run the drop-in proxy on :${HEADROOM_PORT}"
echo "  headroom stats       # see savings"
