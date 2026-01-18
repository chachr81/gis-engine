#!/usr/bin/env sh
set -eu

# Fix permisos del bind-mount (si el host quedó root:root)
chown -R "$(id -u):$(id -g)" /app 2>/dev/null || true

# Bootstrap: si no existe main.py, créalo
if [ ! -f /app/main.py ]; then
  echo "[api-fastapi] main.py no existe en /app. Creando plantilla mínima..."
  cat > /app/main.py <<'EOF'
from fastapi import FastAPI

app = FastAPI(title="Portal GIS API")

@app.get("/health")
def health():
    return {"status": "ok"}
EOF
fi

exec "$@"