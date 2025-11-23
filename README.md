# GIS Engine – Entorno Geoespacial Completo (Docker)

![Docker](https://img.shields.io/badge/Docker-Engine-blue)
![Python](https://img.shields.io/badge/python-3.12%2B-blue)
![Licencia](https://img.shields.io/badge/License-MIT-yellow)

## Descripción General

Este repositorio proporciona una imagen Docker altamente especializada para procesamiento geoespacial avanzado, big data distribuido y flujos ETL de análisis espacial. El entorno está diseñado para trabajar junto a una base de datos PostGIS oficial, orquestado mediante el archivo `docker-compose.yml` incluido.

### Características

- **Imagen Base**: Ubuntu 24.04
- **Python 3.12**: Incluye un entorno virtual con bibliotecas científicas y geoespaciales:
  ```
  numpy, pandas, geopandas, shapely, fiona, pyproj, rtree, rasterio,
  matplotlib, seaborn, plotly, scipy, scikit-learn, sqlalchemy,
  psycopg2-binary, apache-sedona[spark], pyspark, sshtunnel, paramiko.
  ```
- **Frameworks de Big Data**:
  - Apache Spark 4.0.1 (instalado manualmente con validación SHA512).
  - Apache Sedona 1.8.0 (para análisis espacial distribuido).
- **Herramientas GIS**: GDAL, PROJ, GEOS, SpatialIndex.
- **Soporte Opcional para R**: Incluye paquetes espaciales cuando `INSTALL_CRAN=1`.
- **Usuario no-root**: Usuario preconfigurado con entorno Python aislado.

## Configuración Inicial

### Prerrequisitos

1. **Docker**: Asegúrese de que Docker esté instalado y ejecutándose en su sistema.
2. **Docker Compose**: Requerido para orquestar los servicios.
3. **Variables de Entorno**: Utilice el archivo `.env_example` para configurar credenciales sensibles.

### Configuración del Entorno

1. **Copiar el archivo `.env_example`**:
   ```bash
   cp .env_example .env
   ```
2. **Editar el archivo `.env`**:
   Reemplace los valores de las variables con sus propias credenciales.

3. **Iniciar los Servicios**:
   ```bash
   docker compose up -d
   ```

### Servicios

| Servicio     | Puerto             | Descripción                                | Variables de Entorno                               |
|-------------|--------------------|--------------------------------------------|-----------------------------------------------------|
| `postgis`   | `${POSTGRES_PORT}` | Base de datos PostGIS lista para GIS y ETL | `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` |
| `gis-engine`| —                  | Entorno Spark + Sedona + GDAL + Python     | —                                                   |

## Configuración de Docker Compose

El archivo `docker-compose.yml` orquesta los servicios necesarios para ejecutar GIS Engine. Puede usarlo tanto para construir la imagen localmente como para utilizar la imagen publicada en GitHub Container Registry (GHCR).

### Crear el archivo `docker-compose.yml`

Copie el siguiente contenido en un archivo llamado `docker-compose.yml`:

```yaml
services:
  postgis:
    image: postgis/postgis:16-3.4
    container_name: postgis
    env_file:
      - .env
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - ./postgis:/var/lib/postgresql/data
    ports:
      - "${POSTGRES_PORT}:5432"
    networks:
      - backend_net

  gis-engine:
    image: ghcr.io/chachr81/gis-engine:latest
    container_name: gis-engine
    networks:
      - backend_net

networks:
  backend_net:
```

### Configurar las Variables de Entorno

1. Cree un archivo `.env` basado en el ejemplo proporcionado (`.env_example`).
2. Configure las siguientes variables en el archivo `.env`:
   ```env
   POSTGRES_USER=su_usuario
   POSTGRES_PASSWORD=su_contraseña
   POSTGRES_DB=su_base_de_datos
   POSTGRES_PORT=5432
   ```

### Iniciar los Servicios

Ejecute el siguiente comando para iniciar los servicios:
```bash
docker compose up -d
```

---

## Uso en Windows (Soporte Completo)

Este entorno funciona perfectamente en Windows 10/11 con Docker Desktop. Aquí tienes recomendaciones específicas para usuarios de Windows:

### Pasos para usuarios Windows

1. **Instalar Docker Desktop**:
   - Descarga e instala Docker Desktop desde [docker.com](https://www.docker.com/products/docker-desktop).
   - Durante la instalación, habilita WSL2 si es posible.

2. **¿Qué hacer si WSL2 no está habilitado?**:
   - Asegúrate de que tu sistema operativo sea compatible con WSL2.
   - Si no puedes habilitar WSL2, puedes usar el modo de compatibilidad de Docker Desktop con Hyper-V:
     1. Abre Docker Desktop.
     2. Ve a **Settings > General**.
     3. Desactiva la opción "Use the WSL 2 based engine".
     4. Guarda los cambios y reinicia Docker Desktop.

3. **Clonar este repositorio**:
   ```bash
   git clone https://github.com/chachr81/gis-engine.git
   ```

4. **Crear el archivo `.env` desde el ejemplo**:
   ```bash
   cp .env_example .env
   ```

5. **Ejecutar Docker Compose**:
   ```bash
   docker compose up -d
   ```

6. **Entrar al contenedor GIS Engine**:
   ```bash
   docker exec -it gis-engine bash
   ```

7. **Activar el entorno Python**:
   ```bash
   source ~/.venv/bin/activate
   ```

8. **Instalar Jupyter Notebook (opcional)**:
   ```bash
   pip install notebook ipywidgets
   ```

9. **Ejecutar Jupyter Notebook**:
   ```bash
   jupyter notebook --ip=0.0.0.0 --no-browser
   ```

---

## Conexión a PostGIS desde el contenedor

El contenedor `gis-engine` incluye el cliente PostgreSQL (`psql`). Puedes conectarte a la base de datos PostGIS con el siguiente comando:

```bash
psql -h postgis -U $POSTGRES_USER -d $POSTGRES_DB
```

- **Nota**: El password será el configurado en el archivo `.env`.

### Verificar PostGIS

Una vez dentro de `psql`, ejecuta el siguiente comando para verificar la instalación de PostGIS:

```sql
SELECT PostGIS_Version();
```

---

## Pruebas de Integración

### 1. Probar conexión interna con PostGIS

Desde el contenedor `gis-engine`, verifica la conexión a la base de datos:
```bash
psql -h postgis -U postgres -d postgres
```

### 2. Listar tablas disponibles

Dentro de `psql`, usa el comando:
```sql
\dt
```

### 3. Prueba de lectura de raster/shape con GDAL

Verifica la instalación de GDAL y su versión:
```bash
gdalinfo --version
```

---

## Cómo Colaborar con el Proyecto

¡Gracias por tu interés en colaborar con GIS Engine! Aquí tienes algunas formas de contribuir:

1. **Reportar Problemas**:
   - Si encuentras errores o tienes sugerencias, abre un [issue](https://github.com/chachr81/gis-engine/issues).

2. **Proponer Mejoras**:
   - Realiza un fork del repositorio, crea una nueva rama para tus cambios y envía un pull request.

3. **Documentación**:
   - Ayuda a mejorar la documentación, corrigiendo errores o añadiendo ejemplos útiles.

4. **Pruebas**:
   - Ejecuta pruebas en diferentes entornos y comparte tus resultados.

5. **Difundir el Proyecto**:
   - Comparte este repositorio con otros interesados en procesamiento geoespacial y big data.

### Pasos para Contribuir

1. **Clonar el Repositorio**:
   ```bash
   git clone https://github.com/chachr81/gis-engine.git
   ```

2. **Crear una Nueva Rama**:
   ```bash
   git checkout -b feature/nombre-de-tu-cambio
   ```

3. **Realizar Cambios y Confirmarlos**:
   ```bash
   git add .
   git commit -m "Descripción de tu cambio"
   ```

4. **Enviar un Pull Request**:
   - Sube tus cambios a tu fork y abre un pull request hacia el repositorio principal.

---