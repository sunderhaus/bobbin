# Use the incredibly lightweight Alpine Linux base
FROM alpine:latest

# Install ffmpeg without caching the apk index to keep the image small
RUN apk add --no-cache ffmpeg

# Set default blank environment variables (these get overridden at runtime)
ENV RTSP_URL=""
ENV STREAM_KEY=""
ENV ENABLE_AUDIO="true"

# Use 'exec' so FFmpeg runs as PID 1. This allows Docker/k8s to gracefully
# stop the process (SIGTERM) without it hanging.
# When ENABLE_AUDIO is not "true", camera audio is discarded and replaced
# with a silent stereo track (YouTube requires an audio stream).
CMD if [ "$ENABLE_AUDIO" = "true" ]; then \
      exec ffmpeg -nostdin -rtsp_transport tcp -tls_verify 0 -i "$RTSP_URL" \
        -vf scale=2560:1440 \
        -c:v libx264 -preset veryfast -b:v 9000k -maxrate 9000k -bufsize 18000k -g 60 \
        -c:a aac -b:a 128k \
        -f flv "rtmp://a.rtmp.youtube.com/live2/$STREAM_KEY"; \
    else \
      exec ffmpeg -nostdin -rtsp_transport tcp -tls_verify 0 -i "$RTSP_URL" \
        -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
        -map 0:v -map 1:a \
        -vf scale=2560:1440 \
        -c:v libx264 -preset veryfast -b:v 9000k -maxrate 9000k -bufsize 18000k -g 60 \
        -c:a aac -b:a 128k -shortest \
        -f flv "rtmp://a.rtmp.youtube.com/live2/$STREAM_KEY"; \
    fi
