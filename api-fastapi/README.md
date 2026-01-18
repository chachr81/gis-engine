# Servicio de API con FastAPI

Este servicio proporciona una API REST de alto rendimiento para el proyecto, construida con el framework FastAPI.

## Estructura del Contenedor

### Dockerfile

El `Dockerfile` está diseñado para ser ligero y eficiente, específico para una aplicación Python asíncrona.

-   **Imagen Base**: Se utiliza `python:3.12-slim`, una imagen oficial de Python muy ligera, ideal para producción.
-   **Variables de Entorno**:
    -   `PYTHONDONTWRITEBYTECODE=1`: Evita que Python genere archivos `.pyc`, manteniendo el contenedor limpio.
    -   `PYTHONUNBUFFERED=1`: Asegura que los logs de Python se envíen directamente a la terminal del contenedor sin búfer, facilitando el debugging.
-   **Dependencias del Sistema**:
    -   `libpq-dev`: Librerías de desarrollo necesarias para compilar el conector de PostgreSQL (`psycopg2`).
    -   `tini`: Un sistema `init` mínimo que se usa como `ENTRYPOINT` principal. Se encarga de gestionar correctamente los procesos y las señales (como `Ctrl+C`), evitando procesos "zombies" y asegurando un apagado limpio del contenedor.
-   **Dependencias de Python**:
    -   Se instalan a través de `pip` en una única capa para optimizar el tamaño de la imagen. Incluyen `fastapi`, `uvicorn` (servidor ASGI), `psycopg2-binary` (conector PostGIS), `sqlalchemy`, `alembic`, `geoalchemy2` y `asyncpg` para el soporte asíncrono de base de datos.

### Entrypoint (`docker/entrypoint.sh`)

El script de `entrypoint.sh` se ejecuta cada vez que el contenedor se inicia (gestionado por `tini`) y realiza dos tareas cruciales antes de ejecutar el comando principal:

1.  **Ajuste de Permisos**:
    ```sh
    chown -R "$(id -u):$(id -g)" /app 2>/dev/null || true
    ```
    Este comando soluciona un problema común en Docker con los `bind-mounts` (cuando montas una carpeta de tu PC en el contenedor). Asegura que los archivos en `/app` sean propiedad del usuario del contenedor, evitando errores de permisos de lectura/escritura.

2.  **Auto-Bootstrap**:
    ```sh
    if [ ! -f /app/main.py ]; then
      # ... crea un archivo main.py básico
    fi
    ```
    Esta lógica comprueba si existe un archivo `main.py` en la carpeta `/app`. Si no existe (por ejemplo, si la carpeta de desarrollo local está vacía), crea un `main.py` mínimo con un endpoint de `/health`. Esto garantiza que el servidor `uvicorn` pueda arrancar sin errores incluso antes de que se haya escrito la primera línea de código de la API.

3.  **Ejecución del Comando Principal**:
    ```sh
    exec "$@"
    ```
    Esta línea final ejecuta el comando que se le pasa al contenedor (el `CMD` del Dockerfile o el `command` del Docker Compose). En este caso, por defecto es `uvicorn main:app --host 0.0.0.0 --port 8000 --reload`.
