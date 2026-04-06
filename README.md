# Bobbin

Relay an RTSPS stream to YouTube Live using FFmpeg in a lightweight Docker container.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

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

Build and start the container:

```bash
docker compose up -d
```

Check the logs to verify FFmpeg is streaming:

```bash
docker logs -f rtsp-youtube-stream
```

Stop the stream:

```bash
docker compose down
```

## How It Works

The container runs FFmpeg which connects to your RTSPS source over TCP (TLS verification disabled for self-signed camera certs), scales the video from its native resolution to 1080p (1920x1080), re-encodes it with H.264 at 4500kbps, transcodes audio to AAC at 128kbps, and pushes the result as FLV to YouTube's RTMP ingest server. The container automatically restarts if FFmpeg exits or crashes.
