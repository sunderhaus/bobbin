# Use the incredibly lightweight Alpine Linux base
FROM alpine:latest

# Install ffmpeg without caching the apk index to keep the image small
RUN apk add --no-cache ffmpeg

# Set default blank environment variables (these get overridden at runtime)
ENV RTSP_URL=""
ENV STREAM_KEY=""

# Use 'exec' so FFmpeg runs as PID 1. This allows Docker/k8s to gracefully
# stop the process (SIGTERM) without it hanging.
CMD exec ffmpeg -nostdin -rtsp_transport tcp -tls_verify 0 -i "$RTSP_URL" -vf scale=1920:1080 -c:v libx264 -preset veryfast -b:v 4500k -maxrate 4500k -bufsize 9000k -g 60 -c:a aac -b:a 128k -f flv "rtmp://a.rtmp.youtube.com/live2/$STREAM_KEY"
