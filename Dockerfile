# Tymeslot for Railway: the official slim image (no embedded PostgreSQL),
# pinned by version and digest, plus a small wrapper.
FROM luka1thb/tymeslot:1.48.1-slim@sha256:a452cd20c41a9eb30b5f8aeb8a9619fd4fd1d0e03f47732f27be8a370c1d55e5

USER root

COPY railway/ /app/railway/
RUN chmod 755 /app/railway/entrypoint.sh /app/railway/bootstrap-admin.sh /app/railway/ffmpeg \
 && ln -s /app/railway/ffmpeg /usr/local/bin/ffmpeg

# Small-plan defaults (Railway Free/Trial: 0.5 GB RAM).
# - RELEASE_MODE=interactive loads code on first use instead of preloading
#   every module at boot: about 110 MB idle instead of about 560 MB, which
#   otherwise gets the app OOM-killed at 0.5 GB.
# - The upstream pool default is 60 connections.
# - libvips and ffmpeg would otherwise size their thread pools to the host's
#   CPUs, not the service's.
ENV PORT=4000 \
    RELEASE_MODE=interactive \
    DATABASE_POOL_SIZE=10 \
    VIPS_CONCURRENCY=2 \
    FFMPEG_THREADS=2 \
    EMAIL_ADAPTER=test \
    EMAIL_FROM_NAME=Tymeslot

EXPOSE 4000

CMD ["/app/railway/entrypoint.sh"]
