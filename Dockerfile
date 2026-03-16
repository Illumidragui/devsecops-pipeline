# Build stage
FROM python:3.12-slim AS builder
WORKDIR /app
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.12-slim
WORKDIR /app

# Update packages to fix vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# No root — importante para seguridad
RUN adduser --disabled-password --gecos '' appuser

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn
COPY app/ ./app/

USER appuser
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:create_app()"]