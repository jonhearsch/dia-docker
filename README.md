# dia-docker

Auto-built Docker image for [Dia TTS](https://github.com/nari-labs/dia) by Nari Labs — a 1.6B text-to-dialogue model. Targets NVIDIA GPUs (CUDA 12.6).

Since Dia doesn't publish releases, the nightly workflow tracks the latest commit on `main` and rebuilds when it changes.

## What is Dia?

Dia generates realistic multi-speaker dialogue audio from text. Supports voice cloning via an audio prompt. Uses `[S1]` / `[S2]` speaker tags.

Example:
```
[S1] Hey, did you hear about the new model?
[S2] Yeah, it sounds incredible. (laughs)
[S1] Right? Let's try it out.
```

## Quick start

```bash
docker compose up -d
```

Open: `http://localhost:7861`

First run downloads the Dia-1.6B model from HuggingFace (~3GB) into the `hf-cache` volume — takes a few minutes. Subsequent starts are instant.

## Volume mounts

| Host path | Container path | Purpose |
|-----------|---------------|---------|
| `.../hf-cache` | `/data/hf-cache` | HuggingFace model cache (persists across rebuilds) |
| `.../outputs` | `/data/outputs` | Generated audio files |

## Image tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest `main` branch build |
| `abc1234` | Pinned to a specific 7-char commit SHA |
