#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

NUM_ENVS="${NUM_ENVS:-4}"
MAX_ITERATIONS="${MAX_ITERATIONS:-30}"

run_ilab_gui \
  "./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task Isaac-Cartpole-v0 --num_envs $NUM_ENVS --max_iterations $MAX_ITERATIONS"
