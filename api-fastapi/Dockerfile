# ---------------------------
# Dockerfile (FastAPI) - DEV (autobootstrap + permisos)
# ---------------------------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias del sistema (Postgres client libs) + tini para señales limpias
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Dependencias Python típicas para API + PostGIS
RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    psycopg2-binary \
    sqlalchemy \
    alembic \
    geoalchemy2 \
    asyncpg

# EntryPoint (bootstrap main.py + fix permisos)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]

# CMD por defecto (DEV)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
