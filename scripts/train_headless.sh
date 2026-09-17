#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

NUM_ENVS="${NUM_ENVS:-256}"
MAX_ITERATIONS="${MAX_ITERATIONS:-150}"

run_ilab_headless \
  "./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task Isaac-Cartpole-v0 --headless --num_envs $NUM_ENVS --max_iterations $MAX_ITERATIONS"
