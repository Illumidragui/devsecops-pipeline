# DevSecOps Pipeline

A CI/CD pipeline with automated security testing for a Python Flask application.

## Pipeline Overview

Every push to `main` triggers the following security checks automatically:

```
Code Push → Gitleaks (secret scan) → Tests → SonarCloud (SAST) → Snyk (SCA) → Trivy (Container Scan) → OWASP ZAP (DAST) → Consolidated Report
```

## Pipeline Diagram

```mermaid
flowchart TD
    A[git push → main] --> B[Gitleaks(Secret Scan)]
    B --> C[Tests - pytest]
    C --> D[SonarCloud(SAST)]
    C --> E[Snyk(SCA)]
    C --> F[Trivy(Container Scan)]
    C --> G[OWASP ZAP(DAST)]
    D --> H[Consolidated Report]
    E --> H
    F --> H
    G --> H
```

## Security Tools

### Gitleaks — Secret Scanning
Runs on every push to detect hard-coded secrets (API keys, tokens, passwords) in the repository history.

### SonarCloud — Static Application Security Testing (SAST)
Analyzes the source code on every push to detect vulnerabilities, code smells, and bugs before deployment.

**Finding fixed:** Routes lacked explicit HTTP method declarations, violating the principle of least privilege. Fixed by adding `methods=['GET']` to all endpoints.

### Snyk — Software Composition Analysis (SCA)
Scans `requirements.txt` for known vulnerabilities in third-party application dependencies.

**Finding fixed:** `gunicorn==22.0.0` had a high severity vulnerability. Snyk generated the fix PR automatically — updated to a patched version.

### Trivy — Container Image Scanning
Scans the full Docker image for vulnerabilities across two layers that other tools miss:

- **OS base packages** — the `python:3.12-slim` image includes Debian system libraries (openssl, libc, zlib). Trivy cross-references installed versions against CVE databases (NVD, Red Hat, Debian). Snyk does not cover this layer.
- **Application dependencies** — a second layer of coverage on `requirements.txt`, using a different vulnerability database than Snyk for broader detection.

Pipeline is configured with `severity: CRITICAL,HIGH` and `ignore-unfixed: true` — only fails on actionable, high-impact vulnerabilities.

### OWASP ZAP — Dynamic Application Security Testing (DAST)
Attacks the running application to detect vulnerabilities that only appear at runtime.

**Findings fixed:** 5 missing HTTP security headers detected and added:
- `X-Content-Type-Options` — prevents MIME type sniffing
- `Content-Security-Policy` — mitigates XSS attacks
- `Permissions-Policy` — restricts access to browser features
- `Cross-Origin-Resource-Policy` — prevents cross-origin data leaks
- `Cache-Control` — prevents sensitive data caching

### Consolidated Security Report
At the end of the pipeline a consolidated report is generated combining the output from all tools (SonarCloud, Snyk, Trivy, ZAP) into a single `consolidated-report.md` artifact.

## Security Decisions in the Dockerfile

**Multi-stage build** — separates build and runtime environments, reducing the attack surface by excluding build tools from the final image.

**Non-root user** — the container runs as `appuser` instead of `root`, limiting the blast radius if the application is compromised.

## Project Structure

```
devsecops-pipeline/
├── app/
│   ├── __init__.py               # App factory
│   └── routes.py                 # Endpoints with security headers
├── tests/
│   └── test_app.py               # Pytest test suite
├── .github/
│   └── workflows/
│       └── pipeline.yml          # CI/CD pipeline definition
├── scripts/                      # Pipeline helper scripts
│   ├── generate_consolidated_report.sh
│   ├── snyk_summary.sh
│   ├── trivy_summary.sh
│   └── zap_summary.sh
├── Dockerfile                    # Multi-stage, non-root build
├── sonar-project.properties
└── requirements.txt
```

## Running Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
python -m pytest tests/ -v

# Run with Docker
docker build -t devsecops-demo .
docker run -p 5000:5000 devsecops-demo
```

## Pipeline Status
![Pipeline](https://github.com/Illumidragui/devsecops-pipeline/actions/workflows/pipeline.yml/badge.svg)