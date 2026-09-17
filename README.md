# Isaac Lab Cartpole on USC CARC Discovery

在 USC CARC Discovery 集群上，使用 Apptainer、Isaac Sim 5.1 和 Isaac Lab 2.3.2 运行一个最小的 Cartpole PPO 强化学习例子。

## 运行环境

- Cluster: USC CARC Discovery
- Scheduler: Slurm
- GPU: NVIDIA L40S（推荐）或 A40
- Container runtime: Apptainer 1.5.3
- Container: `nvcr.io/nvidia/isaac-lab:2.3.2`
- RL algorithm: RSL-RL PPO
- Task: `Isaac-Cartpole-v0`

> Isaac Sim 需要带 RT Core 的 GPU。不要为这个项目选择 A100、V100 或 P100。

## 1. 申请交互式桌面

在 CARC OnDemand 的 Traveler Desktop 中选择：

| 字段 | 设置 |
|---|---|
| Cluster | `discovery` |
| Partition | `gpu` |
| CPUs | `16` |
| Memory | `64 GB` |
| GPU model | `L40S` |
| Number of GPUs | `1` |

进入桌面后确认：

```bash
nvidia-smi
```

## 2. 下载容器（只需一次）

```bash
bash scripts/setup.sh
```

默认文件位置：

```text
/scratch1/$USER/isaac-sim/isaac-lab/isaac-lab-2.3.2.sif
```

## 3. 最小仿真测试

```bash
bash scripts/smoke_test.sh
```

该命令以 headless 模式启动 Isaac Lab。看到 `[INFO]: Setup complete...` 表示 Isaac Sim、Isaac Lab 和 GPU 已连通。按 `Ctrl+C` 可结束持续运行的测试。

## 4. GUI 短训练

必须在 Traveler Desktop 终端中运行：

```bash
bash scripts/train_gui.sh
```

它会显示 4 个并行 Cartpole，并训练 30 次迭代。这个配置主要用于演示完整 RL 流程，不保证策略完全收敛。

## 5. Headless 完整训练

```bash
bash scripts/train_headless.sh
```

默认使用 256 个并行环境、150 次迭代。训练结果保存在：

```text
/scratch1/$USER/isaac-sim/isaac-lab/logs/rsl_rl/cartpole/
```

也可以覆盖默认参数：

```bash
NUM_ENVS=512 MAX_ITERATIONS=200 bash scripts/train_headless.sh
```

## 6. GUI 播放最新策略

```bash
bash scripts/play_gui.sh
```

`play.py` 会默认选择最近一次 Cartpole 训练及其最新 checkpoint。

## 7. 提交 Slurm 批处理作业

编辑 `slurm/train_cartpole.slurm`，把：

```text
#SBATCH --account=<PROJECT_ACCOUNT>
```

替换成自己的项目账户，例如 `haoji_1598`，然后提交：

```bash
sbatch slurm/train_cartpole.slurm
squeue --me
```

查看日志：

```bash
tail -f slurm-cartpole-<JOB_ID>.out
```

## Cartpole 中的 RL 定义

| 概念 | 内容 |
|---|---|
| Observation | 小车位置/速度、杆角度/角速度 |
| Action | 对小车施加的水平力 |
| Reward | 保持存活和杆直立 |
| Termination | 小车越界或达到时间上限 |
| Policy | PPO actor 神经网络 |
| Value function | PPO critic 神经网络 |

训练闭环：观察状态 → PPO 输出动作 → Isaac Sim 计算物理状态 → 环境计算奖励 → PPO 更新网络。

## 常见问题

### `Read-only file system: /isaac-sim/kit/data`

必须使用本项目脚本提供的可写目录绑定。SIF 镜像本身是只读的。

### `XOpenDisplay` 或 segmentation fault

Headless 训练应使用 `scripts/train_headless.sh`。GUI 命令必须从 Traveler Desktop 内运行，并确保：

```bash
echo "$DISPLAY"
ls /tmp/.X11-unix
```

### GUI 训练很慢

GUI 只用于观察。正式训练使用 headless 模式和更多并行环境。

### 重新申请作业后变量失效

本项目脚本会自行设置所有变量，不依赖之前终端中的 `export`。

## 许可

运行 NVIDIA 容器时，`ACCEPT_EULA=Y` 表示接受对应的 NVIDIA 软件许可协议。Isaac Lab 本身使用 BSD-3-Clause 许可证；请分别遵守 NVIDIA Isaac Sim、Isaac Lab 和相关依赖的许可证。
