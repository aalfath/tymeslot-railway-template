[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/tymeslot-1?utm_medium=integration&utm_source=button&utm_campaign=tymeslot)

# Tymeslot on Railway

One-click [Tymeslot](https://tymeslot.app) (open-source meeting scheduling, a Calendly alternative built on Elixir and Phoenix LiveView) for [Railway](https://railway.com).

**Version:** Tymeslot `1.48.1`, official image `luka1thb/tymeslot:1.48.1-slim@sha256:a452cd20c41a9eb30b5f8aeb8a9619fd4fd1d0e03f47732f27be8a370c1d55e5` (the slim image carries no embedded PostgreSQL).

## What it deploys

| Service | Source | Volume | Role |
|---|---|---|---|
| `Tymeslot` | this repo (`Dockerfile`) | `/app/data` (uploads, tz data) | The web app on port 4000, health check `/healthcheck` |
| `Postgres` | Railway's PostgreSQL | `/var/lib/postgresql/data` | All accounts, schedules and bookings |

The app waits for PostgreSQL and runs its database migrations on every start, then serves on the Railway domain.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `ADMIN_EMAIL` | *(you enter it)* | Email address of the admin account created on first boot. Use a real domain: Tymeslot rejects reserved ones such as `.test` or `.local` |
| `ADMIN_PASSWORD` | generated | Admin password (16 chars + `Aa1!`, meets Tymeslot's rules). Read it in the service's Variables tab |
| `SECRET_KEY_BASE` | generated (64 chars) | Signs sessions and cookies |
| `DATA_ENCRYPTION_KEY` | generated (Base64, 48 bytes) | Encrypts stored calendar and video credentials. Never change it after the first boot |
| `PHX_HOST` | `${{RAILWAY_PUBLIC_DOMAIN}}` | Public host name used in links |
| `DATABASE_HOST`, `DATABASE_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | references to `Postgres` | Private-network database connection |
| `PORT` | `4000` | Listen port |

Everything else (SMTP, Google/GitHub sign-in, calendar OAuth apps, Zoom, Stripe) is optional and set later as variables; see the [Tymeslot docs](https://tymeslot.app/docs).

## After deploy

1. Open the public URL and log in with `ADMIN_EMAIL` and `ADMIN_PASSWORD`.
2. The first boot closes public sign-up so strangers can't create accounts. Reopen it at `/admin` if you want others to register.
3. **Set up email.** Until you do, Tymeslot discards every email (booking confirmations, reminders, password resets). Add `EMAIL_ADAPTER=smtp` with `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` and `EMAIL_FROM_ADDRESS` (or `postmark` with `POSTMARK_API_KEY`).
4. Connect calendars and video in the dashboard (CalDAV, Nextcloud, Radicale work with no OAuth app; Google and Outlook need your own OAuth client).

**Memory:** it runs in 0.5 GB RAM (Railway's smallest plan). Measured with a 512 MB limit: about 120–130 MB of app memory when idle and after a login, no OOM kills. The template loads code on demand (`RELEASE_MODE=interactive`); upstream's default embedded mode needs about 560 MB and is killed at 0.5 GB.

If the app stops unexpectedly it exits non-zero, so Railway's restart policy brings it back.

## How updates reach you

This template builds from this repository. When a new Tymeslot version is pinned here and merged to `main`, Railway shows an "update available" notice on your project, and you choose when to apply it. Read `CHANGELOG.md` first: breaking changes are listed at the top of each entry. Migrations run automatically on start.

## Files

- `Dockerfile`: the pinned official image plus the wrapper below.
- `railway/entrypoint.sh`: sets defaults, starts the admin bootstrap in the background, then runs upstream's `start-docker.sh` (wait for the database, migrate, start).
- `railway/bootstrap-admin.sh` / `bootstrap-admin.exs`: once the server is up, creates a verified admin from `ADMIN_EMAIL` / `ADMIN_PASSWORD` if none exists, and closes public sign-up.
- `railway/ffmpeg`: limits ffmpeg's threads for video uploads on small plans.

Tymeslot is © its authors, licensed AGPL-3.0. This wrapper is not affiliated with the Tymeslot project.
