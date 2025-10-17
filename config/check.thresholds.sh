#!/bin/sh
RESULTS_FILE=$1

echo "Checking thresholds for $RESULTS_FILE ..."

# Calcula métricas básicas (puedes usar awk o grep)
P95=$(awk -F',' 'NR>1 {print $2}' $RESULTS_FILE | sort -n | awk 'BEGIN{c=0} {a[c++]=$1} END{print a[int(c*0.95)]}')
ERRORS=$(grep -c "false" $RESULTS_FILE)
TOTAL=$(($(wc -l < $RESULTS_FILE) - 1))
ERROR_RATE=$(echo "scale=2; ($ERRORS/$TOTAL)*100" | bc)

echo "P95 response time: ${P95} ms"
echo "Error rate: ${ERROR_RATE}%"

THRESHOLD_P95=500
THRESHOLD_ERROR=1

if [ "$P95" -gt "$THRESHOLD_P95" ]; then
  echo "❌ Threshold failed: P95 > ${THRESHOLD_P95} ms"
  exit 1
fi

if [ "$(echo "$ERROR_RATE > $THRESHOLD_ERROR" | bc)" -eq 1 ]; then
  echo "❌ Threshold failed: Error rate > ${THRESHOLD_ERROR}%"
  exit 1
fi

echo "✅ All thresholds passed."