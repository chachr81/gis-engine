# ---------------------------
# Dockerfile (Django + GeoDjango) - DEV (autobootstrap + permisos)
# ---------------------------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias del sistema para GeoDjango + tini
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils \
    git \
    gdal-bin \
    libgdal-dev \
    libproj-dev \
    proj-bin \
    libgeos-dev \
    libpq-dev \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    Django \
    djangorestframework \
    django-leaflet \
    psycopg2-binary

# EntryPoint (bootstrap manage.py/proyecto + fix permisos)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
