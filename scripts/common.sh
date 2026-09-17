#!/usr/bin/env bash

set -euo pipefail

module purge
module load apptainer/1.5.3

export ISIM_ROOT="${ISIM_ROOT:-/scratch1/$USER/isaac-sim}"
export ILAB_ROOT="${ILAB_ROOT:-$ISIM_ROOT/isaac-lab}"
export ILAB_IMAGE="${ILAB_IMAGE:-$ILAB_ROOT/isaac-lab-2.3.2.sif}"
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-$ISIM_ROOT/apptainer-cache}"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$ISIM_ROOT/apptainer-tmp}"
export APPTAINERENV_ACCEPT_EULA=Y

if [[ -z "${SLURM_JOB_ID:-}" ]]; then
  echo "ERROR: Run this script inside a Slurm GPU allocation." >&2
  exit 1
fi

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "ERROR: No NVIDIA GPU is available in this allocation." >&2
  exit 1
fi

export ILAB_RUNTIME="${ILAB_RUNTIME:-${TMPDIR:-/tmp/$USER-isaaclab-$SLURM_JOB_ID}}"

mkdir -p \
  "$APPTAINER_CACHEDIR" \
  "$APPTAINER_TMPDIR" \
  "$ILAB_ROOT/cache" \
  "$ILAB_ROOT/omniverse-logs" \
  "$ILAB_ROOT/logs" \
  "$ILAB_ROOT/outputs" \
  "$ILAB_ROOT/data" \
  "$ILAB_RUNTIME/home-cache" \
  "$ILAB_RUNTIME/kit-cache" \
  "$ILAB_RUNTIME/kit-data" \
  "$ILAB_RUNTIME/kit-logs"

if [[ ! -f "$ILAB_IMAGE" ]]; then
  echo "ERROR: Container not found: $ILAB_IMAGE" >&2
  echo "Run: bash scripts/setup.sh" >&2
  exit 1
fi

ILAB_BINDS=(
  --bind "$ILAB_RUNTIME/home-cache:$HOME/.cache"
  --bind "$ILAB_RUNTIME/kit-cache:/isaac-sim/kit/cache"
  --bind "$ILAB_RUNTIME/kit-data:/isaac-sim/kit/data"
  --bind "$ILAB_RUNTIME/kit-logs:/isaac-sim/kit/logs"
  --bind "$ILAB_ROOT/omniverse-logs:$HOME/.nvidia-omniverse/logs"
  --bind "$ILAB_ROOT/logs:/workspace/isaaclab/logs"
  --bind "$ILAB_ROOT/outputs:/workspace/isaaclab/outputs"
  --bind "$ILAB_ROOT/data:/workspace/isaaclab/data_storage"
)

run_ilab_headless() {
  apptainer exec --nv \
    --env ACCEPT_EULA=Y \
    "${ILAB_BINDS[@]}" \
    "$ILAB_IMAGE" \
    bash -lc "unset DISPLAY; cd /workspace/isaaclab; $*"
}

run_ilab_gui() {
  if [[ -z "${DISPLAY:-}" ]]; then
    echo "ERROR: DISPLAY is empty. Run this from a Traveler Desktop terminal." >&2
    exit 1
  fi
  if [[ ! -d /tmp/.X11-unix ]]; then
    echo "ERROR: /tmp/.X11-unix is unavailable." >&2
    exit 1
  fi

  apptainer exec --nv \
    --env ACCEPT_EULA=Y \
    --env DISPLAY="$DISPLAY" \
    --bind /tmp/.X11-unix:/tmp/.X11-unix \
    "${ILAB_BINDS[@]}" \
    "$ILAB_IMAGE" \
    bash -lc "cd /workspace/isaaclab; $*"
}
