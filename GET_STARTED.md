# Guía de Inicio Rápido (Get Started)

Este documento proporciona los comandos esenciales para interactuar con los contenedores del stack GIS y acceder a sus consolas.

## Acceso a las Consolas de los Contenedores

Para ejecutar comandos dentro de los contenedores activos, utiliza `docker exec`.

### 1. Base de Datos (PostGIS)
Acceder a la terminal del sistema:
```bash
docker exec -it postgis /bin/bash
```
Acceder directamente a la consola de PostgreSQL:
```bash
docker exec -it postgis psql -U postgres -d gis_db
# Nota: Reemplaza 'postgres' y 'gis_db' con los valores de tu .env si son diferentes.
```

### 2. API de Datos (FastAPI)
```bash
docker exec -it api-fastapi /bin/bash
```

### 3. Portal Web (Django)
```bash
docker exec -it django-web /bin/bash
```
Para ejecutar comandos de gestión de Django (ej. migraciones):
```bash
docker exec -it django-web python manage.py shell
```

### 4. Motor GIS (Gis Engine - Worker)
```bash
docker exec -it gis-engine /bin/bash
```

### 5. GeoServer
```bash
docker exec -it geoserver /bin/bash
```

---

## Documentación de la API (FastAPI)

Una vez que los contenedores estén corriendo, puedes acceder a la documentación interactiva de la API (Swagger UI):

*   **Vía Proxy (Recomendado):** http://localhost/api/docs
*   **Acceso Directo:** http://localhost:8000/docs

## Prueba de Endpoints (ArcGIS Proxy)

Se ha añadido un endpoint de ejemplo en FastAPI para consultar un servicio externo de ArcGIS (Censo).

*   **Endpoint:** `/api/arcgis/census-info` (o `/arcgis/census-info` si accedes directo al puerto 8000)
*   **Descripción:** Consulta los metadatos de la capa "Microdatos Censo" desde el servicio público de ArcGIS.
