# Plataforma Geoespacial de Microservicios con Docker

![Docker](https://img.shields.io/badge/Docker-Engine-blue)
![Python](https://img.shields.io/badge/python-3.12%2B-blue)
![Licencia](https://img.shields.io/badge/License-MIT-yellow)

## 1. Descripción General

Este repositorio contiene una plataforma completa para el análisis y visualización de datos geoespaciales, construida sobre una arquitectura de microservicios orquestada con Docker Compose. El proyecto está diseñado para ser modular, robusto y escalable.

El corazón del proyecto es el `gis-engine`, un entorno de procesamiento de Big Data con Apache Spark y Apache Sedona, complementado por servicios de base de datos, API y un portal web con GeoDjango.

## 2. Arquitectura de Microservicios

La plataforma se divide en dos stacks que se comunican a través de una red compartida.

### Capa 1: Datos y Procesamiento (`docker-compose.yml`)
Este stack constituye el backend de almacenamiento y análisis de Big Data.

| Servicio | Descripción |
|---|---|
| `postgis` | Base de datos **PostgreSQL 16** con la extensión **PostGIS 3.4**, optimizada para consultas y almacenamiento de datos espaciales. |
| `gis-engine` | **Motor de procesamiento principal**. Entorno Ubuntu 24.04 con **Apache Spark 4.0.1**, **Apache Sedona 1.8.0** y Python 3.12. |

### Capa 2: Aplicación y Visualización (`docker-compose.portal.yml`)
Este stack expone los datos y la lógica de negocio.

| Servicio | Descripción |
|---|---|
| `django-web` | **Portal Web principal** (GeoDjango). Montado en `/app` con estructura profesional (`apps/`). |
| `api-fastapi` | **API REST** (FastAPI). Montado en `/app` con estructura modular (`app/routers`, `app/models`). |
| `geoserver` | Servidor de mapas estándar (OGC WMS/WFS). |
| `edge-proxy` | **Proxy Inverso (Nginx)**. Punto de entrada único (puerto 80) que redirige tráfico a los contenedores. |

---

## 3. Guía de Instalación

### 3.1. Estructura de Directorios Recomendada
Para un desarrollo ordenado, se recomienda tener el código fuente de las aplicaciones fuera de la carpeta de Docker.

```text
/home/usuario/
├── docker_data/        # Este repositorio (configuraciones Docker)
├── api_fastapi/        # Código fuente de la API
├── django_web/         # Código fuente del Portal
└── edge-proxy/         # Configuración de Nginx
```

### 3.2. Configuración Inicial

1. **Clonar el repositorio:**
   ```bash
   git clone <URL_DEL_REPOSITORIO> docker_data
   cd docker_data
   ```

2. **Configurar las variables de entorno:**
   Copia el archivo de ejemplo y edítalo con tus rutas **absolutas**.
   ```bash
   cp .env_example .env
   ```
   **Ejemplo de `.env`:**
   ```ini
   FASTAPI_PATH=/home/usuario/api_fastapi
   DJANGO_PATH=/home/usuario/django_web
   # ...
   ```

3. **Crear carpetas de código (si no existen):**
   Asegúrate de que las carpetas apuntadas en el `.env` existan.
   ```bash
   mkdir -p ~/api_fastapi ~/django_web ~/edge-proxy/nginx.conf
   ```

---

## 4. Cómo Ejecutar el Entorno

1. **Levantar la Capa de Datos (PostGIS + Spark):**
   ```bash
   docker compose up -d
   ```

2. **Levantar la Capa de Aplicación (Portal + API + Proxy):**
   ```bash
   docker compose -f docker-compose.portal.yml up -d
   ```
   *Nota: Si es la primera vez, añade `--build` al final para construir las imágenes.*

### Comandos Útiles

*   **Reconstruir contenedores tras cambios en dependencias:**
    ```bash
    docker compose -f docker-compose.portal.yml up -d --build --force-recreate
    ```

*   **Ver logs en tiempo real:**
    ```bash
    docker compose -f docker-compose.portal.yml logs -f --tail=100
    ```

---

## 5. Accesos Rápidos

| Servicio | URL Local | Descripción |
|---|---|---|
| **Portal Web** | [http://localhost/](http://localhost/) | Home de Django |
| **API Docs** | [http://localhost/api/docs](http://localhost/api/docs) | Swagger UI de FastAPI |
| **GeoServer** | [http://localhost/geoserver/](http://localhost/geoserver/) | Admin: `admin` / `geoserver` |
| **Salud API** | [http://localhost/api/health](http://localhost/api/health) | JSON Health Check |