#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT/bootstrap/common.sh"

# Make nix available in the current shell if just installed
NIX_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
[ -f "$NIX_PROFILE" ] && source "$NIX_PROFILE"

nix profile install "$ROOT#userland"
"$ROOT/scripts/link.sh"
