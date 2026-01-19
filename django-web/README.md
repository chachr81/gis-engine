# Servicio de Portal Web con GeoDjango

Este servicio aloja la aplicación web principal, utilizando Django con soporte geoespacial completo (GeoDjango).

## Estructura del Proyecto

El contenedor está configurado para soportar una estructura modular con una carpeta dedicada `apps/`.

```text
django_web/        <-- Raíz del volumen montado en /app
├── manage.py
├── portafolio_gis/ <-- Configuración del proyecto (settings, wsgi)
├── apps/           <-- Tus aplicaciones Django (users, maps, etc.)
├── requirements.txt
└── ...
```

## Detalles Técnicos del Contenedor

### Dockerfile
*   **Imagen Base**: `python:3.12-slim`.
*   **Librerías GIS**: Incluye GDAL, GEOS y PROJ instalados a nivel de sistema (`apt-get`), necesarios para GeoDjango.
*   **Herramientas**: Incluye `curl`, `nano` y `ping` para diagnóstico.

### Entrypoint (`docker/entrypoint.sh`)
Automatiza la configuración inicial:
1.  **Bootstrap de Proyecto**: Si no encuentra `manage.py`, crea un proyecto Django nuevo llamado `portafolio_gis`.
2.  **Estructura de Apps**: Crea automáticamente la carpeta `apps/` y su `__init__.py` si no existen, fomentando las buenas prácticas desde el inicio.
3.  **Migraciones**: Intenta ejecutar `python manage.py migrate` en cada inicio (ignora fallos si la DB no está lista).

## Configuración de Base de Datos (PostGIS)

Para conectar tu proyecto Django con el servicio `postgis` del stack, asegúrate de configurar `DATABASES` en `settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': os.environ.get('POSTGRES_DB', 'postgres'),
        'USER': os.environ.get('POSTGRES_USER', 'postgres'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD', ''),
        'HOST': os.environ.get('POSTGRES_HOST', 'postgis'),
        'PORT': os.environ.get('POSTGRES_PORT', '5432'),
    }
}
```
*Nota: Recuerda añadir `'django.contrib.gis'` a `INSTALLED_APPS`.*