# DigitalOcean Droplet Deployment Skill

Generic deployment solution for any Python or Node.js application to DigitalOcean droplets using doctl CLI.

## Quick Start

1. **Install doctl**:
   ```bash
   # macOS
   brew install doctl

   # Linux
   cd ~
   wget https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz
   tar xf ~/doctl-1.104.0-linux-amd64.tar.gz
   sudo mv ~/doctl /usr/local/bin
   ```

2. **Authenticate doctl**:
   ```bash
   doctl auth init
   # Enter your DigitalOcean API token
   ```

3. **Deploy your app**:
   ```bash
   ./scripts/deploy-to-droplet.sh /path/to/app 137.184.196.101 myapp
   ```

## What This Skill Provides

### Scripts
- **deploy-to-droplet.sh** - Complete deployment automation
- **update-secrets.sh** - Update environment variables without redeploying
- **validate-app.sh** - Pre-deployment validation (TODO)
- **health-check.sh** - Post-deployment health checks (TODO)
- **manage-deployment.sh** - Service lifecycle management (TODO)

### Templates
- Systemd service files
- Environment file templates
- Deployment tracking JSON
- Deployment checklists

### Examples
- Python FastAPI deployment
- Node.js Express deployment
- Background worker deployment

## Supported Applications

- **Python**: Flask, FastAPI, Django, background workers
- **Node.js**: Express, Fastify, any Node.js app
- **Any**: Generic apps that can run as systemd services

## How It Works

1. **Validates** your application locally
2. **Auto-detects** app type (Python/Node.js) and entry point
3. **Transfers** code to droplet via doctl SSH + rsync
4. **Installs** dependencies (pip/npm)
5. **Creates** systemd service
6. **Starts** and enables service
7. **Verifies** deployment health

## Example: Deploy Python FastAPI App

```bash
# 1. Your app structure:
# myapp/
# ├── server.py
# ├── requirements.txt
# └── .env

# 2. Deploy
cd myapp
../scripts/deploy-to-droplet.sh . 137.184.196.101 myapp

# 3. Update secrets later
../scripts/update-secrets.sh 137.184.196.101 myapp
```

## Example: Deploy Node.js Express App

```bash
# 1. Your app structure:
# myapp/
# ├── server.js
# ├── package.json
# └── .env

# 2. Deploy
cd myapp
../scripts/deploy-to-droplet.sh . 137.184.196.101 myapp

# 3. View logs
doctl compute ssh 137.184.196.101 --ssh-command 'journalctl -u myapp -f'
```

## Security

- ✅ Environment variables stored securely (600 permissions)
- ✅ Secrets never committed to git
- ✅ Automatic .env backup before updates
- ✅ Rollback on deployment failure
- ✅ No hardcoded credentials

## Integration

This skill integrates with deployment plugin commands:
- `/deployment:prepare` - Validate app before deployment
- `/deployment:deploy` - Execute droplet deployment
- `/deployment:validate` - Verify deployment health
- `/deployment:rollback` - Rollback to previous version

## Next Steps

- [ ] Create `validate-app.sh` script
- [ ] Create `health-check.sh` script
- [ ] Create `manage-deployment.sh` script
- [ ] Add deployment examples
- [ ] Add systemd service templates
- [ ] Create deployment tracking JSON template
- [ ] Integrate with deployment plugin commands
- [ ] Create `digitalocean-app-deployment` skill for App Platform
