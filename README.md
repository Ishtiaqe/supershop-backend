# SuperShop Backend

This repository contains the backend API for the SuperShop multi-tenant shop management system. The codebase uses NestJS, Prisma, and PostgreSQL. The `src/` directory holds the application code and `dist/` contains production builds.

## Quick start
### Cloud Run (local & Cloud Code)

This repository is intended to run on Google Cloud Run in production. If you use Cloud Code to run/debug locally (Cloud Run emulator with minikube), follow these steps. The most common error is minikube's inability to pull base images from Docker Hub (DNS issues when minikube behind a firewall or systemd-resolved). See troubleshooting steps below.

1. Start `minikube` (Cloud Code will start a profile named `cloud-run-dev-internal` automatically). You can also run it manually:

```bash
minikube start -p cloud-run-dev-internal
```

2. Preload the Node base image into minikube to avoid `index.docker.io` DNS failures:

```bash
docker pull node:20-alpine
minikube image load node:20-alpine -p cloud-run-dev-internal
```

Alternatively run the included script:

```bash
chmod +x scripts/minikube-prereqs.sh
scripts/minikube-prereqs.sh
```

3. Ensure Cloud Run local has the correct container port defined (`8080` by default). Confirm `containerPort` is set to `8080` in `.vscode/launch.json`.

4. Start Cloud Run from Cloud Code in VS Code: run **Cloud Run: Run/Debug Locally** from the Run panel or the command palette.

Troubleshooting DNS/pulling errors
- If Skaffold or minikube fail with "dial tcp: lookup index.docker.io on 127.0.0.53:53: server misbehaving", it is an environment DNS issue. The script above will prevent Docker from attempting to re-pull the base image in minikube.
- If you still have DNS errors, try `minikube ssh -- sudo systemctl restart systemd-resolved` or adjust your host DNS settings.
- If your network restricts access to docker hub, configure a mirror or use a private registry.

1. Install dependencies:

```bash
npm install
```

2. Run in development mode (hot reload):

```bash
npm run start:dev
```

3. Build for production and run (local):

```bash
npm run build
npm run start:prod
```

## Docker (production-like)

```bash
docker build -t supershop-backend .
docker run -p 8080:8080 --env-file .env -it supershop-backend
```

After starting the app, the API documentation is available at: `http://localhost:8080/api/docs`

Port and Cloud Run
- Cloud Run requires that apps listen on the PORT environment variable. This project uses `process.env.PORT` and falls back to `8080` in `src/main.ts`. The default `containerPort` for Cloud Run is `8080` — if you change the port, update `containerPort` in `.vscode/launch.json`.

Check `GET /api/v1/health` after the Cloud Run emulator or Docker container starts:

```bash
curl -fsS http://localhost:8080/api/v1/health
```

## Database backups

The backend contains helper scripts for backing up the Postgres database and exporting data via Prisma.

- `scripts/backup-db.sh` — uses `pg_dump` to create SQL dumps (custom format)
- `scripts/export-prisma.ts` — exports each Prisma model into JSON files under `backups/`
- `scripts/query-to-inserts.ts` — runs SQL queries and exports results as INSERT statements

See `BACKUP_RESTORE_GUIDE.md` for detailed instructions on backups and restores.
