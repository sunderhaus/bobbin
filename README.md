# Bobbin

Relay an RTSP stream to YouTube Live using FFmpeg in a lightweight Docker container.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

## Setup

1. Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

2. Edit `.env` with your RTSP source URL and YouTube stream key:

```
RTSP_URL=rtsp://192.168.1.100:554/stream
STREAM_KEY=xxxx-xxxx-xxxx-xxxx-xxxx
```

## Environment Variables

| Variable     | Description                                                        |
| ------------ | ------------------------------------------------------------------ |
| `RTSP_URL`   | RTSP source URL from your camera or streaming device               |
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

The container runs FFmpeg which connects to your RTSP source over TCP, copies the video stream as-is (no re-encoding), transcodes audio to AAC at 128kbps, and pushes the result as FLV to YouTube's RTMP ingest server. The container automatically restarts if FFmpeg exits or crashes.
