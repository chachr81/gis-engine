#!/usr/bin/env sh
set -eu

# Solo informar quién soy y dónde estoy
echo "[django-web] uid=$(id -u) gid=$(id -g) workdir=$(pwd)"

DJANGO_PROJECT_NAME="${DJANGO_PROJECT_NAME:-portafolio_gis}"

# Bootstrap: si no existe manage.py, crea el proyecto Django en /app
if [ ! -f /app/manage.py ]; then
  if [ -w /app ]; then
    echo "[django-web] manage.py no existe en /app. Creando proyecto ${DJANGO_PROJECT_NAME}..."
    django-admin startproject "${DJANGO_PROJECT_NAME}" /app
  else
    echo "[django-web] ERROR: /app no es escribible y falta manage.py. Revisa permisos."
    exit 1
  fi
fi

# Estructura profesional: Crear carpeta 'apps' si no existe
if [ ! -d /app/apps ]; then
    echo "[django-web] Creando directorio para aplicaciones (apps/)..."
    mkdir -p /app/apps
    touch /app/apps/__init__.py
fi

# Migraciones (no falla si DB aún no está lista)
echo "[django-web] Ejecutando migraciones..."
python manage.py migrate --noinput || echo "[django-web] Advertencia: No se pudieron ejecutar las migraciones (¿DB lista?)."

exec "$@"
