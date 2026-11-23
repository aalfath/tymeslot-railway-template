# Changelog

## 1.48.1 (2026-11-23)

First release of the template.

- Tymeslot `1.48.1`, `luka1thb/tymeslot:1.48.1-slim@sha256:a452cd20c41a9eb30b5f8aeb8a9619fd4fd1d0e03f47732f27be8a370c1d55e5`, with Railway PostgreSQL.
- A verified admin is created on first boot from `ADMIN_EMAIL` / `ADMIN_PASSWORD`, and public sign-up is closed.
- Small-plan defaults: `DATABASE_POOL_SIZE=10`, `VIPS_CONCURRENCY=2`, ffmpeg limited to 2 threads.
