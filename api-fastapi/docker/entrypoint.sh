#!/usr/bin/env sh
set -eu

# Solo informar quién soy y dónde estoy
echo "[api-fastapi] uid=$(id -u) gid=$(id -g) workdir=$(pwd)"

# Bootstrap: si no existe main.py, créalo (solo si /app es escribible)
if [ ! -f /app/main.py ]; then
  if [ -w /app ]; then
    echo "[api-fastapi] main.py no existe en /app. Creando plantilla mínima..."
    cat > /app/main.py <<'EOF'
from fastapi import FastAPI

app = FastAPI(title="Portal GIS API")

@app.get("/health")
def health():
    return {"status": "ok"}
EOF
  else
    echo "[api-fastapi] ERROR: /app no es escribible y falta main.py. Revisa permisos del bind-mount en el host."
    ls -la /app || true
    exit 1
  fi
fi

exec "$@"
