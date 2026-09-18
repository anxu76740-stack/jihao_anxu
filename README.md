# Isaac Lab Cartpole RL on USC CARC Discovery

This project runs a minimal reinforcement learning example with NVIDIA Isaac Sim 5.1, Isaac Lab 2.3.2, and RSL-RL PPO on the USC CARC Discovery cluster. The example trains a policy to balance a pole on a moving cart and displays the simulation through the CARC Traveler Desktop.

## 1. Launch a Traveler Desktop GPU Session

Use the following settings in CARC OnDemand:

| Setting | Value |
|---|---|
| Desktop environment | `Rocky Linux 8 + Xfce 4.16` |
| Cluster | `discovery` |
| Project account | `haoji_1598` |
| Partition | `gpu` |
| Number of CPUs | `16` |
| Memory | `64 GB` |
| GPU model | `L40S` |
| Number of GPUs | `1` |
| Constraint | Leave blank |

Open a terminal inside the Traveler Desktop after the session starts.

## 2. Check the GPU and Display

```bash
hostname
echo "SLURM_JOB_ID=$SLURM_JOB_ID"
echo "DISPLAY=$DISPLAY"
nvidia-smi
```

## 3. Set Up the Environment

```bash
module purge
module load apptainer/1.5.3

export ISIM_ROOT=/scratch1/$USER/isaac-sim
export ILAB_ROOT=$ISIM_ROOT/isaac-lab
export ILAB_IMAGE=$ILAB_ROOT/isaac-lab-2.3.2.sif

export APPTAINER_CACHEDIR=$ISIM_ROOT/apptainer-cache
export APPTAINER_TMPDIR=$ISIM_ROOT/apptainer-tmp
export APPTAINERENV_ACCEPT_EULA=Y

mkdir -p \
  "$APPTAINER_CACHEDIR" \
  "$APPTAINER_TMPDIR" \
  "$ILAB_ROOT/cache" \
  "$ILAB_ROOT/omniverse-logs" \
  "$ILAB_ROOT/logs" \
  "$ILAB_ROOT/outputs" \
  "$ILAB_ROOT/data"

cd "$ILAB_ROOT"
```

## 4. Download the Isaac Lab Container

Run this once. Skip it if the SIF file already exists.

```bash
apptainer pull "$ILAB_IMAGE" \
  docker://nvcr.io/nvidia/isaac-lab:2.3.2

ls -lh "$ILAB_IMAGE"
```

## 5. Verify GPU Access Inside the Container

```bash
apptainer exec --nv \
  "$ILAB_IMAGE" \
  nvidia-smi
```

## 6. Create Writable Runtime Directories

```bash
export ILAB_RUNTIME="${TMPDIR:-/tmp/$USER-isaaclab-$SLURM_JOB_ID}"

mkdir -p \
  "$ILAB_RUNTIME/home-cache" \
  "$ILAB_RUNTIME/kit-cache" \
  "$ILAB_RUNTIME/kit-data" \
  "$ILAB_RUNTIME/kit-logs" \
  "$ILAB_ROOT/omniverse-logs" \
  "$ILAB_ROOT/logs" \
  "$ILAB_ROOT/outputs" \
  "$ILAB_ROOT/data"
```

## 7. Train Cartpole in the Isaac Sim GUI

```bash
apptainer exec --nv \
  --env ACCEPT_EULA=Y \
  --env DISPLAY="$DISPLAY" \
  --bind /tmp/.X11-unix:/tmp/.X11-unix \
  --bind "$ILAB_RUNTIME/home-cache:$HOME/.cache" \
  --bind "$ILAB_RUNTIME/kit-cache:/isaac-sim/kit/cache" \
  --bind "$ILAB_RUNTIME/kit-data:/isaac-sim/kit/data" \
  --bind "$ILAB_RUNTIME/kit-logs:/isaac-sim/kit/logs" \
  --bind "$ILAB_ROOT/omniverse-logs:$HOME/.nvidia-omniverse/logs" \
  --bind "$ILAB_ROOT/logs:/workspace/isaaclab/logs" \
  --bind "$ILAB_ROOT/outputs:/workspace/isaaclab/outputs" \
  --bind "$ILAB_ROOT/data:/workspace/isaaclab/data_storage" \
  "$ILAB_IMAGE" \
  bash -lc '
    cd /workspace/isaaclab
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
      --task Isaac-Cartpole-v0 \
      --num_envs 4 \
      --max_iterations 30
  '
```

This short run verifies the complete RL training and GUI workflow.

## 8. Train a Better Policy Without the GUI

```bash
apptainer exec --nv \
  --env ACCEPT_EULA=Y \
  --bind "$ILAB_RUNTIME/home-cache:$HOME/.cache" \
  --bind "$ILAB_RUNTIME/kit-cache:/isaac-sim/kit/cache" \
  --bind "$ILAB_RUNTIME/kit-data:/isaac-sim/kit/data" \
  --bind "$ILAB_RUNTIME/kit-logs:/isaac-sim/kit/logs" \
  --bind "$ILAB_ROOT/omniverse-logs:$HOME/.nvidia-omniverse/logs" \
  --bind "$ILAB_ROOT/logs:/workspace/isaaclab/logs" \
  --bind "$ILAB_ROOT/outputs:/workspace/isaaclab/outputs" \
  --bind "$ILAB_ROOT/data:/workspace/isaaclab/data_storage" \
  "$ILAB_IMAGE" \
  bash -lc '
    unset DISPLAY
    cd /workspace/isaaclab
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
      --task Isaac-Cartpole-v0 \
      --num_envs 256 \
      --max_iterations 150 \
      --headless
  '
```

## 9. Play the Latest Trained Policy in the GUI

```bash
apptainer exec --nv \
  --env ACCEPT_EULA=Y \
  --env DISPLAY="$DISPLAY" \
  --bind /tmp/.X11-unix:/tmp/.X11-unix \
  --bind "$ILAB_RUNTIME/home-cache:$HOME/.cache" \
  --bind "$ILAB_RUNTIME/kit-cache:/isaac-sim/kit/cache" \
  --bind "$ILAB_RUNTIME/kit-data:/isaac-sim/kit/data" \
  --bind "$ILAB_RUNTIME/kit-logs:/isaac-sim/kit/logs" \
  --bind "$ILAB_ROOT/omniverse-logs:$HOME/.nvidia-omniverse/logs" \
  --bind "$ILAB_ROOT/logs:/workspace/isaaclab/logs" \
  --bind "$ILAB_ROOT/outputs:/workspace/isaaclab/outputs" \
  --bind "$ILAB_ROOT/data:/workspace/isaaclab/data_storage" \
  "$ILAB_IMAGE" \
  bash -lc '
    cd /workspace/isaaclab
    ./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/play.py \
      --task Isaac-Cartpole-v0 \
      --num_envs 4
  '
```

Press `Ctrl+C` in the terminal to stop playback.

## 10. Run Again in a New CARC Session

The SIF image and training results remain under `/scratch1`. In a new GPU Traveler Desktop session, repeat Sections 2, 3, and 6, then run either Section 7, 8, or 9. Do not download the container again.
