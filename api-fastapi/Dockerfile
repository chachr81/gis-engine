# ---------------------------
# Dockerfile (FastAPI) - Production Ready
# ---------------------------
FROM python:3.12-slim

# Evita archivos .pyc y buffers en logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

# 1. Instalar dependencias del sistema
# Agregamos 'curl', 'nano', 'iputils-ping' para facilitar depuración dentro del contenedor
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    tini \
    curl \
    nano \
    iputils-ping \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar dependencias de Python
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copiar el código fuente
COPY . /app

# 4. Entrypoint script (para configuraciones de inicio)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]

# 5. Comando por defecto
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]