# Servicio de Proxy Inverso con Nginx

Este servicio actúa como el **único punto de entrada** a la plataforma web. Utiliza Nginx como un proxy inverso para dirigir el tráfico entrante al microservicio adecuado basándose en la URL solicitada.

## Configuración (`nginx.conf/default.conf`)

La lógica de enrutamiento está definida en el archivo `default.conf`.

-   **Listener**: Escucha en el puerto `80`, el puerto estándar para HTTP.
-   **Timeouts y Tamaño de Subida**:
    -   Se han aumentado los `timeouts` a 600 segundos para permitir operaciones largas, como la subida o procesamiento de grandes archivos GIS.
    -   `client_max_body_size` se ha fijado en `100M` para permitir la subida de datasets de tamaño considerable.
-   **Reglas de Enrutamiento (`location`)**:
    1.  `location /api/`: Todas las peticiones que empiezan con `/api/` son redirigidas al servicio `api-fastapi` en el puerto `8000`.
    2.  `location /geoserver/`: Las peticiones a `/geoserver/` se envían al contenedor de `geoserver` en el puerto `8080`.
    3.  `location /`: **Cualquier otra petición** (la regla por defecto) se redirige al portal principal, el servicio `django-web` en el puerto `8000`.
-   **Cabeceras (`proxy_set_header`)**: En cada `location`, se añaden cabeceras importantes como `X-Real-IP` y `X-Forwarded-For`. Esto permite que los servicios de backend (Django, FastAPI) sepan la dirección IP real del cliente final, en lugar de ver siempre la IP del contenedor de Nginx.
