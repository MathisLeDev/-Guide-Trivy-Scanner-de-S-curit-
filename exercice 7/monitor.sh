#!/bin/bash
IMAGES=("nginx:latest" "redis:latest" "postgres:latest")
REPORT_DIR="reports/$(date +%Y-%m-%d)"
mkdir -p $REPORT_DIR
for image in "${IMAGES[@]}"; do
  echo "Scanning $image..."
  report_file="$REPORT_DIR/${image//[:\/]/_}.json"
  trivy image --format json --output "$report_file" "$image"
  critical_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$report_file")
  if [ "$critical_count" -gt 0 ]; then
    echo "⚠️ $critical_count critical vulnerabilities found in $image"
    # curl -X POST ... (alerte Slack)
  fi
done
