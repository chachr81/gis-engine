# Servicio de Portal Web con GeoDjango

Este servicio contiene la aplicación web principal del proyecto, construida con el framework Django y su extensión geoespacial, GeoDjango.

## Estructura del Contenedor

### Dockerfile

El `Dockerfile` está optimizado para un entorno de desarrollo de GeoDjango.

-   **Imagen Base**: `python:3.12-slim`, para mantener la imagen ligera.
-   **Dependencias del Sistema**: A diferencia de un Django normal, GeoDjango requiere una serie de librerías geoespaciales a nivel de sistema:
    -   `gdal-bin`, `libgdal-dev`: GDAL es una librería fundamental para la lectura y escritura de formatos de datos geoespaciales.
    -   `libproj-dev`, `proj-bin`: Para la gestión de proyecciones y transformaciones de coordenadas.
    -   `libgeos-dev`: Para operaciones geométricas.
    -   `libpq-dev`: Para la conexión con PostgreSQL/PostGIS.
    -   `tini`: Al igual que en el otro servicio, se usa para una gestión de procesos robusta.
-   **Dependencias de Python**:
    -   `Django`, `djangorestframework`: El core del framework web y su popular extensión para crear APIs REST.
    -   `django-leaflet`: Facilita la integración de mapas interactivos de Leaflet.
    -   `psycopg2-binary`: El adaptador de base de datos para PostgreSQL.

### Entrypoint (`docker/entrypoint.sh`)

El script `entrypoint.sh` automatiza la configuración inicial del entorno de desarrollo de Django:

1.  **Ajuste de Permisos**:
    ```sh
    chown -R "$(id -u):$(id -g)" /app 2>/dev/null || true
    ```
    Corrige los permisos de la carpeta `/app` para el usuario del contenedor, evitando problemas con el `bind-mount`.

2.  **Auto-Bootstrap de Django**:
    ```sh
    if [ ! -f /app/manage.py ]; then
      django-admin startproject "${DJANGO_PROJECT_NAME}" /app
    fi
    ```
    Esta es la parte más importante. Si el script no encuentra un `manage.py` en `/app`, **crea un nuevo proyecto Django automáticamente**. El nombre del proyecto se toma de la variable de entorno `DJANGO_PROJECT_NAME`, con `portafolio_gis` como valor por defecto.

3.  **Migraciones Automáticas**:
    ```sh
    python manage.py migrate --noinput || true
    ```
    Intenta ejecutar las migraciones de la base de datos al iniciar. El `|| true` al final es importante: asegura que si el comando de migración falla (por ejemplo, porque la base de datos aún no está lista), el script no se detenga y el contenedor pueda seguir arrancando.

4.  **Ejecución del Comando Principal**:
    ```sh
    exec "$@"
    ```
    Ejecuta el comando por defecto: `python manage.py runserver 0.0.0.0:8000`, que inicia el servidor de desarrollo de Django.
