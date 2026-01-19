# Servicio de Proxy Inverso con Nginx

Este servicio actúa como la puerta de enlace (Gateway) única para toda la plataforma.

## Función
Nginx recibe todo el tráfico HTTP en el puerto **80** y lo distribuye a los contenedores internos:

*   `http://localhost/` -> **Django Web** (Puerto 8000)
*   `http://localhost/api/` -> **FastAPI** (Puerto 8000)
*   `http://localhost/geoserver/` -> **GeoServer** (Puerto 8080)

## Configuración

La configuración reside en un único archivo `nginx.conf/default.conf` que se monta como volumen dentro del contenedor.

### Características Clave
*   **Soporte para Archivos Grandes**: `client_max_body_size 100M` (Ideal para subir rasters o shapefiles).
*   **Timeouts Extendidos**: `600s` para lecturas y envíos, evitando cortes en procesamientos GIS pesados.
*   **CORS**: Configurado para permitir peticiones cruzadas en GeoServer y API.

### Montaje del Volumen
En el `docker-compose.portal.yml`, el archivo se monta explícitamente:
```yaml
volumes:
  - /ruta/a/nginx.conf/default.conf:/etc/nginx/conf.d/default.conf:ro
```
*Asegúrate de que la ruta local apunte al archivo `.conf`, no al directorio que lo contiene.*