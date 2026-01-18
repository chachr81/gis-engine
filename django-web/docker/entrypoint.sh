#!/usr/bin/env sh
set -eu

DJANGO_PROJECT_NAME="${DJANGO_PROJECT_NAME:-portafolio_gis}"

# Fix permisos del bind-mount (si el host quedó root:root)
chown -R "$(id -u):$(id -g)" /app 2>/dev/null || true

# Bootstrap: si no existe manage.py, crea el proyecto Django en /app
if [ ! -f /app/manage.py ]; then
  echo "[django-web] manage.py no existe en /app. Creando proyecto ${DJANGO_PROJECT_NAME}..."
  django-admin startproject "${DJANGO_PROJECT_NAME}" /app
fi

# Migraciones (no falla si DB aún no está lista)
python manage.py migrate --noinput || true

exec "$@"
