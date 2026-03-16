#!/bin/bash

set +e

TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")
SHORT_COMMIT="${GITHUB_SHA:0:7}"
BRANCH="$GITHUB_REF_NAME"

cat > consolidated-report.md << EOF
# 🛡️ Security Report — DevSecOps Pipeline

**Commit:** \`$SHORT_COMMIT\`
**Branch:** \`$BRANCH\`
**Generated:** $TIMESTAMP
**Workflow run:** $GITHUB_RUN_NUMBER

---

## Summary

| Tool | Type | Scope |
|------|------|-------|
| SonarQube | SAST | Source code |
| Snyk | SCA | Dependencies |
| Trivy | Container | Docker image |
| OWASP ZAP | DAST | Running app |

---

## 📦 Snyk — Dependency Vulnerabilities
EOF

if [ -f all-reports/snyk-report/snyk-report.json ]; then
  python3 -c "
import json
with open('all-reports/snyk-report/snyk-report.json') as f:
    data = json.load(f)
vulns = data.get('vulnerabilities', [])
if not vulns:
    print('No vulnerabilities found.')
else:
    print(f'Total: {len(vulns)}\n')
    print('| Package | Severity | CVE | Fix |')
    print('|---------|----------|-----|-----|')
    for v in vulns[:20]:
        pkg = v.get('moduleName', 'N/A')
        sev = v.get('severity', 'N/A').upper()
        cve = v.get('identifiers', {}).get('CVE', ['N/A'])[0]
        fix = v.get('fixedIn', ['No fix'])[0] if v.get('fixedIn') else 'No fix'
        print(f'| {pkg} | {sev} | {cve} | {fix} |')
" >> consolidated-report.md 2>/dev/null || echo "_Report not available_" >> consolidated-report.md
else
  echo "_Snyk report not found_" >> consolidated-report.md
fi

cat >> consolidated-report.md << 'EOF'

---

## 🐳 Trivy — Container Vulnerabilities
EOF

if [ -f all-reports/trivy-report/trivy-report.json ]; then
  python3 -c "
import json
with open('all-reports/trivy-report/trivy-report.json') as f:
    data = json.load(f)
all_vulns = []
for result in data.get('Results', []):
    for v in result.get('Vulnerabilities') or []:
        all_vulns.append(v)
if not all_vulns:
    print('No vulnerabilities found.')
else:
    print(f'Total: {len(all_vulns)}\n')
    print('| Package | Severity | CVE | Fixed In |')
    print('|---------|----------|-----|----------|')
    for v in all_vulns[:20]:
        print(f'| {v.get(\"PkgName\",\"N/A\")} | {v.get(\"Severity\",\"N/A\")} | {v.get(\"VulnerabilityID\",\"N/A\")} | {v.get(\"FixedVersion\",\"No fix\")} |')
" >> consolidated-report.md 2>/dev/null || echo "_Report not available_" >> consolidated-report.md
else
  echo "_Trivy report not found_" >> consolidated-report.md
fi

cat >> consolidated-report.md << 'EOF'

---

## 🌐 OWASP ZAP — DAST Alerts
EOF

if [ -f all-reports/zap-reports/report_json.json ]; then
  python3 -c "
import json
with open('all-reports/zap-reports/report_json.json') as f:
    data = json.load(f)
alerts = data.get('site', [{}])[0].get('alerts', [])
if not alerts:
    print('No alerts found.')
else:
    print(f'Total alerts: {len(alerts)}\n')
    print('| Alert | Risk | Confidence | Count |')
    print('|-------|------|------------|-------|')
    for a in alerts[:20]:
        print(f'| {a.get(\"alert\",\"N/A\")} | {a.get(\"riskdesc\",\"N/A\")} | {a.get(\"confidence\",\"N/A\")} | {a.get(\"count\",\"1\")} |')
" >> consolidated-report.md 2>/dev/null || echo "_Report not available_" >> consolidated-report.md
else
  echo "_ZAP report not found_" >> consolidated-report.md
fi