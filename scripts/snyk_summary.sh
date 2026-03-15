#!/bin/bash

echo "## 📦 Snyk - Dependency Scan" >> $GITHUB_STEP_SUMMARY

if [ -f snyk-report.json ]; then
  VULNS=$(python3 -c "
import json, sys
data = json.load(open('snyk-report.json'))
vulns = data.get('vulnerabilities', [])
high = sum(1 for v in vulns if v.get('severity') == 'high')
critical = sum(1 for v in vulns if v.get('severity') == 'critical')
print(f'Critical: {critical} | High: {high} | Total: {len(vulns)}')
" 2>/dev/null || echo "No se pudo parsear el reporte")
  echo "**Vulnerabilidades encontradas:** $VULNS" >> $GITHUB_STEP_SUMMARY
fi