#!/bin/bash

echo "## 🌐 OWASP ZAP - DAST Scan" >> $GITHUB_STEP_SUMMARY

if [ -f report_json.json ]; then
  STATS=$(python3 -c "
import json
with open('report_json.json') as f:
    data = json.load(f)
alerts = data.get('site', [{}])[0].get('alerts', [])
counts = {}
for a in alerts:
    risk = a.get('riskdesc', 'Unknown').split(' ')[0]
    counts[risk] = counts.get(risk, 0) + int(a.get('count', 1))
print(' | '.join(f'{k}: {v}' for k, v in sorted(counts.items())))
" 2>/dev/null || echo "Sin alertas o error al parsear")
  echo "**Alertas encontradas:** $STATS" >> $GITHUB_STEP_SUMMARY
fi