# Docker Deployment Patterns

This example demonstrates containerized deployment workflows using Docker and the deployment-scripts skill.

## Overview

Deploy applications using Docker containers to various platforms:
- Docker Hub / Container Registry
- Fly.io
- AWS ECS
- Google Cloud Run
- DigitalOcean App Platform

## Directory Structure

```
project/
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── docker-compose.prod.yml
└── scripts/
    ├── docker-build.sh
    └── docker-deploy.sh
```

## Using the Docker Templates

### 1. Copy and Customize Dockerfile

For Node.js applications:

```bash
# Copy Node.js template
cp plugins/deployment/skills/deployment-scripts/templates/Dockerfile.node Dockerfile

# Customize for your application
nano Dockerfile
```

For Python applications:

```bash
# Copy Python template
cp plugins/deployment/skills/deployment-scripts/templates/Dockerfile.python Dockerfile

# Customize for your application
nano Dockerfile
```

### 2. Copy .dockerignore

```bash
cp plugins/deployment/skills/deployment-scripts/templates/.dockerignore .
```

## Local Docker Deployment

### Build Image

```bash
# Build image
docker build -t my-app:latest .

# Build with build arguments
docker build \
  --build-arg NODE_ENV=production \
  --build-arg PORT=8080 \
  -t my-app:latest .
```

### Run Container Locally

```bash
# Run with environment file
docker run -d \
  --name my-app \
  --env-file .env.production \
  -p 8080:8080 \
  my-app:latest

# View logs
docker logs -f my-app

# Health check
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh http://localhost:8080
```

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      NODE_ENV: production
      PORT: 8080
    env_file:
      - .env.production
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  postgres-data:
  redis-data:
```

Run with Docker Compose:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Deploying to Fly.io

### 1. Initialize Fly.io

```bash
# Check authentication
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh fly

# Copy fly.toml template
cp plugins/deployment/skills/deployment-scripts/templates/fly.toml .

# Customize fly.toml
nano fly.toml
```

### 2. Deploy to Fly.io

```bash
# Build and deploy
flyctl deploy

# Or use deployment helper
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
  --platform fly \
  --env production
```

### 3. Verify Deployment

```bash
# Get deployment URL
FLY_URL=$(flyctl status --json | jq -r '.Hostname')

# Health check
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
  "https://${FLY_URL}"
```

## Deploying to Docker Registry

### Push to Docker Hub

```bash
#!/usr/bin/env bash
# docker-push.sh

set -euo pipefail

REGISTRY="docker.io"
USERNAME="myusername"
IMAGE="my-app"
TAG="${1:-latest}"

# Build multi-platform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "${REGISTRY}/${USERNAME}/${IMAGE}:${TAG}" \
  -t "${REGISTRY}/${USERNAME}/${IMAGE}:latest" \
  --push \
  .

echo "✓ Image pushed: ${REGISTRY}/${USERNAME}/${IMAGE}:${TAG}"
```

### Push to GitHub Container Registry

```bash
#!/usr/bin/env bash
# docker-push-ghcr.sh

set -euo pipefail

REGISTRY="ghcr.io"
OWNER="myorganization"
IMAGE="my-app"
TAG="${1:-latest}"

# Login to GitHub Container Registry
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin

# Build and push
docker build -t "${REGISTRY}/${OWNER}/${IMAGE}:${TAG}" .
docker push "${REGISTRY}/${OWNER}/${IMAGE}:${TAG}"

echo "✓ Image pushed: ${REGISTRY}/${OWNER}/${IMAGE}:${TAG}"
```

## Deploying to AWS ECS

### 1. Create ECS Task Definition

```json
{
  "family": "my-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "my-app",
      "image": "myregistry/my-app:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:db-url"
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### 2. Deploy to ECS

```bash
#!/usr/bin/env bash
# deploy-ecs.sh

set -euo pipefail

CLUSTER="my-cluster"
SERVICE="my-app"
TASK_DEFINITION="my-app"

# Check AWS authentication
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh aws

# Build and push image
docker build -t "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest" .

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Push image
docker push "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"

# Update ECS service
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --force-new-deployment

echo "✓ Deployment initiated to ECS"
```

## Deploying to Google Cloud Run

```bash
#!/usr/bin/env bash
# deploy-cloudrun.sh

set -euo pipefail

PROJECT="my-project"
REGION="us-central1"
SERVICE="my-app"

# Check authentication
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh gcloud

# Build and submit
gcloud builds submit --tag gcr.io/$PROJECT/$SERVICE

# Deploy to Cloud Run
gcloud run deploy $SERVICE \
  --image gcr.io/$PROJECT/$SERVICE \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE \
  --platform managed \
  --region $REGION \
  --format 'value(status.url)')

echo "✓ Deployed to: $SERVICE_URL"

# Health check
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh "$SERVICE_URL"
```

## Multi-Stage Build Optimization

Example optimized Dockerfile with build cache:

```dockerfile
# syntax=docker/dockerfile:1

# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# Install dependencies (cached)
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Build application
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install dumb-init
RUN apk add --no-cache dumb-init

# Create user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

USER nodejs

EXPOSE 8080

ENV NODE_ENV=production PORT=8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

## Docker Security Best Practices

### Scan for Vulnerabilities

```bash
# Scan image with Docker Scout
docker scout cve my-app:latest

# Scan with Trivy
trivy image my-app:latest
```

### Use Non-Root User

Always included in our templates:

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Switch to non-root
USER nodejs
```

### Minimize Image Size

```bash
# Use alpine base images
FROM node:18-alpine

# Multi-stage builds
FROM builder AS production

# Remove dev dependencies
RUN npm prune --production
```

## Monitoring Docker Deployments

### Health Checks

All our Docker templates include health checks:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### Logging

Configure logging drivers:

```yaml
# docker-compose.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Troubleshooting

### Image Build Fails

```bash
# Build with detailed output
docker build --progress=plain -t my-app:latest .

# Check build cache
docker builder prune
```

### Container Won't Start

```bash
# Check logs
docker logs my-app

# Run interactively
docker run -it --entrypoint sh my-app:latest
```

### Health Check Failing

```bash
# Test health endpoint locally
docker run -p 8080:8080 my-app:latest
curl http://localhost:8080/health
```

## Next Steps

- Implement container orchestration with Kubernetes
- Set up automated image scanning in CI/CD
- Configure container monitoring and logging
- Implement blue-green deployments
