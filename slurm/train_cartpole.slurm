#!/bin/bash
#SBATCH --job-name=cartpole-ppo
#SBATCH --account=<PROJECT_ACCOUNT>
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --gpus-per-task=l40s:1
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=slurm-cartpole-%j.out
#SBATCH --error=slurm-cartpole-%j.err

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

NUM_ENVS=256 MAX_ITERATIONS=150 bash scripts/train_headless.sh
