# Supershop Backend Deployment Guide

This guide provides step-by-step instructions for building and deploying the Supershop Backend application to Google Cloud Run.

## Prerequisites

1. **Google Cloud SDK**: Install and initialize `gcloud`
   ```bash
   # Install gcloud SDK
   # Authenticate
   gcloud auth login
   # Set project
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Docker**: Ensure Docker is installed and running

3. **Node.js**: For local development (Node 20+)

4. **Cloud SQL Instance**: Ensure your PostgreSQL instance is running in Cloud SQL

5. **Secret Manager**: Store sensitive data like JWT_SECRET in Secret Manager

## Project Structure

- `Dockerfile`: Multi-stage build for production
- `skaffold.yaml`: Configuration for building and deploying
- `.env.production`: Production environment variables
- `prisma/`: Database schema and migrations

## Local Development Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
Copy and configure environment files:
```bash
cp .env.example .env  # For local development
# Edit .env with local database URL
```

### 3. Database Setup
For local development with Docker PostgreSQL:
```bash
docker run -d --name supershop-local-db \
  -e POSTGRES_PASSWORD=MUJAHIDrumel123@123 \
  -e POSTGRES_USER=supershop_user \
  -e POSTGRES_DB=supershop \
  -p 5432:5432 \
  postgres:15-alpine
```

Apply migrations:
```bash
npx prisma migrate deploy
```

### 4. Run Locally
```bash
# Development mode
npm run start:dev

# Production build
npm run build
npm run start:prod
```

## Building the Application

### Docker Build
```bash
# Build the Docker image
docker build -t gcr.io/YOUR_PROJECT_ID/supershop-backend .

# Configure Docker for GCR
gcloud auth configure-docker

# Push to Google Container Registry
docker push gcr.io/YOUR_PROJECT_ID/supershop-backend
```

### Using Skaffold (Alternative)
```bash
# Build and push
skaffold build

# Or build and deploy
skaffold run
```

## Deploying to Cloud Run

### 1. Prepare Secrets
Ensure JWT_SECRET is stored in Secret Manager:
```bash
# Create secret if not exists
echo -n "your-jwt-secret-here" | gcloud secrets create JWT_SECRET --data-file=-

# Or update existing
echo -n "your-jwt-secret-here" | gcloud secrets versions add JWT_SECRET --data-file=-
```

### 2. Deploy to Cloud Run
```bash
gcloud run deploy supershop-backend \
  --image gcr.io/YOUR_PROJECT_ID/supershop-backend \
  --add-cloudsql-instances YOUR_PROJECT_ID:asia-southeast1:YOUR_INSTANCE_NAME \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-secrets JWT_SECRET=JWT_SECRET:latest
```

### 3. Verify Deployment
```bash
# Check service status
gcloud run services describe supershop-backend --region asia-southeast1

# Get service URL
gcloud run services describe supershop-backend --region asia-southeast1 --format="value(status.url)"
```

## Environment Variables

### Production (.env.production)
```env
# Application
NODE_ENV=production
PORT=8080
API_VERSION=v1
API_PREFIX=api

# Database
DATABASE_URL=postgresql://supershop_user:MUJAHIDrumel123%40123@/supershop?host=/cloudsql/YOUR_PROJECT_ID:asia-southeast1:YOUR_INSTANCE&schema=public

# JWT
JWT_SECRET=01/VSuHWLI0U0q8PN/oCjddo2Va28SUfm90/yiKBfIU=
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=zVxZ+sBIg23YO2yi4yHoo1rhzp56N6lK4AkIL9y4yEQ=
JWT_REFRESH_EXPIRES_IN=7d

# Throttling (Rate Limiting)
THROTTLE_TTL=60000
THROTTLE_LIMIT=10

# CORS
CORS_ORIGIN=http://localhost:3000

# Deployment
FRONTEND_URL=http://localhost:3000
```

### Cloud Run Environment Variables
- `JWT_SECRET`: Injected from Secret Manager
- `DATABASE_URL`: Loaded from .env.production in container
- `PORT`: Automatically set by Cloud Run
- `NODE_ENV`: Set to production in Dockerfile

## Database Management

### Prisma Commands
```bash
# Generate client
npx prisma generate

# Create migration
npx prisma migrate dev --name description

# Apply migrations
npx prisma migrate deploy

# Reset database (dangerous)
npx prisma migrate reset

# Open Prisma Studio
npx prisma studio
```

### Cloud SQL Proxy (for local development)
```bash
# Download proxy
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# Run proxy
./cloud-sql-proxy YOUR_PROJECT_ID:asia-southeast1:YOUR_INSTANCE
```

## Troubleshooting

### Build Issues
- **OpenSSL warning**: Ensure `openssl` is installed in Docker stages
- **Prisma client not found**: Run `npx prisma generate` in build
- **Build context too large**: Add `.dockerignore` file

### Deployment Issues
- **Container fails to start**: Check logs in Cloud Console
- **Database connection fails**: Verify Cloud SQL instance and permissions
- **JWT secret missing**: Ensure secret exists in Secret Manager
- **Port not listening**: Ensure app binds to `0.0.0.0:$PORT`

### Common Commands
```bash
# View Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=supershop-backend" --limit=50

# Check service status
gcloud run services describe supershop-backend --region asia-southeast1

# Update service
gcloud run deploy supershop-backend --image gcr.io/YOUR_PROJECT_ID/supershop-backend:latest

# Delete service
gcloud run services delete supershop-backend --region asia-southeast1
```

## API Endpoints

Once deployed, the API will be available at:
- Base URL: `https://YOUR_SERVICE_URL`
- Health Check: `https://YOUR_SERVICE_URL/api/v1/health`
- API Docs: `https://YOUR_SERVICE_URL/api/docs`
- Auth endpoints: `https://YOUR_SERVICE_URL/api/v1/auth/*`

## Security Considerations

1. **Secrets Management**: Use Secret Manager for sensitive data
2. **Database Access**: Restrict Cloud SQL to specific services
3. **CORS**: Configure appropriate origins
4. **Rate Limiting**: Adjust throttle settings as needed
5. **HTTPS**: Cloud Run provides automatic HTTPS

## Monitoring

- **Cloud Run Metrics**: View in Google Cloud Console
- **Logs**: Use Cloud Logging for application logs
- **Health Checks**: Implement proper health endpoints
- **Database Monitoring**: Monitor Cloud SQL performance

## Cost Optimization

- **Instance Type**: Use appropriate CPU/memory allocation
- **Scaling**: Configure min/max instances based on load
- **Cold Starts**: Keep minimum instances > 0 for faster response
- **Database**: Choose appropriate Cloud SQL tier

---

**Note**: Replace `YOUR_PROJECT_ID` and `YOUR_INSTANCE` with actual values. Ensure all secrets and configurations are properly set before deployment.</content>
<parameter name="filePath">/mnt/storage/Projects/supershop-backend/DEPLOYMENT.md