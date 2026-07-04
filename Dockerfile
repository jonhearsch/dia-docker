# syntax=docker/dockerfile:1
# Dia TTS (nari-labs/dia) | NVIDIA GPU
# https://github.com/nari-labs/dia

FROM nvidia/cuda:12.6.3-runtime-ubuntu22.04

ARG DIA_COMMIT=main
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_NO_CACHE=1 \
    # HuggingFace cache → persistent volume
    HF_HOME=/data/hf-cache \
    GRADIO_SERVER_NAME=0.0.0.0

# uv — fast Python package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        ffmpeg \
        libsndfile1 \
        python3.11 \
        python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Non-root user (UID 99 / GID 100 = nobody:users, matches Unraid share permissions)
RUN groupadd -g 100 users 2>/dev/null || true \
    && useradd -u 99 -g 100 -d /home/dia -m -s /bin/bash dia \
    && mkdir -p /app /data/hf-cache /data/outputs \
    && chown -R 99:100 /app /data

WORKDIR /app
USER dia

# Clone the pinned commit
RUN git clone https://github.com/nari-labs/dia.git . \
    && git checkout "${DIA_COMMIT}"

# Install deps via uv into a venv
RUN uv venv venv --python python3.11 --seed
ENV VIRTUAL_ENV="/app/venv" \
    PATH="/app/venv/bin:$PATH"

RUN uv pip install \
        --index-url https://pypi.org/simple \
        --extra-index-url https://download.pytorch.org/whl/cu126 \
        "torch==2.6.0" \
        "torchaudio==2.6.0" \
        "triton==3.2.0" \
        "descript-audio-codec>=1.0.0" \
        "gradio>=5.25.2" \
        "huggingface-hub>=0.30.2" \
        "numpy>=2.2.4" \
        "pydantic>=2.11.3" \
        "safetensors>=0.5.3" \
        "soundfile>=0.13.1"

EXPOSE 7860

# HuggingFace model cache and outputs — bind-mount from host
VOLUME ["/data/hf-cache", "/data/outputs"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=10 \
    CMD curl -f http://localhost:7860/ || exit 1

CMD ["python", "app.py"]
