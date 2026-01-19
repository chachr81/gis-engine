# Servicio de API con FastAPI

Este servicio proporciona una API REST de alto rendimiento, construida con el framework FastAPI y optimizada para datos geoespaciales.

## Estructura del Proyecto

El contenedor espera una estructura de proyecto profesional ("Application Factory"), donde el código reside en un paquete `app`.

```text
api_fastapi/       <-- Raíz del volumen montado en /app
├── app/
│   ├── __init__.py
│   ├── main.py    <-- Punto de entrada (app.main:app)
│   ├── routers/
│   ├── models/
│   └── ...
├── requirements.txt
└── Dockerfile (opcional si usas el centralizado)
```

## Detalles Técnicos del Contenedor

### Dockerfile
*   **Imagen Base**: `python:3.12-slim`.
*   **Dependencias**: Instala librerías clave para GIS (`geoalchemy2`, `asyncpg`, `psycopg2`) y utilidades de depuración (`curl`, `nano`, `netcat`).
*   **Gestión de Paquetes**: Utiliza un archivo `requirements.txt` centralizado para fácil mantenimiento.

### Entrypoint (`docker/entrypoint.sh`)
El script de arranque es inteligente y robusto:
1.  **Check de Estructura**: Verifica si existe `app/main.py`. Si no existe, crea automáticamente la estructura de carpetas `app/{routers,models,...}` y un archivo `main.py` de ejemplo.
2.  **Permisos**: Ajusta los permisos de `/app` para coincidir con el usuario del host, evitando problemas de escritura en Linux.
3.  **Arranque**: Lanza `uvicorn` apuntando al módulo `app.main:app` con "Hot Reload" activado.

## Desarrollo

Para agregar nuevas dependencias:
1.  Edita `requirements.txt` en tu carpeta local.
2.  Ejecuta: `docker compose -f docker-compose.portal.yml up -d --build api-fastapi`.