# Supershop Backend Deployment Guide (Cloud Run + Cloud SQL)

This guide documents the exact, working deployment flow we’re using: Cloud Run with the free Cloud SQL connector (no VPC connector), Secret Manager for sensitive config, and a custom domain via Cloudflare.

## Prerequisites

- `gcloud` installed and authenticated
  ```bash
  gcloud auth login
  gcloud config set project shomaj-817b0
  ```
- Cloud SQL Postgres instance: `shomaj-817b0:asia-southeast1:YOUR_INSTANCE`
- Secret Manager enabled
- Docker (for local builds) and Node 20+ (for local dev)

## Quick Start (Production)

1) Create/update secrets (URL-encode any special chars in password, e.g. `@` -> `%40`)
```bash
# JWTs
echo -n "<random-32+bytes>" | gcloud secrets create JWT_SECRET --data-file=- 2>/dev/null || \
echo -n "<random-32+bytes>" | gcloud secrets versions add JWT_SECRET --data-file=-
echo -n "<random-32+bytes>" | gcloud secrets create JWT_REFRESH_SECRET --data-file=- 2>/dev/null || \
echo -n "<random-32+bytes>" | gcloud secrets versions add JWT_REFRESH_SECRET --data-file=-
echo -n "15m" | gcloud secrets create JWT_EXPIRES_IN --data-file=- 2>/dev/null || \
echo -n "15m" | gcloud secrets versions add JWT_EXPIRES_IN --data-file=-
echo -n "7d" | gcloud secrets create JWT_REFRESH_EXPIRES_IN --data-file=- 2>/dev/null || \
echo -n "7d" | gcloud secrets versions add JWT_REFRESH_EXPIRES_IN --data-file=-

# DATABASE_URL using Cloud SQL connector (Unix socket) — free, no VPC connector
# Template: postgresql://USER:PASSWORD@localhost:5432/DB?host=/cloudsql/PROJECT:REGION:INSTANCE&schema=public&sslmode=disable
echo -n "postgresql://supershop_user:REDACTED%40PASS@localhost:5432/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:YOUR_INSTANCE&schema=public&sslmode=disable" \
| gcloud secrets create DATABASE_URL --data-file=- 2>/dev/null || \
echo -n "postgresql://supershop_user:REDACTED%40PASS@localhost:5432/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:YOUR_INSTANCE&schema=public&sslmode=disable" \
| gcloud secrets versions add DATABASE_URL --data-file=-
```

2) Build and deploy to Cloud Run (pick one):

- Build locally and deploy:
```bash
# Build the Docker image locally
docker build -t gcr.io/shomaj-817b0/supershop-backend .

# Push the image to Google Container Registry
docker push gcr.io/shomaj-817b0/supershop-backend

# Deploy to Cloud Run
gcloud run deploy supershop-backend \
  --image gcr.io/shomaj-817b0/supershop-backend \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest,GOOGLE_CLIENT_ID=GOOGLE_CLIENT_ID:latest,GOOGLE_CLIENT_SECRET=GOOGLE_CLIENT_SECRET:latest,GOOGLE_CALLBACK_URL=GOOGLE_CALLBACK_URL:latest,CORS_ORIGIN=CORS_ORIGIN:latest \
  --clear-vpc-connector
```

- Using an existing image (if already built and pushed):
```bash
gcloud run deploy supershop-backend \
  --image gcr.io/shomaj-817b0/supershop-backend \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest,GOOGLE_CLIENT_ID=GOOGLE_CLIENT_ID:latest,GOOGLE_CLIENT_SECRET=GOOGLE_CLIENT_SECRET:latest,GOOGLE_CALLBACK_URL=GOOGLE_CALLBACK_URL:latest,CORS_ORIGIN=CORS_ORIGIN:latest \
  --clear-vpc-connector
```

- Or build from source directly (in cloud):
```bash
gcloud run deploy supershop-backend \
  --source . \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest,GOOGLE_CLIENT_ID=GOOGLE_CLIENT_ID:latest,GOOGLE_CLIENT_SECRET=GOOGLE_CLIENT_SECRET:latest,GOOGLE_CALLBACK_URL=GOOGLE_CALLBACK_URL:latest,CORS_ORIGIN=CORS_ORIGIN:latest \
  --clear-vpc-connector
```

3) Verify
```bash
SERVICE_URL=$(gcloud run services describe supershop-backend --region asia-southeast1 --format="value(status.url)")
curl -sS "$SERVICE_URL/api/v1/health"
```

## Secrets and Env

Backend consumes these secrets via ConfigService:
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `JWT_EXPIRES_IN` (defaulted to 15m in code if missing)
- `JWT_REFRESH_EXPIRES_IN` (defaulted to 7d in code if missing)
- `DATABASE_URL` (must be the connector URL; passwords URL-encoded)
- `GOOGLE_CLIENT_ID` (required for Google OAuth)
- `GOOGLE_CLIENT_SECRET` (required for Google OAuth)
- `GOOGLE_CALLBACK_URL` (required for Google OAuth, e.g. "https://api.shomaj.one/api/v1/auth/google/callback")
- `CORS_ORIGIN` (comma-separated list of allowed origins, e.g. "http://localhost:3000,https://supershop.shomaj.one")

### Local secret manager sync (optional)

If you'd like to keep local `.env` or `.env.production` files synced with your Secret Manager values (for local testing), use the helper scripts in `scripts/`.

1) Ensure you have the gcloud CLI installed and set the right project.

2) Run the check to see which secrets exist:

```bash
./scripts/check-secrets.sh --project shomaj-817b0
```

3) Fetch and sync secrets into an env file (dry-run prints values without modifying):

```bash
# Dry-run, prints secrets
./scripts/fetch-secrets.sh --env-file .env --project shomaj-817b0 --dry-run

# Actually update your .env
./scripts/fetch-secrets.sh --env-file .env --project shomaj-817b0

# Update .env.production
./scripts/fetch-secrets.sh --env-file .env.production --project shomaj-817b0
```

Important: DO NOT commit your updated `.env` files with real secrets to the repository. Add them to `.gitignore` if necessary.


Non-secret envs (optional with safe defaults): `API_PREFIX`, `API_VERSION`, `PORT`.

## Database Migrations & Seed

Recommended: run migrations and seeding from your machine using the Cloud SQL Proxy (free) or connector:
```bash
# Start proxy (local)
./cloud-sql-proxy shomaj-817b0:asia-southeast1:YOUR_INSTANCE

# Test connection
npx -y prisma db execute --file /dev/stdin --url "postgresql://supershop_user:PWD%40ENC@localhost:5432/supershop?schema=public&sslmode=disable" <<<'select 1;'

# Apply migrations
npx prisma migrate deploy --schema prisma/schema.prisma --url "postgresql://supershop_user:PWD%40ENC@localhost:5432/supershop?schema=public&sslmode=disable"

# Seed
npm run prisma:seed  # or: ts-node prisma/seed.ts
```

## Local Development

```bash
npm install
cp .env.example .env
# Set local DATABASE_URL (proxy or local Postgres). URL-encode password!
npm run start:dev

## Sentry (Error Monitoring)

To enable Sentry for backend error monitoring, set the `SENTRY_DSN` secret in Secret Manager and add it to your Cloud Run envs (do not commit to repo). The backend will initialize Sentry when `SENTRY_DSN` is configured.

Recommended envs:
- `SENTRY_DSN` - (secret) The Sentry DSN for your project
- `SENTRY_TRACES_SAMPLE_RATE` - (optional) Fraction of requests to sample for performance tracing (default 0.1)

Once Sentry is enabled the server will automatically capture unhandled exceptions and send them to your configured Sentry project.

### Sentry usage & tracing examples (backend)

Use `@sentry/node` to capture exceptions and instrument spans/traces.

Exception example:
```typescript
import Sentry from '@sentry/node';

try {
  // some risky operation
} catch (error) {
  Sentry.captureException(error);
}
```

Custom Span instrumentation (for performance traces):
```typescript
import Sentry from '@sentry/node';

const span = Sentry.startSpan({ op: 'http.client', name: 'GET /api/users' });
// ... perform operation
span.finish();
```

Logger Integration:
The backend initialization uses `Sentry.consoleLoggingIntegration({ levels: ['log', 'warn', 'error'] })` to capture server logs as Sentry logs. Use `Sentry.captureMessage` or `Sentry.captureException` for structure logging in code.

## Authentication token strategy

The backend sets access and refresh tokens as HttpOnly cookies. Recommended policy:

- `accessToken`: short-lived (15m) cookie; `HttpOnly`, `secure`, `SameSite=None`, `domain=.shomaj.one`.
- `refreshToken`: longer-lived cookie; stored as `HttpOnly` cookie and rotated on usage; maintain a DB table for refresh token sessions per device for revocation.

Call `POST /auth/refresh` to rotate refresh tokens; the endpoint will set new cookies with the updated tokens.

For CSRF protection, require a CSRF header/CSRF token when `SameSite=None` cookies are used for cross-site requests.

```

If using the Cloud SQL Proxy locally:
```bash
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
./cloud-sql-proxy shomaj-817b0:asia-southeast1:YOUR_INSTANCE
```

## Custom Domain: api.shomaj.one (Cloudflare DNS)

1) Create the domain mapping in Cloud Run:
```bash
gcloud run domain-mappings create \
  --service supershop-backend \
  --domain api.shomaj.one \
  --region asia-southeast1
```

2) Get the required DNS records to add in Cloudflare:
```bash
gcloud run domain-mappings describe \
  --domain api.shomaj.one \
  --region asia-southeast1 \
  --format="json(status.resourceRecords)" | jq
```
Add exactly those records in Cloudflare DNS for `api.shomaj.one`.
- Tip: Turn OFF the Cloudflare proxy (gray cloud) until the Google-managed cert shows Ready; you can enable it later (prefer Full (strict)).

3) Wait for certificate to provision, then verify:
```bash
gcloud run domain-mappings describe --domain api.shomaj.one --region asia-southeast1 \
  --format="value(status.conditions[?type=Ready].status)"

curl -i https://api.shomaj.one/api/v1/health
```

## Frontend (Vercel) Integration

- In Vercel Project Settings → Environment Variables:
  - `NEXT_PUBLIC_API_BASE_URL = https://api.shomaj.one`
  - `NEXT_PUBLIC_SENTRY_DSN` (optional; client-side Sentry DSN)
- Redeploy the frontend.
- CORS: backend currently accepts a single origin. Set the secret/env `CORS_ORIGIN` to your production frontend origin, e.g. `https://shomaj.one` or `https://<project>.vercel.app` and redeploy the API.

## Troubleshooting & Ops

Common checks:
```bash
# Logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=supershop-backend" --limit 50 \
  --format "table(timestamp,severity,textPayload)"

# Service config
gcloud run services describe supershop-backend --region asia-southeast1 \
  --format "json(spec.template.metadata.annotations,spec.template.spec.containers[0].env)" | jq
```

Notes:
- Do not use a Serverless VPC Access connector for DB — the Cloud SQL connector (Unix socket) is free and already configured via `--add-cloudsql-instances`.
- If you previously set a VPC connector, remove it from the service with `--clear-vpc-connector` and optionally delete the connector in Compute → VPC Access.
- If your DB password contains special characters, URL-encode them in `DATABASE_URL`.

## API

- Health: `/api/v1/health`
- Auth: `/api/v1/auth/*`
- Swagger: `/api/docs`

## Security

- Secrets in Secret Manager only; never bake into images.
- CORS limited to your frontend origin.
- Use principle of least privilege for the Cloud Run service account (Cloud SQL Client + Secret Accessor only).

## Cost Tips

- Avoid Serverless VPC Access unless necessary.
- Right-size Cloud Run CPU/memory; set min instances to 0 if cold starts are acceptable.
- Choose appropriate Cloud SQL tier.
<parameter name="filePath">/mnt/storage/Projects/supershop-backend/DEPLOYMENT.md