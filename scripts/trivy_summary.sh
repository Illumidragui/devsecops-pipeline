#!/bin/bash

echo "## 🐳 Trivy - Container Scan" >> $GITHUB_STEP_SUMMARY

if [ -f trivy-report.json ]; then
  STATS=$(python3 -c "
import json
with open('trivy-report.json') as f:
    data = json.load(f)
counts = {}
for result in data.get('Results', []):
    for vuln in result.get('Vulnerabilities') or []:
        sev = vuln.get('Severity', 'UNKNOWN')
        counts[sev] = counts.get(sev, 0) + 1
print(' | '.join(f'{k}: {v}' for k, v in sorted(counts.items())))
" 2>/dev/null || echo "Sin vulnerabilidades o error al parsear")
  echo "**Resultado:** $STATS" >> $GITHUB_STEP_SUMMARY
fi