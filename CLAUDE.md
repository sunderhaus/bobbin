# Bobbin

RTSPS-to-YouTube-Live relay. FFmpeg in a Docker container copies an RTSPS video stream and pushes it to YouTube's RTMP ingest.

## Project Structure

```
Dockerfile          # Alpine Linux + FFmpeg, env-var-driven CMD
docker-compose.yml  # Single service, auto-restart, env var interpolation from .env
.env.example        # Template for required environment variables
.gitignore          # Excludes .env (secrets)
README.md           # User-facing setup and usage docs
```

## How It Works

The container runs a single FFmpeg process that:
1. Connects to an RTSPS source over TCP (TLS verification disabled for self-signed camera certs)
2. Scales video to 1080p (1920x1080) and re-encodes with H.264 at 4500kbps
3. Transcodes audio to AAC at 128kbps
4. Pushes the output as FLV to `rtmp://a.rtmp.youtube.com/live2/`

FFmpeg runs as PID 1 via `exec` in shell form (not JSON exec form, because env var expansion is required). Docker sends SIGTERM directly to FFmpeg on stop.

## Configuration

Two required environment variables, set via `.env` file:

- `RTSP_URL` — RTSPS source URL (camera/device)
- `STREAM_KEY` — YouTube Live stream key

## Build & Run

```bash
cp .env.example .env   # fill in values
docker compose up -d   # build and start
docker logs -f rtsp-youtube-stream  # verify
docker compose down    # stop
```

## Design Decisions

- **Alpine base**: Minimal image (~111MB with FFmpeg and codec deps)
- **Shell form CMD with exec**: JSON exec form can't expand `$RTSP_URL`/`$STREAM_KEY`; shell form + `exec` gives PID 1 behavior with variable expansion
- **`restart: unless-stopped`**: Auto-recovers from FFmpeg crashes without manual intervention
- **Video re-encoding to 1080p**: Camera outputs 2688x1512 which YouTube rejects; scaled to 1920x1080 with libx264 `veryfast` preset at 4500kbps (YouTube's recommended range for 1080p). Uses `-maxrate`/`-bufsize` for CBR-like output suitable for live streaming
- **TLS verification disabled (`-tls_verify 0`)**: Cameras commonly use self-signed certificates; FFmpeg would reject the RTSPS connection without this flag
