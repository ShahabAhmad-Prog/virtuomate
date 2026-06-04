# Production Cloud Run — coaching assessment API
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV PORT=8080

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-cloud.txt .
RUN pip install --no-cache-dir -r requirements-cloud.txt

COPY ml ./ml

# Verify imports at build time (fails build early if package layout is wrong)
RUN python -c "from ml.api.main import app; print('build_check_ok', app.title)"

EXPOSE 8080

# Cloud Run sets PORT=8080; bind all interfaces
CMD ["python", "-m", "uvicorn", "ml.api.main:app", "--host", "0.0.0.0", "--port", "8080"]
