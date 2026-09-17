#!/usr/bin/env bash

set -euo pipefail

module purge
module load apptainer/1.5.3

ISIM_ROOT="${ISIM_ROOT:-/scratch1/$USER/isaac-sim}"
ILAB_ROOT="${ILAB_ROOT:-$ISIM_ROOT/isaac-lab}"
ILAB_IMAGE="${ILAB_IMAGE:-$ILAB_ROOT/isaac-lab-2.3.2.sif}"

export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-$ISIM_ROOT/apptainer-cache}"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-$ISIM_ROOT/apptainer-tmp}"

mkdir -p "$ILAB_ROOT" "$APPTAINER_CACHEDIR" "$APPTAINER_TMPDIR"

if [[ -f "$ILAB_IMAGE" ]]; then
  echo "Container already exists: $ILAB_IMAGE"
  exit 0
fi

apptainer pull "$ILAB_IMAGE" docker://nvcr.io/nvidia/isaac-lab:2.3.2
echo "Downloaded: $ILAB_IMAGE"
