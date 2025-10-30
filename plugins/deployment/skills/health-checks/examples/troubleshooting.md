# Troubleshooting Guide

This guide helps diagnose and resolve common health check failures and issues.

## Table of Contents

1. [HTTP Health Check Failures](#http-health-check-failures)
2. [API Health Check Failures](#api-health-check-failures)
3. [MCP Server Health Check Failures](#mcp-server-health-check-failures)
4. [SSL/TLS Validation Failures](#ssltls-validation-failures)
5. [Performance Test Failures](#performance-test-failures)
6. [Network and Connectivity Issues](#network-and-connectivity-issues)
7. [Debugging Techniques](#debugging-techniques)

---

## HTTP Health Check Failures

### Problem: Connection Refused

**Symptoms:**
```
✗ Cannot connect to https://example.com
curl: (7) Failed to connect to example.com port 443: Connection refused
```

**Possible Causes:**
1. Service is not running
2. Firewall blocking the port
3. Service listening on wrong port or interface
4. DNS resolution issues

**Debugging Steps:**

```bash
# 1. Check if service is running
systemctl status your-service

# 2. Check if port is listening
sudo netstat -tlnp | grep :443
# or
sudo ss -tlnp | grep :443

# 3. Test connectivity
telnet example.com 443
# or
nc -zv example.com 443

# 4. Check DNS resolution
nslookup example.com
dig example.com

# 5. Check firewall rules
sudo iptables -L -n
sudo ufw status

# 6. Test with curl directly
curl -v https://example.com
```

**Solutions:**

```bash
# Start service if not running
sudo systemctl start your-service

# Open firewall port
sudo ufw allow 443/tcp

# Check application logs
sudo journalctl -u your-service -n 100 --no-pager

# Verify correct binding
# In application config, ensure it binds to 0.0.0.0:443 not 127.0.0.1:443
```

---

### Problem: Timeout Errors

**Symptoms:**
```
✗ Request timed out after 10s
curl: (28) Operation timed out after 10000 milliseconds
```

**Possible Causes:**
1. Service is overloaded
2. Network latency
3. Application deadlock
4. Database query hanging

**Debugging Steps:**

```bash
# 1. Check service health
bash scripts/http-health-check.sh https://example.com 200 30000

# 2. Increase timeout temporarily
TIMEOUT=60 bash scripts/http-health-check.sh https://example.com

# 3. Check application metrics
curl https://example.com/metrics

# 4. Monitor network latency
ping example.com
traceroute example.com
mtr example.com

# 5. Check server load
ssh server 'top -b -n 1 | head -20'
ssh server 'uptime'
```

**Solutions:**

```bash
# Scale application (more instances)
# Review application logs for slow queries
sudo journalctl -u your-service | grep "slow query"

# Optimize database queries
# Add caching layer
# Increase application timeout settings
```

---

### Problem: Wrong HTTP Status Code

**Symptoms:**
```
✗ Status code: 503 (expected: 200)
Service Unavailable
```

**Debugging Steps:**

```bash
# 1. Get detailed response
curl -i https://example.com

# 2. Check specific endpoint
curl -v https://example.com/health

# 3. View response body
curl -s https://example.com | head -c 1000

# 4. Check if it's a temporary issue
for i in {1..5}; do
    echo "Attempt $i:"
    curl -s -o /dev/null -w "Status: %{http_code}\n" https://example.com
    sleep 2
done
```

**Common Status Codes:**

- **502 Bad Gateway**: Upstream service is down
  - Check backend service health
  - Verify proxy configuration

- **503 Service Unavailable**: Service is temporarily unavailable
  - Check if service is starting up
  - Verify database connections
  - Check dependency services

- **504 Gateway Timeout**: Upstream service timed out
  - Increase proxy timeout
  - Optimize backend performance

---

## API Health Check Failures

### Problem: Authentication Failures

**Symptoms:**
```
✗ Status code: 401 (Expected 2xx)
Unauthorized
```

**Debugging Steps:**

```bash
# 1. Verify token format
echo "Token: Bearer $API_TOKEN"

# 2. Test authentication manually
curl -v -H "Authorization: Bearer $API_TOKEN" \
    https://api.example.com/health

# 3. Check token expiration
# Decode JWT token (if using JWT)
echo "$API_TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq '.'

# 4. Test with different auth methods
curl -v -H "X-API-Key: $API_KEY" https://api.example.com/health
curl -v -u username:password https://api.example.com/health
```

**Solutions:**

```bash
# Regenerate API token
# Verify token has correct permissions
# Check token is not expired
# Ensure Authorization header is properly formatted
```

---

### Problem: Invalid JSON Response

**Symptoms:**
```
✗ Invalid JSON response
parse error: Invalid numeric literal at line 1, column 10
```

**Debugging Steps:**

```bash
# 1. View raw response
curl -s https://api.example.com/health

# 2. Validate JSON manually
curl -s https://api.example.com/health | jq '.'

# 3. Check content type
curl -I https://api.example.com/health | grep -i content-type

# 4. Save response for analysis
curl -s https://api.example.com/health > response.txt
cat response.txt
```

**Solutions:**

- API might be returning HTML error page instead of JSON
- Check API logs for exceptions
- Verify API endpoint path is correct
- Ensure API is not in maintenance mode

---

### Problem: JSON Path Not Found

**Symptoms:**
```
Validating JSON path: .status
✗ JSON path not found: .status
```

**Debugging Steps:**

```bash
# 1. View entire JSON response
curl -s https://api.example.com/health | jq '.'

# 2. Test different JSON paths
curl -s https://api.example.com/health | jq '.status'
curl -s https://api.example.com/health | jq '.health'
curl -s https://api.example.com/health | jq '.state'

# 3. List all keys
curl -s https://api.example.com/health | jq 'keys'

# 4. Navigate nested structure
curl -s https://api.example.com/health | jq '.data.status'
```

**Solutions:**

```bash
# Correct the JSON path in health check
bash scripts/api-health-check.sh \
    https://api.example.com/health \
    "" \
    ".data.status" \
    "healthy"
```

---

## MCP Server Health Check Failures

### Problem: MCP Initialize Failed

**Symptoms:**
```
✗ Initialize error: Method not found
```

**Debugging Steps:**

```bash
# 1. Test basic connectivity
curl -v http://localhost:3000/mcp

# 2. Send manual initialize request
curl -X POST http://localhost:3000/mcp \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "test", "version": "1.0.0"}
        }
    }' | jq '.'

# 3. Check MCP server logs
journalctl -u mcp-server -n 50

# 4. Verify protocol version
curl -X POST http://localhost:3000/mcp \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","id":1,"method":"ping"}' | jq '.'
```

**Solutions:**

- Verify MCP server is running latest version
- Check MCP endpoint URL is correct
- Ensure server supports MCP protocol version 2024-11-05
- Review server startup logs for errors

---

### Problem: No Tools Available

**Symptoms:**
```
⚠ Found 0 available tools
```

**Debugging Steps:**

```bash
# 1. List tools manually
curl -X POST http://localhost:3000/mcp \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/list",
        "params": {}
    }' | jq '.result.tools'

# 2. Check server configuration
cat /etc/mcp-server/config.json

# 3. Verify tools are registered
# Check server startup logs
```

**Solutions:**

- Tools may not be registered in server configuration
- Server may need restart after adding tools
- Check tool registration code

---

## SSL/TLS Validation Failures

### Problem: Certificate Expired

**Symptoms:**
```
✗ Certificate has EXPIRED (15 days ago)
```

**Solutions:**

```bash
# 1. Renew certificate (Let's Encrypt example)
sudo certbot renew --force-renewal

# 2. Verify renewal
sudo certbot certificates

# 3. Restart web server
sudo systemctl restart nginx  # or apache2

# 4. Verify new certificate
openssl s_client -connect example.com:443 -servername example.com \
    </dev/null 2>/dev/null | openssl x509 -noout -dates
```

---

### Problem: Certificate Expiring Soon

**Symptoms:**
```
⚠ Certificate expires soon (15 days remaining, minimum: 30)
```

**Solutions:**

```bash
# Set up auto-renewal (Let's Encrypt)
sudo certbot renew --dry-run

# Add cron job for automatic renewal
echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'" | sudo crontab -

# Set up monitoring alerts for certificate expiration
```

---

### Problem: Certificate Chain Invalid

**Symptoms:**
```
⚠ Certificate chain verification: Verify return code: 21 (unable to verify the first certificate)
```

**Debugging Steps:**

```bash
# 1. View certificate chain
openssl s_client -connect example.com:443 -showcerts

# 2. Check intermediate certificates
curl https://example.com 2>&1 | grep -i certificate

# 3. Verify chain file
openssl verify -CAfile chain.pem cert.pem
```

**Solutions:**

- Include intermediate certificates in certificate bundle
- Ensure certificate chain is in correct order
- Download missing intermediate certificates from CA

---

## Performance Test Failures

### Problem: Low Success Rate

**Symptoms:**
```
✗ Success rate: 87.5% (threshold: 95.0%)
HTTP Status Codes:
  200: 875
  503: 125
```

**Debugging Steps:**

```bash
# 1. Reduce concurrent requests to identify threshold
bash scripts/performance-tester.sh https://example.com 10 100
bash scripts/performance-tester.sh https://example.com 25 250
bash scripts/performance-tester.sh https://example.com 50 500

# 2. Check application metrics during test
# In separate terminal:
watch -n 1 'curl -s https://example.com/metrics | grep -E "requests|errors|latency"'

# 3. Monitor server resources
ssh server 'vmstat 1 10'
ssh server 'iostat -x 1 10'

# 4. Check application logs during load
ssh server 'tail -f /var/log/application.log'
```

**Solutions:**

- Scale application horizontally (more instances)
- Increase application resources (CPU, RAM)
- Optimize database queries
- Add caching layer
- Configure rate limiting properly
- Review connection pool settings

---

### Problem: High Response Time

**Symptoms:**
```
✗ Average response time: 4532ms (threshold: 3000ms)
95th percentile (p95): 8234ms (threshold: 5000ms)
```

**Debugging Steps:**

```bash
# 1. Profile slow requests
curl -w "\nTime Total: %{time_total}s\nTime Connect: %{time_connect}s\nTime Start Transfer: %{time_starttransfer}s\n" \
    -o /dev/null -s https://example.com

# 2. Identify bottleneck
# Check application profiling
# Review database slow query log
# Monitor external API calls

# 3. Test from different locations
# Network latency may be the issue
```

**Solutions:**

- Add CDN for static assets
- Optimize database queries (add indexes)
- Implement caching strategy
- Reduce external API calls
- Enable compression (gzip)
- Optimize application code

---

## Network and Connectivity Issues

### DNS Resolution Failures

```bash
# 1. Check DNS
nslookup example.com
dig example.com

# 2. Try different DNS servers
nslookup example.com 8.8.8.8
nslookup example.com 1.1.1.1

# 3. Flush DNS cache
sudo systemd-resolve --flush-caches

# 4. Check /etc/hosts
cat /etc/hosts | grep example.com
```

---

### Firewall Blocking Requests

```bash
# 1. Check firewall status
sudo ufw status verbose
sudo iptables -L -n -v

# 2. Test from different source
# If works from one machine but not another, likely firewall

# 3. Temporarily disable firewall (testing only!)
sudo ufw disable
# Run health check
# Re-enable
sudo ufw enable

# 4. Add firewall rules
sudo ufw allow from YOUR_IP to any port 443
```

---

## Debugging Techniques

### Enable Verbose Output

All scripts support verbose debugging:

```bash
# Run with bash -x for detailed execution trace
bash -x scripts/http-health-check.sh https://example.com

# Enable curl verbose output
curl -v https://example.com

# Set environment variables for debugging
export DEBUG=true
export VERBOSE=true
bash scripts/api-health-check.sh https://api.example.com/health
```

---

### Capture Network Traffic

```bash
# Capture HTTP traffic with tcpdump
sudo tcpdump -i any -s 0 -A 'tcp port 80 or tcp port 443' -w health-check.pcap

# Analyze with Wireshark
wireshark health-check.pcap

# Use mitmproxy for HTTPS inspection
mitmproxy --mode reverse:https://example.com --listen-port 8080
```

---

### Common Environment Variables

```bash
# Increase timeouts
export TIMEOUT=60
export RETRIES=10
export RETRY_DELAY=5

# Custom output directory
export OUTPUT_DIR=/tmp/debug-health-checks

# Enable debugging
export DEBUG=1
export VERBOSE=1

# Override defaults
export THRESHOLD_SUCCESS_RATE=90.0
export THRESHOLD_AVG_TIME=5000
export THRESHOLD_P95_TIME=10000
```

---

### Quick Diagnostic Script

```bash
#!/bin/bash
# diagnose-health-check.sh

URL="$1"

echo "=== Health Check Diagnostics ==="
echo "URL: $URL"
echo ""

echo "1. DNS Resolution:"
host "$URL" 2>&1

echo -e "\n2. Ping Test:"
ping -c 3 "$URL" 2>&1

echo -e "\n3. Port Connectivity:"
nc -zv "$URL" 443 2>&1

echo -e "\n4. HTTP Response:"
curl -I "$URL" 2>&1

echo -e "\n5. SSL Certificate:"
echo | openssl s_client -connect "$URL":443 -servername "$URL" 2>/dev/null | \
    openssl x509 -noout -dates 2>&1

echo -e "\n6. Traceroute:"
traceroute -m 10 "$URL" 2>&1
```

**Usage:**
```bash
bash diagnose-health-check.sh example.com
```

---

## Getting Help

If issues persist after troubleshooting:

1. **Collect logs:**
   ```bash
   # Application logs
   sudo journalctl -u your-service -n 500 > app-logs.txt

   # Health check logs
   ls -lah /var/log/health-checks/

   # System logs
   dmesg > system-logs.txt
   ```

2. **Document the issue:**
   - Exact error message
   - Steps to reproduce
   - Environment details (OS, versions)
   - Recent changes

3. **Create minimal reproducible example:**
   ```bash
   # Simplest possible command that fails
   curl -v https://example.com
   ```

4. **Check common solutions:**
   - Service status
   - Network connectivity
   - Firewall rules
   - Certificate validity
   - Resource availability

---

This troubleshooting guide covers the most common health check failures and their solutions.
