# Bobbin

Relay an RTSPS stream to YouTube Live using FFmpeg in a lightweight Docker container.

## Prerequisites

- [Podman](https://podman.io/docs/installation) with [Podman Compose](https://github.com/containers/podman-compose), or [Docker](https://docs.docker.com/get-docker/) with [Docker Compose](https://docs.docker.com/compose/install/)

## Setup

1. Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

2. Edit `.env` with your RTSPS source URL and YouTube stream key:

```
RTSP_URL=rtsps://192.168.1.100:554/stream
STREAM_KEY=xxxx-xxxx-xxxx-xxxx-xxxx
```

## Environment Variables

| Variable     | Description                                                        |
| ------------ | ------------------------------------------------------------------ |
| `RTSP_URL`   | RTSPS source URL from your camera or streaming device              |
| `STREAM_KEY` | YouTube Live stream key (YouTube Studio > Go Live > Stream Settings) |

## Usage

### Podman (CPU)

```bash
podman compose up -d
podman logs -f rtsp-youtube-stream
podman compose down
```

### Podman with NVIDIA GPU

```bash
podman compose -f docker-compose.yml -f docker-compose.podman-nvidia.yml up -d
podman logs -f rtsp-youtube-stream
podman compose -f docker-compose.yml -f docker-compose.podman-nvidia.yml down
```

Requires [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) with CDI configured:

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

### Docker (CPU)

```bash
docker compose up -d
docker logs -f rtsp-youtube-stream
docker compose down
```

### Docker with NVIDIA GPU

```bash
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d
docker logs -f rtsp-youtube-stream
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml down
```

Requires [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html):

```bash
nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

The GPU path uses NVDEC for decoding, CUDA for scaling, and NVENC for encoding — frames stay in GPU memory throughout the pipeline.

## How It Works

The container runs FFmpeg which connects to your RTSPS source over TCP (TLS verification disabled for self-signed camera certs), scales the video from its native resolution to 1080p (1920x1080), re-encodes it with H.264 at 4500kbps, transcodes audio to AAC at 128kbps, and pushes the result as FLV to YouTube's RTMP ingest server. The container automatically restarts if FFmpeg exits or crashes.
