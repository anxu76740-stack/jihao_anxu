#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

run_ilab_headless \
  './isaaclab.sh -p scripts/tutorials/00_sim/log_time.py --headless'
