# Plataforma Geoespacial de Microservicios con Docker

![Docker](https://img.shields.io/badge/Docker-Engine-blue)
![Python](https://img.shields.io/badge/python-3.12%2B-blue)
![Licencia](https://img.shields.io/badge/License-MIT-yellow)

## 1. Descripción General

Este repositorio contiene una plataforma completa para el análisis y visualización de datos geoespaciales, construida sobre una arquitectura de microservicios orquestada con Docker Compose. El proyecto está diseñado para ser modular, robusto y escalable, separando la infraestructura en dos capas principales: una para el procesamiento de datos pesados y otra para la exposición de servicios y aplicaciones web.

El corazón del proyecto es el `gis-engine`, un entorno de procesamiento de Big Data con Apache Spark y Apache Sedona, complementado por servicios de base de datos, API y un portal web con GeoDjango.

## 2. Arquitectura de Microservicios

La plataforma se divide en dos stacks que se comunican a través de una red compartida, permitiendo levantar solo los componentes necesarios para cada tarea.

### Capa 1: Datos y Procesamiento (`docker-compose.yml`)
Este stack constituye el backend de almacenamiento y análisis de Big Data.

| Servicio | Descripción |
|---|---|
| `postgis` | Base de datos **PostgreSQL 16** con la extensión **PostGIS 3.4**, optimizada para consultas y almacenamiento de datos espaciales. |
| `gis-engine` | **Motor de procesamiento principal**. Es un entorno Ubuntu 24.04 con **Apache Spark 4.0.1**, **Apache Sedona 1.8.0**, Python 3.12 y un conjunto completo de librerías GIS (GDAL, Geopandas, Rasterio, etc.) para análisis distribuido. |

### Capa 2: Aplicación y Visualización (`docker-compose.portal.yml`)
Este stack expone los datos y la lógica de negocio a través de servicios web accesibles desde el navegador.

| Servicio | Descripción |
|---|---|
| `django-web` | **Portal Web principal** desarrollado con GeoDjango. Actúa como la interfaz de usuario principal. |
| `api-fastapi` | **API REST** de alto rendimiento construida con FastAPI, ideal para servir endpoints de datos rápidos y eficientes. |
| `geoserver` | Servidor de mapas estándar para publicar datos geoespaciales a través de servicios OGC (WMS, WFS). |
| `edge-proxy` | **Proxy Inverso (Nginx)** que actúa como único punto de entrada a la plataforma. Redirige el tráfico al servicio correspondiente según la URL. |

---

## 3. Guía de Instalación y Configuración

A continuación se detallan los pasos para configurar el entorno en diferentes sistemas operativos.

### 3.1. Para Usuarios de Linux y macOS

**Prerrequisitos:**
- Docker y Docker Compose instalados.
- Git instalado.

**Pasos:**
1. **Clonar el repositorio:**
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd docker_data
   ```

2. **Crear archivos de configuración de Docker:**
   Copia los archivos de ejemplo para crear tu configuración local.
   ```bash
   cp docker-compose_example.yml docker-compose.yml
   cp docker-compose.portal_example.yml docker-compose.portal.yml
   ```

3. **Configurar las variables de entorno:**
   Copia el archivo de ejemplo `.env` y edítalo con tus rutas y credenciales.
   ```bash
   cp .env_example .env
   ```
   Abre el archivo `.env` con un editor de texto y **modifica las rutas para que sean absolutas** y apunten a las carpetas correctas en tu sistema.

### 3.2. Para Usuarios de Windows

El entorno funciona perfectamente en Windows 10/11 con Docker Desktop.

**Prerrequisitos:**
1. **Instalar Docker Desktop**:
   - Descarga e instala Docker Desktop desde [el sitio oficial de Docker](https://www.docker.com/products/docker-desktop).
   - Durante la instalación, se recomienda **habilitar la integración con WSL2** para un rendimiento óptimo.

2. **Git para Windows**:
   - Instala Git desde [git-scm.com](https://git-scm.com/download/win).

**Pasos:**
1. **Abrir una terminal**:
   Puedes usar PowerShell, Windows Terminal o Git Bash.

2. **Clonar el repositorio:**
   ```powershell
   git clone <URL_DEL_REPOSITORIO>
   cd docker_data
   ```

3. **Crear archivos de configuración de Docker:**
   Usa el comando `copy` en la terminal de Windows.
   ```powershell
   copy docker-compose_example.yml docker-compose.yml
   copy docker-compose.portal_example.yml docker-compose.portal.yml
   ```

4. **Configurar las variables de entorno:**
   ```powershell
   copy .env_example .env
   ```
   Abre el archivo `.env` con un editor (como VS Code o Notepad++) y **modifica las rutas**. Deben ser absolutas y usar el formato de Windows (ej. `C:\Users\TuUsuario\proyectos\docker_data`).

---

## 4. Cómo Ejecutar el Entorno

El proceso es el mismo para todos los sistemas operativos.

1. **Levantar la Capa de Datos**:
   Abre una terminal en la raíz del proyecto y ejecuta:
   ```bash
   docker compose up -d
   ```

2. **Levantar la Capa de Aplicación**:
   Una vez la capa de datos esté funcionando, levanta los servicios web:
   ```bash
   docker compose -f docker-compose.portal.yml up -d
   ```

### Detener el Entorno
Para detener todos los servicios:
```bash
docker compose -f docker-compose.portal.yml down
docker compose down
```
> **Nota**: Para borrar también los volúmenes de datos (¡cuidado, esto elimina los datos de PostGIS!), añade la opción `-v`.

---

## 5. Guía de Uso y Desarrollo

### Acceso a los Servicios Web
- **Portal Web (Django)**: [http://localhost/](http://localhost/)
- **API (FastAPI)**: [http://localhost/api/health](http://localhost/api/health)
- **GeoServer**: [http://localhost/geoserver/](http://localhost/geoserver/)
- **PostGIS**: Accesible en el puerto `${POSTGRES_PORT}` desde tu máquina local.

### Interacción con `gis-engine`
- **Acceder al contenedor**:
  ```bash
  docker exec -it gis-engine bash
  ```
- **Activar el entorno Python**:
  ```bash
  source ~/.venv/bin/activate
  ```
- **Ejecutar Jupyter Notebook**:
  ```bash
  jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
  ```
  > Para acceder, necesitarás mapear el puerto `8888` en el `docker-compose.yml`.
- **Validar Spark y Sedona**:
  ```bash
  python /opt/validate_sedona.py
  ```

### Conexión a PostGIS desde `gis-engine`
```bash
psql -h postgis -U $POSTGRES_USER -d $POSTGRES_DB
```
---

## 6. Cómo Colaborar
¡Gracias por tu interés en colaborar!
1. **Reportar Problemas**: Si encuentras un error o tienes una sugerencia, abre un [issue](https://github.com/chachr81/gis-engine/issues) detallando el problema.
2. **Proponer Mejoras**:
   - Realiza un fork del repositorio.
   - Crea una nueva rama para tus cambios (`git checkout -b feature/nombre-mejora`).
   - Realiza tus cambios y haz commit (`git commit -m "feat: descripción del cambio"`).
   - Envía un Pull Request hacia la rama principal del repositorio original.
