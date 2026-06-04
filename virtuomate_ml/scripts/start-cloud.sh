#!/bin/sh
set -e
echo "VirtuoMate Intelligence Engine starting..."
echo "PORT=${PORT:-8080}"
python -c "from ml.api.main import app; print('import_ok', app.title)"
exec python -m uvicorn ml.api.main:app --host 0.0.0.0 --port "${PORT:-8080}" --log-level info
