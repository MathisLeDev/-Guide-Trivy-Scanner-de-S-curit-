#!/bin/bash
set -e
IMAGE_NAME=$1
SAFE_IMAGE_NAME=$(echo "$IMAGE_NAME" | sed 's/[:\/]/-/g')
SEVERITY="CRITICAL,HIGH"
REPORT_FILE="security-report-${SAFE_IMAGE_NAME}.json"
echo "🔍 Scanning $IMAGE_NAME for security vulnerabilities..."
trivy image \
  --severity $SEVERITY \
  --format json \
  --output $REPORT_FILE \
  --exit-code 1 \
  $IMAGE_NAME
if [ $? -eq 0 ]; then
  echo "✅ Security scan passed!"
else
  echo "❌ Security scan failed! Check $REPORT_FILE for details."
  exit 1
fi
