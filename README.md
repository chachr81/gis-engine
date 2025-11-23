# GIS Engine – Entorno Geoespacial Completo (Docker)

🚨 **Nota Importante sobre el Usuario**

Por defecto, el contenedor utiliza el usuario `chris`. Si deseas cambiar el nombre de usuario, edita la línea correspondiente en el `Dockerfile`:

```dockerfile
ARG USERNAME=chris
```

Reemplaza `chris` con el nombre de usuario deseado. Por ejemplo, para usar `usuario`:

```dockerfile
ARG USERNAME=usuario
```

Luego, reconstruye la imagen para aplicar los cambios:

```bash
docker build --no-cache -t gis-engine ./gis-engine
```

⚠️ **Advertencia:** Si no cambias esta línea, el usuario predeterminado será `chris`.

---

Este repositorio contiene una imagen GIS Engine altamente especializada y preparada para procesamiento geoespacial avanzado, big data distribuido y flujos ETL de análisis espacial.
El entorno fue diseñado para trabajar junto a una base de datos PostGIS oficial, utilizando un `docker-compose.yml` ubicado en:

```bash
# Estructura del proyecto
.
├── docker-compose.yml
├── postgis/
└── gis-engine/
```

🚀 **Descripción General**

La imagen `gis-engine` está basada en **Ubuntu 24.04** e integra:

✔️ **Python 3.12 + Entorno .venv**

Incluye librerías científicas y geoespaciales:

```bash
numpy, pandas, geopandas, shapely, fiona,
pyproj, rtree, rasterio,
matplotlib, seaborn, plotly,
scipy, scikit-learn,
sqlalchemy, psycopg2-binary,
apache-sedona[spark], pyspark,
sshtunnel, paramiko.
```

✔️ **Big Data Frameworks**

- **Apache Spark 4.0.1** (instalado manualmente con validación SHA512).
- **Apache Sedona 1.8.0** (para análisis espacial distribuido).

✔️ **GIS Stack nativo**

```bash
GDAL
PROJ
GEOS
SpatialIndex
```

✔️ **Soporte opcional para R (CRAN)**

Con paquetes espaciales principales cuando `INSTALL_CRAN=1`.

✔️ **Usuario no-root preconfigurado**

```bash
Usuario: chris
Modo seguro: sudo sin contraseña
Todo se instala bajo /home/chris
Entorno Python aislado en /home/chris/.venv
```

🐳 **Uso con Docker Compose (Recomendado)**

Tu `docker-compose.yml`, ubicado en `docker_data/`, orquesta dos servicios:

```yaml
services:
  postgis:
    image: postgis/postgis:16-3.4
    container_name: postgis
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
    build:
      context: ./gis-engine
      dockerfile: Dockerfile
    image: gis-engine:latest
    container_name: gis-engine
    volumes:
      - ./gis-engine:/opt/gis
    networks:
      - backend_net

networks:
  backend_net:
```

▶️ **Levantar todo el stack**

Desde `docker_data/`:

```bash
docker compose up -d
```

**Servicios creados:**

| Servicio   | Puerto            | Descripción                                |
|------------|-------------------|--------------------------------------------|
| postgis    | ${POSTGRES_PORT}  | Base de datos PostGIS lista para GIS y ETL |
| gis-engine | —                 | Entorno Spark + Sedona + GDAL + Python     |

💡 **Nota:** Puedes personalizar las variables de entorno en el archivo `.env` para ajustar los puertos y credenciales según tus necesidades.

📦 **Build manual de la imagen (opcional)**

Si necesitas reconstruir `gis-engine`:

```bash
docker build --no-cache -t gis-engine ./gis-engine
```

🐳 **Publicar tu imagen en GitHub Container Registry (GHCR)**

1. **Login**

```bash
echo "<TOKEN>" | docker login ghcr.io -u chachr81 --password-stdin
```

2. **Tag**

```bash
docker tag gis-engine:latest ghcr.io/chachr81/gis-engine:latest
```

3. **Push**

```bash
docker push ghcr.io/chachr81/gis-engine:latest
```

💡 **Uso dentro del contenedor**

Conectarse:

```bash
docker exec -it gis-engine bash
```

Activar entorno:

```bash
source ~/.venv/bin/activate
```

Verificar Spark:

```bash
spark-submit --version
```

Verificar Sedona:

```bash
python3 - << 'EOF'
from sedona.spark import SedonaContext
from pyspark.sql import SparkSession

spark = (SparkSession.builder
         .master("local[*]")
         .appName("test")
         .getOrCreate())

sedona = SedonaContext.create(spark)
print("Sedona OK")
spark.stop()
EOF
```

📁 **Estructura del entorno en el contenedor**

```bash
/opt/spark             → Apache Spark
/opt/spark/conf        → Configuración y log4j
/home/chris/.venv      → Entorno Python
/opt/gis               → Código montado desde host
```

🛠️ **Variables de ambiente esenciales**

| Variable     | Valor                              |
|--------------|------------------------------------|
| SPARK_HOME   | /opt/spark                         |
| SEDONA_HOME  | /opt/sedona                        |
| JAVA_HOME    | /usr/lib/jvm/java-17-openjdk-amd64 |
| GDAL_DATA    | /usr/share/gdal                    |
| PROJ_LIB     | /usr/share/proj                    |
| VIRTUAL_ENV  | /home/chris/.venv                  |

🔒 **Seguridad**

- Usuario no-root por defecto
- Sudo restringido usando `/etc/sudoers.d/chris`
- Contenedor orientado a desarrollo seguro, no producción

📘 **Licencia**

MIT License.

## 🧪 Pruebas Adicionales

Para garantizar que los servicios `gis-engine` y `postgis` están funcionando correctamente, puedes realizar las siguientes pruebas:

### 1. Verificar conectividad entre `gis-engine` y `postgis`

Conéctate al contenedor `gis-engine`:

```bash
docker exec -it gis-engine bash
```

Dentro del contenedor, instala `psql` si no está disponible:

```bash
sudo apt-get update && sudo apt-get install -y postgresql-client
```

Prueba la conexión a la base de datos `postgis`:

```bash
psql -h postgis -U postgres -d postgres
```

Si la conexión es exitosa, deberías ver el prompt de `psql`. Usa el siguiente comando para listar las tablas:

```sql
\dt
```

### 2. Ejecutar una consulta espacial básica

Dentro de `psql`, ejecuta la siguiente consulta para verificar que las extensiones espaciales están activas:

```sql
SELECT PostGIS_Version();
```

Deberías obtener la versión de PostGIS instalada.

### 3. Probar un script de Sedona

Desde el contenedor `gis-engine`, crea un archivo `test_sedona.py` con el siguiente contenido:

```python
from sedona.spark import SedonaContext
from pyspark.sql import SparkSession

spark = (SparkSession.builder
         .master("local[*]")
         .appName("SedonaTest")
         .getOrCreate())

sedona = SedonaContext.create(spark)

print("Sedona está funcionando correctamente.")

spark.stop()
```

Ejecuta el script:

```bash
python3 test_sedona.py
```

Si todo está configurado correctamente, deberías ver el mensaje `Sedona está funcionando correctamente.` en la salida.

## 📜 Normas para Docker Compose

Para trabajar con `docker-compose` de manera eficiente, sigue estas normas:

1. **Mantén las credenciales fuera del archivo `docker-compose.yml`**:
   - Usa un archivo `.env` para almacenar variables sensibles como usuario, contraseña y puertos.
   - Ejemplo de un archivo `.env`:

     ```env
     POSTGRES_USER=postgres
     POSTGRES_PASSWORD=CAMBIAR_ME
     POSTGRES_DB=postgres
     POSTGRES_PORT=55432
     ```

2. **Evita usar imágenes sin tag específico**:
   - Siempre especifica una versión o tag para las imágenes en lugar de usar `latest`.
   - Ejemplo:

     ```yaml
     image: postgis/postgis:16-3.4
     ```

3. **Define redes personalizadas**:
   - Usa redes dedicadas para aislar los servicios y evitar conflictos.
   - Ejemplo:

     ```yaml
     networks:
       backend_net:
     ```

4. **Configura reinicios automáticos**:
   - Usa `restart: unless-stopped` para garantizar que los servicios se reinicien automáticamente en caso de fallo.

5. **Mapea volúmenes para persistencia de datos**:
   - Asegúrate de mapear volúmenes para bases de datos y otros datos importantes.
   - Ejemplo:

     ```yaml
     volumes:
       - ./postgis:/var/lib/postgresql/data
     ```

6. **Verifica los puertos expuestos**:
   - Asegúrate de que los puertos expuestos no entren en conflicto con otros servicios en tu máquina.
   - Ejemplo:

     ```yaml
     ports:
       - "55432:5432"
     ```

7. **Usa `docker-compose.override.yml` para configuraciones locales**:
   - Crea un archivo `docker-compose.override.yml` para configuraciones específicas de desarrollo.

8. **Documenta tus servicios**:
   - Incluye comentarios en el archivo `docker-compose.yml` para explicar cada servicio y configuración.

Estas normas te ayudarán a mantener un entorno limpio, seguro y fácil de gestionar.

## 🌐 Uso del archivo `.env_example`

Para configurar las credenciales y variables de entorno necesarias para `docker-compose`, utiliza el archivo `.env_example` incluido en este repositorio. Sigue estos pasos:

1. **Copia el archivo `.env_example` a `.env`**:

   ```bash
   cp .env_example .env
   ```

2. **Edita el archivo `.env`**:
   - Abre el archivo `.env` en tu editor de texto favorito.
   - Reemplaza los valores de las variables según sea necesario. Por ejemplo:

     ```env
     POSTGRES_USER=postgres
     POSTGRES_PASSWORD=mi_contraseña_segura
     POSTGRES_DB=mi_base_de_datos
     POSTGRES_PORT=55432
     ```

3. **Verifica que el archivo `.env` esté siendo utilizado**:
   - Asegúrate de que el archivo `docker-compose.yml` incluya la línea `env_file: - .env` en la configuración de los servicios.

Este archivo `.env` asegura que las credenciales sensibles no se incluyan directamente en el archivo `docker-compose.yml`, siguiendo las mejores prácticas de seguridad.