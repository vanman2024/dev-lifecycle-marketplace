# Deployment Troubleshooting Guide

Common deployment issues and solutions when using deployment-scripts skill.

## Authentication Issues

### Problem: "Not authenticated with platform"

```bash
✗ Not authenticated with Vercel
ℹ Run: vercel login
```

**Solutions:**

1. **Run platform login command:**
   ```bash
   # Vercel
   vercel login

   # Netlify
   netlify login

   # Fly.io
   flyctl auth login

   # AWS
   aws configure

   # Google Cloud
   gcloud auth login
   ```

2. **Verify authentication:**
   ```bash
   bash plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh <platform>
   ```

3. **Check token expiration:**
   ```bash
   # Vercel
   vercel whoami

   # Netlify
   netlify status
   ```

4. **For CI/CD environments:**
   ```yaml
   # Set tokens as environment variables
   env:
     VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
     NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
   ```

## Environment Variable Issues

### Problem: "Environment variable not set or empty"

```bash
✗ DATABASE_URL is not set or empty
```

**Solutions:**

1. **Check .env file exists:**
   ```bash
   ls -la .env.production
   ```

2. **Verify variable is set:**
   ```bash
   grep DATABASE_URL .env.production
   ```

3. **Load environment manually:**
   ```bash
   set -a
   source .env.production
   set +a
   echo $DATABASE_URL
   ```

4. **Check for typos:**
   ```bash
   # Common mistakes
   DATABASE_URL=postgresql://...  # Correct
   DATABASE_UR=postgresql://...   # Wrong (typo)
   DATABSE_URL=postgresql://...   # Wrong (typo)
   ```

5. **Validate environment file:**
   ```bash
   bash plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
   ```

### Problem: "Insecure value detected"

```bash
✗ API_KEY contains insecure value
```

**Solutions:**

1. **Generate secure secrets:**
   ```bash
   # Generate random secret
   openssl rand -base64 32

   # Generate UUID
   uuidgen
   ```

2. **Never use defaults:**
   ```bash
   # Bad
   API_KEY=password
   JWT_SECRET=secret

   # Good
   API_KEY=$(openssl rand -base64 32)
   JWT_SECRET=$(openssl rand -base64 64)
   ```

## Build Validation Issues

### Problem: "node_modules not found"

```bash
⚠ node_modules not found - run npm install
```

**Solutions:**

1. **Install dependencies:**
   ```bash
   npm install
   # or
   npm ci  # For production (uses package-lock.json)
   ```

2. **Check package.json exists:**
   ```bash
   ls package.json
   ```

3. **Clear and reinstall:**
   ```bash
   trash-put node_modules package-lock.json
   npm install
   ```

### Problem: "Security vulnerabilities detected"

```bash
⚠ Security vulnerabilities detected - run 'npm audit' for details
```

**Solutions:**

1. **Review vulnerabilities:**
   ```bash
   npm audit
   ```

2. **Fix automatically:**
   ```bash
   npm audit fix
   ```

3. **Fix with breaking changes:**
   ```bash
   npm audit fix --force
   ```

4. **Update specific package:**
   ```bash
   npm update <package-name>
   ```

### Problem: "Large files detected"

```bash
⚠ Large files detected (>10MB):
  - dist/bundle.js (15MB)
```

**Solutions:**

1. **Optimize build output:**
   ```bash
   # Enable production optimizations
   NODE_ENV=production npm run build
   ```

2. **Split large bundles:**
   ```javascript
   // webpack.config.js
   optimization: {
     splitChunks: {
       chunks: 'all'
     }
   }
   ```

3. **Add to .gitignore:**
   ```bash
   echo "dist/" >> .gitignore
   ```

4. **Use .dockerignore for Docker builds:**
   ```bash
   cp plugins/deployment/skills/deployment-scripts/templates/.dockerignore .
   ```

## Deployment Failures

### Problem: "Build failed on platform"

```bash
✗ Deployment failed with status: 1
```

**Solutions:**

1. **Test build locally:**
   ```bash
   npm run build
   ```

2. **Check build logs:**
   ```bash
   # Vercel
   vercel logs

   # Netlify
   netlify logs
   ```

3. **Verify Node.js version:**
   ```bash
   # Check local version
   node --version

   # Specify in package.json
   {
     "engines": {
       "node": "18.x"
     }
   }
   ```

4. **Check disk space:**
   ```bash
   df -h
   ```

### Problem: "Deployment timeout"

```bash
Error: Deployment timed out after 10 minutes
```

**Solutions:**

1. **Optimize build time:**
   ```bash
   # Use CI cache
   npm ci --prefer-offline
   ```

2. **Reduce build steps:**
   ```json
   // package.json
   {
     "scripts": {
       "build": "tsc && webpack --mode production"
     }
   }
   ```

3. **Increase platform timeout:**
   ```json
   // vercel.json
   {
     "builds": [{
       "maxDuration": 900  // 15 minutes
     }]
   }
   ```

### Problem: "Out of memory during build"

```bash
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
```

**Solutions:**

1. **Increase Node.js memory:**
   ```json
   // package.json
   {
     "scripts": {
       "build": "NODE_OPTIONS='--max-old-space-size=4096' npm run build"
     }
   }
   ```

2. **Optimize dependencies:**
   ```bash
   # Remove unused dependencies
   npm prune

   # Use production dependencies only
   npm ci --production
   ```

## Health Check Failures

### Problem: "Site is not reachable"

```bash
✗ Site is not reachable
```

**Solutions:**

1. **Wait for DNS propagation:**
   ```bash
   # Check DNS
   nslookup my-app.com

   # Wait 5-10 minutes for propagation
   ```

2. **Verify URL is correct:**
   ```bash
   # Get deployment URL
   vercel inspect --json | jq -r '.url'
   ```

3. **Check deployment status:**
   ```bash
   # Vercel
   vercel ls

   # Netlify
   netlify status
   ```

### Problem: "SSL certificate invalid"

```bash
⚠ Could not verify SSL certificate
```

**Solutions:**

1. **Wait for certificate provisioning:**
   ```bash
   # SSL certificates can take 5-10 minutes
   # Check status on platform dashboard
   ```

2. **Verify domain configuration:**
   ```bash
   # Check DNS records
   dig my-app.com

   # Ensure A/CNAME records point to platform
   ```

3. **Force SSL renewal:**
   ```bash
   # Contact platform support if certificate doesn't provision
   ```

### Problem: "Response time is slow"

```bash
⚠ Response time is slow (>3s)
```

**Solutions:**

1. **Check server performance:**
   ```bash
   # Profile application
   NODE_ENV=production node --prof app.js
   ```

2. **Optimize database queries:**
   ```javascript
   // Add indexes
   // Use query caching
   // Implement connection pooling
   ```

3. **Enable CDN:**
   ```json
   // vercel.json
   {
     "headers": [{
       "source": "/static/(.*)",
       "headers": [{
         "key": "Cache-Control",
         "value": "public, max-age=31536000, immutable"
       }]
     }]
   }
   ```

## Rollback Issues

### Problem: "Cannot find previous deployment"

```bash
Error: No previous deployment found
```

**Solutions:**

1. **List recent deployments:**
   ```bash
   # Vercel
   vercel ls

   # Netlify
   netlify sites:list

   # Fly.io
   flyctl releases
   ```

2. **Manual rollback via dashboard:**
   - Vercel: Dashboard > Deployments > Promote to Production
   - Netlify: Dashboard > Deploys > Publish deploy
   - Fly.io: `flyctl releases rollback`

### Problem: "Rollback failed"

```bash
✗ Rollback failed
```

**Solutions:**

1. **Check deployment ID:**
   ```bash
   # Ensure deployment ID is valid
   vercel inspect <deployment-id>
   ```

2. **Redeploy last known good version:**
   ```bash
   git checkout <last-good-commit>
   bash plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
     --platform vercel --env production
   ```

## Docker Deployment Issues

### Problem: "Docker build fails"

```bash
Error: failed to solve with frontend dockerfile.v0
```

**Solutions:**

1. **Check Dockerfile syntax:**
   ```bash
   docker build --no-cache .
   ```

2. **Verify base image:**
   ```dockerfile
   # Use specific versions
   FROM node:18-alpine  # Good
   FROM node:latest     # Bad (unpredictable)
   ```

3. **Check file paths:**
   ```dockerfile
   # Ensure files exist
   COPY package.json ./  # Verify package.json exists
   ```

### Problem: "Container exits immediately"

```bash
docker: Error response from daemon: Container exited
```

**Solutions:**

1. **Check logs:**
   ```bash
   docker logs <container-id>
   ```

2. **Run interactively:**
   ```bash
   docker run -it --entrypoint sh my-app:latest
   ```

3. **Verify entrypoint:**
   ```dockerfile
   # Ensure command is correct
   CMD ["node", "dist/index.js"]  # Check path exists
   ```

### Problem: "Health check failing"

```bash
Health check failed: unhealthy
```

**Solutions:**

1. **Test health endpoint:**
   ```bash
   docker run -p 8080:8080 my-app:latest
   curl http://localhost:8080/health
   ```

2. **Update health check:**
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
     CMD curl -f http://localhost:8080/health || exit 1
   ```

## Platform-Specific Issues

### Vercel

**Problem: "Function size too large"**

```bash
Error: Function size exceeds 50MB limit
```

**Solution:**
```json
// vercel.json
{
  "functions": {
    "api/**/*.js": {
      "includeFiles": "!node_modules/**"
    }
  }
}
```

### Netlify

**Problem: "Build command not found"**

```bash
Error: Command not found: npm run build
```

**Solution:**
```toml
# netlify.toml
[build]
  command = "npm install && npm run build"
  publish = "dist"
```

### Fly.io

**Problem: "App not responding"**

```bash
Error: no response from app
```

**Solution:**
```bash
# Check app status
flyctl status

# Restart app
flyctl apps restart

# Check logs
flyctl logs
```

## Getting Help

### Collect Diagnostic Information

```bash
#!/usr/bin/env bash
# diagnostics.sh

echo "=== System Info ==="
node --version
npm --version
docker --version

echo "=== Platform Auth ==="
bash plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel

echo "=== Environment ==="
bash plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production

echo "=== Build ==="
bash plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

echo "=== Deployment Status ==="
vercel ls

echo "=== Recent Logs ==="
vercel logs --limit 50
```

### Support Resources

- Vercel: https://vercel.com/support
- Netlify: https://www.netlify.com/support/
- Fly.io: https://community.fly.io/
- AWS: https://aws.amazon.com/support/
- Google Cloud: https://cloud.google.com/support

## Prevention Best Practices

1. **Always validate before deploying:**
   ```bash
   bash plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
   bash plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .
   ```

2. **Test locally first:**
   ```bash
   npm run build
   npm start
   ```

3. **Use staging environment:**
   ```bash
   # Deploy to staging first
   bash scripts/deploy-env.sh staging
   # Verify staging works
   # Then deploy to production
   ```

4. **Monitor deployments:**
   ```bash
   # Always run health check after deployment
   bash plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.com
   ```

5. **Keep rollback ready:**
   ```bash
   # Know how to rollback before deploying
   bash plugins/deployment/skills/deployment-scripts/scripts/rollback-deployment.sh vercel
   ```
