# Configuración real y verificada para Spark 4.0.1 + Sedona 1.8.0

![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Apache Sedona](https://img.shields.io/badge/Apache%20Sedona-FF6600?style=for-the-badge&logo=apache&logoColor=white)

## Contenedor gis-engine (Ubuntu 24.04)

Este documento detalla la configuración del contenedor `gis-engine`, que incluye Apache Spark 4.0.1, Apache Sedona 1.8.0, y un entorno Python 3.12 con bibliotecas GIS y de big data. También se describe cómo validar la instalación y solucionar problemas comunes.

---

## 1. Estructura del contenedor

El contenedor se basa en Ubuntu 24.04 e incluye:

- **Apache Spark 4.0.1**: Instalado en `/opt/spark`.
- **Apache Sedona 1.8.0**: Instalado como paquete Python y configurado con los jars necesarios.
- **Python 3.12**: Instalado en un entorno virtual (`.venv`) en `/home/chris/.venv`.
- **Herramientas GIS**: GDAL, PROJ, GEOS, SpatialIndex.
- **OpenJDK 17**: Requerido para Spark.
- **PostgreSQL Client**: Para conectarse a bases de datos PostGIS.

### Variables de entorno configuradas

Las siguientes variables están definidas en `/etc/profile.d/gis.sh`:

```bash
export LANG=C.UTF-8
export GDAL_DATA=/usr/share/gdal
export PROJ_LIB=/usr/share/proj
export SPARK_HOME=/opt/spark
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export VIRTUAL_ENV=/home/chris/.venv
export PATH=/home/chris/.venv/bin:$PATH
export PYSPARK_PYTHON=/home/chris/.venv/bin/python
export PYSPARK_DRIVER_PYTHON=/home/chris/.venv/bin/python
export PYSPARK_SUBMIT_ARGS='--packages org.apache.sedona:sedona-spark-4.0_2.13:1.8.0,org.datasyslab:geotools-wrapper:1.8.0-33.1 pyspark-shell'
```

---

## 2. Instalación de dependencias

El contenedor incluye las siguientes dependencias:

- **Python GIS Libraries**: `geopandas`, `shapely`, `fiona`, `pyproj`, `rtree`, `rasterio`.
- **Big Data Libraries**: `pyspark`, `apache-sedona[spark]`.
- **Visualización**: `matplotlib`, `seaborn`, `plotly`.
- **Otros**: `sqlalchemy`, `psycopg2-binary`, `sshtunnel`, `paramiko`.

Estas bibliotecas están instaladas en el entorno virtual (`.venv`) y se validan automáticamente al construir el contenedor.

---

## 3. Validación de la configuración

### Script de validación

El contenedor incluye un script de validación ubicado en `/opt/validate_sedona.py`. Este script verifica:

1. La versión de Spark.
2. La disponibilidad de funciones de Sedona como `ST_Point`.
3. Funciones raster específicas de Sedona 1.8.0.

#### Ejecución del script

Para ejecutar el script, usa el siguiente comando dentro del contenedor:

```bash
python /opt/validate_sedona.py
```

#### Salida esperada

```plaintext
Spark version: 4.0.1
ST_Point disponible: True

Validación de funciones Raster en Sedona 1.8.0:

RS_FromGeoTiff      : True
RS_GDALRead         : False
RS_Tile             : True
RS_Resample         : True
RS_Add              : True
RS_Subtract         : True
RS_Multiply         : True
RS_Divide           : True
RS_Normalize        : True
RS_ConvertToFloat   : False
RS_ConvertToInt     : False
RS_ConvertToDouble  : False
RS_SetValue         : True
RS_ToGeoTiff        : False
```
---

## 4. Uso de `pyspark-real`

El contenedor incluye un wrapper llamado `pyspark-real` para garantizar que Sedona y Spark funcionen correctamente con el entorno virtual. Este wrapper:

- Configura las variables necesarias para Sedona.
- Usa el Python del entorno virtual (`.venv`).

### Alias persistente

El alias `pyspark` está configurado para usar `pyspark-real`. Esto asegura que siempre se utilicen las configuraciones correctas.

---

## 5. Troubleshooting

### Problema: `pyspark` se cuelga o no devuelve control a la shell

**Causa**: Bug conocido en Spark 4.0.1 con Python 3.12.

**Solución**: Usa `pyspark-real` en lugar del comando global.

### Problema: `SedonaContext.create()` lanza `TypeError`

**Causa**: Sedona no está en el classpath o la sesión Spark ya existía.

**Solución**: Asegúrate de iniciar notebooks con la configuración persistente de `PYSPARK_SUBMIT_ARGS`.

### Problema: `ST_Point` no aparece en `spark.catalog.functionExists`

**Causa**: Sedona UDT/UDF no se registró.

**Solución**: Implementa `SedonaContext.create(spark)` nuevamente.

---

## 6. Resumen final

- El contenedor `gis-engine` está completamente configurado para Spark 4.0.1 y Sedona 1.8.0.
- Incluye herramientas GIS, un entorno Python aislado, y validaciones automáticas.
- Usa `pyspark-real` para evitar problemas conocidos con Spark y Python 3.12.
- El script de validación confirma que todas las funciones de Sedona están disponibles.

Para más información, consulta el archivo `Dockerfile` o ejecuta el script de validación incluido.
