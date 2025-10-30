# Monitoring Setup Examples

This guide demonstrates how to set up continuous monitoring with health checks, metrics collection, and alerting.

## Table of Contents

1. [Prometheus Integration](#prometheus-integration)
2. [Grafana Dashboards](#grafana-dashboards)
3. [Health Check Exporter](#health-check-exporter)
4. [Alertmanager Configuration](#alertmanager-configuration)
5. [Continuous Monitoring Scripts](#continuous-monitoring-scripts)
6. [Log Aggregation](#log-aggregation)

---

## Prometheus Integration

### Health Check Metrics Exporter

Create a script that exports health check metrics in Prometheus format:

```bash
#!/bin/bash
# health-check-prometheus-exporter.sh

set -euo pipefail

METRICS_FILE="${METRICS_FILE:-/var/metrics/health-checks.prom}"
METRICS_PORT="${METRICS_PORT:-9090}"

# Function to export metric
export_metric() {
    local metric_name="$1"
    local value="$2"
    local labels="$3"

    echo "${metric_name}{${labels}} ${value}" >> "$METRICS_FILE"
}

# Function to run health check and export metrics
check_and_export() {
    local endpoint_name="$1"
    local endpoint_url="$2"
    local check_type="$3"

    local start_time=$(date +%s%N)
    local status=0
    local response_time=0
    local http_status=0

    case "$check_type" in
        http)
            if bash scripts/http-health-check.sh "$endpoint_url" 200 5000 2>&1; then
                status=1
            fi
            ;;
        api)
            if bash scripts/api-health-check.sh "$endpoint_url/health" 2>&1; then
                status=1
            fi
            ;;
        mcp)
            if bash scripts/mcp-server-health-check.sh "$endpoint_url" 2>&1; then
                status=1
            fi
            ;;
    esac

    local end_time=$(date +%s%N)
    response_time=$(( (end_time - start_time) / 1000000 ))

    # Export metrics
    local labels="endpoint=\"${endpoint_name}\",type=\"${check_type}\",environment=\"${ENVIRONMENT:-production}\""

    export_metric "health_check_success" "$status" "$labels"
    export_metric "health_check_response_time_ms" "$response_time" "$labels"
    export_metric "health_check_last_run_timestamp" "$(date +%s)" "$labels"
}

# Clear old metrics
> "$METRICS_FILE"

# Add metadata
cat >> "$METRICS_FILE" <<EOF
# HELP health_check_success Whether the health check succeeded (1) or failed (0)
# TYPE health_check_success gauge
# HELP health_check_response_time_ms Response time in milliseconds
# TYPE health_check_response_time_ms gauge
# HELP health_check_last_run_timestamp Unix timestamp of last health check
# TYPE health_check_last_run_timestamp gauge
EOF

# Run health checks and export metrics
check_and_export "frontend" "https://example.com" "http"
check_and_export "api" "https://api.example.com" "api"
check_and_export "mcp-server" "https://mcp.example.com" "mcp"

# Serve metrics via HTTP
if command -v python3 &> /dev/null; then
    cd "$(dirname "$METRICS_FILE")"
    python3 -m http.server "$METRICS_PORT" &
    echo "Metrics available at: http://localhost:${METRICS_PORT}/$(basename "$METRICS_FILE")"
fi
```

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 30s

scrape_configs:
  # Health check exporter
  - job_name: 'health-checks'
    static_configs:
      - targets: ['localhost:9090']
    metrics_path: '/health-checks.prom'

  # Application metrics
  - job_name: 'application'
    static_configs:
      - targets:
          - 'app1.example.com:9100'
          - 'app2.example.com:9100'

# Alert rules
rule_files:
  - '/etc/prometheus/rules/*.yml'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']
```

### Prometheus Alert Rules

```yaml
# /etc/prometheus/rules/health-checks.yml
groups:
  - name: health_check_alerts
    interval: 30s
    rules:
      - alert: HealthCheckFailed
        expr: health_check_success == 0
        for: 2m
        labels:
          severity: critical
          category: availability
        annotations:
          summary: "Health check failed for {{ $labels.endpoint }}"
          description: "The health check for {{ $labels.endpoint }} has been failing for more than 2 minutes."

      - alert: HighResponseTime
        expr: health_check_response_time_ms > 5000
        for: 5m
        labels:
          severity: warning
          category: performance
        annotations:
          summary: "High response time for {{ $labels.endpoint }}"
          description: "Response time for {{ $labels.endpoint }} is {{ $value }}ms (threshold: 5000ms)"

      - alert: HealthCheckStale
        expr: (time() - health_check_last_run_timestamp) > 300
        for: 1m
        labels:
          severity: warning
          category: monitoring
        annotations:
          summary: "Health check data is stale for {{ $labels.endpoint }}"
          description: "No health check data received for {{ $labels.endpoint }} in the last 5 minutes."
```

---

## Grafana Dashboards

### JSON Dashboard Configuration

See `templates/monitoring-dashboard.json` for the complete Grafana dashboard configuration.

### Import Dashboard

```bash
# import-grafana-dashboard.sh
#!/bin/bash

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_API_KEY="${GRAFANA_API_KEY}"
DASHBOARD_FILE="templates/monitoring-dashboard.json"

curl -X POST "${GRAFANA_URL}/api/dashboards/db" \
    -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
    -H "Content-Type: application/json" \
    -d @"$DASHBOARD_FILE"
```

---

## Health Check Exporter

### Systemd Service for Continuous Monitoring

```ini
# /etc/systemd/system/health-check-exporter.service
[Unit]
Description=Health Check Prometheus Exporter
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
WorkingDirectory=/opt/health-checks
ExecStart=/opt/health-checks/health-check-prometheus-exporter.sh
Restart=always
RestartSec=30
Environment="ENVIRONMENT=production"
Environment="METRICS_FILE=/var/metrics/health-checks.prom"
Environment="METRICS_PORT=9090"

[Install]
WantedBy=multi-user.target
```

**Enable and start:**

```bash
sudo systemctl enable health-check-exporter
sudo systemctl start health-check-exporter
sudo systemctl status health-check-exporter
```

### Cron-Based Monitoring

```bash
# Add to crontab: crontab -e

# Run health checks every 5 minutes
*/5 * * * * /opt/health-checks/health-check-prometheus-exporter.sh >> /var/log/health-checks.log 2>&1

# Run comprehensive validation hourly
0 * * * * /opt/health-checks/comprehensive-health-check.sh >> /var/log/comprehensive-health-checks.log 2>&1

# Daily SSL certificate check
0 6 * * * /opt/health-checks/scripts/ssl-tls-validator.sh example.com 443 30 >> /var/log/ssl-checks.log 2>&1
```

---

## Alertmanager Configuration

### Alertmanager Configuration File

```yaml
# /etc/alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m
  slack_api_url: ${SLACK_WEBHOOK_URL}

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'

  routes:
    # Critical alerts go to PagerDuty and Slack
    - match:
        severity: critical
      receiver: 'critical-alerts'
      continue: true

    # Warning alerts go to Slack only
    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'default'
    slack_configs:
      - channel: '#monitoring'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'critical-alerts'
    pagerduty_configs:
      - service_key: ${PAGERDUTY_SERVICE_KEY}
        severity: critical
    slack_configs:
      - channel: '#critical-alerts'
        title: '🚨 {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        color: 'danger'

  - name: 'warning-alerts'
    slack_configs:
      - channel: '#monitoring'
        title: '⚠️ {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        color: 'warning'

inhibit_rules:
  # Don't alert about response time if service is down
  - source_match:
      alertname: 'HealthCheckFailed'
    target_match:
      alertname: 'HighResponseTime'
    equal: ['endpoint']
```

---

## Continuous Monitoring Scripts

### Comprehensive Monitoring Loop

```bash
#!/bin/bash
# continuous-health-monitor.sh

set -euo pipefail

INTERVAL="${INTERVAL:-300}"  # 5 minutes
LOG_DIR="${LOG_DIR:-/var/log/health-checks}"
METRICS_DIR="${METRICS_DIR:-/var/metrics}"

mkdir -p "$LOG_DIR" "$METRICS_DIR"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_DIR/monitor.log"
}

check_endpoint() {
    local name="$1"
    local url="$2"
    local type="$3"

    local timestamp=$(date +%s)
    local status="UNKNOWN"
    local response_time=0

    case "$type" in
        http)
            if timeout 30 bash scripts/http-health-check.sh "$url" >> "$LOG_DIR/${name}.log" 2>&1; then
                status="HEALTHY"
            else
                status="UNHEALTHY"
            fi
            ;;
        api)
            if timeout 30 bash scripts/api-health-check.sh "$url/health" >> "$LOG_DIR/${name}.log" 2>&1; then
                status="HEALTHY"
            else
                status="UNHEALTHY"
            fi
            ;;
    esac

    # Write status to metrics file
    echo "${timestamp},${name},${type},${status}" >> "$METRICS_DIR/health-status.csv"

    log "$name: $status"
}

# Main monitoring loop
log "Starting continuous health monitoring (interval: ${INTERVAL}s)"

while true; do
    log "Running health check cycle..."

    check_endpoint "frontend" "https://example.com" "http"
    check_endpoint "api" "https://api.example.com" "api"
    check_endpoint "mcp-server" "https://mcp.example.com" "http"

    log "Health check cycle complete"

    sleep "$INTERVAL"
done
```

### Monitoring with Alerting

```bash
#!/bin/bash
# health-monitor-with-alerts.sh

set -euo pipefail

ALERT_WEBHOOK="${SLACK_WEBHOOK_URL}"
CONSECUTIVE_FAILURES=0
MAX_FAILURES=3

send_alert() {
    local severity="$1"
    local message="$2"

    local color="warning"
    [ "$severity" = "critical" ] && color="danger"

    curl -X POST "$ALERT_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{
            \"text\": \"Health Check Alert\",
            \"attachments\": [{
                \"color\": \"${color}\",
                \"text\": \"${message}\",
                \"ts\": $(date +%s)
            }]
        }"
}

run_checks() {
    local all_passed=true

    if ! bash scripts/http-health-check.sh https://example.com; then
        all_passed=false
    fi

    if ! bash scripts/api-health-check.sh https://api.example.com/health; then
        all_passed=false
    fi

    if [ "$all_passed" = false ]; then
        ((CONSECUTIVE_FAILURES++))

        if [ $CONSECUTIVE_FAILURES -ge $MAX_FAILURES ]; then
            send_alert "critical" "Health checks have failed $CONSECUTIVE_FAILURES consecutive times!"
        fi

        return 1
    else
        if [ $CONSECUTIVE_FAILURES -gt 0 ]; then
            send_alert "info" "Health checks recovered after $CONSECUTIVE_FAILURES failures"
        fi
        CONSECUTIVE_FAILURES=0
        return 0
    fi
}

# Run continuously
while true; do
    run_checks
    sleep 300  # 5 minutes
done
```

---

## Log Aggregation

### Centralized Logging with ELK Stack

```bash
#!/bin/bash
# ship-logs-to-elk.sh

LOGSTASH_HOST="${LOGSTASH_HOST:-localhost:5044}"
LOG_FILE="/var/log/health-checks/monitor.log"

# Send logs to Logstash using Filebeat
cat > /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/health-checks/*.log
    fields:
      service: health-checks
      environment: production
    multiline:
      pattern: '^\['
      negate: true
      match: after

output.logstash:
  hosts: ["${LOGSTASH_HOST}"]

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
EOF

# Restart Filebeat
sudo systemctl restart filebeat
```

### Query Health Check Logs

```bash
#!/bin/bash
# query-health-logs.sh

# Query Elasticsearch for recent health check failures
curl -X GET "localhost:9200/health-checks-*/_search?pretty" \
    -H 'Content-Type: application/json' \
    -d '{
      "query": {
        "bool": {
          "must": [
            {"match": {"message": "FAILED"}},
            {"range": {"@timestamp": {"gte": "now-1h"}}}
          ]
        }
      },
      "sort": [{"@timestamp": {"order": "desc"}}],
      "size": 100
    }'
```

---

## Docker Compose Monitoring Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./rules:/etc/prometheus/rules
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
    depends_on:
      - prometheus

  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager-data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'

  health-check-exporter:
    build:
      context: .
      dockerfile: Dockerfile.health-exporter
    ports:
      - "9100:9090"
    environment:
      - ENVIRONMENT=production
    volumes:
      - ./scripts:/opt/health-checks/scripts

volumes:
  prometheus-data:
  grafana-data:
  alertmanager-data:
```

---

This monitoring setup provides production-ready continuous monitoring with metrics, dashboards, and alerting for all health checks.
