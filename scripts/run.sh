#!/bin/sh

set -e

echo "Waiting for database..."
python manage.py wait_for_db

echo "Running migrations..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn app.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers ${GUNICORN_WORKERS:-4} \
    --worker-class ${GUNICORN_WORKER_CLASS:-sync} \
    --timeout ${GUNICORN_TIMEOUT:-30} \
    --log-level ${GUNICORN_LOG_LEVEL:-info}