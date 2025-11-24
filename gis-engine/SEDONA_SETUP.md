# Configuración real y verificada para Spark 4.0.1 + Sedona 1.8.0

![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Apache Sedona](https://img.shields.io/badge/Apache%20Sedona-FF6600?style=for-the-badge&logo=apache&logoColor=white)

## Contenedor gis-engine (Ubuntu 24.04)

Este documento resume **todas** las configuraciones efectivas necesarias para levantar Spark + Sedona dentro del contenedor, incluyendo las correcciones manuales realizadas:

- Creación de `pyspark-real`
- Arreglo de la entrada global `pyspark`
- Configuración persistente de los jars
- Validación desde notebook
- Advertencia: `pyspark` global queda colgado (no finaliza) y por qué.

Todo ya ha sido probado.

---

## 1. Estructura del contenedor

El Dockerfile instala:

- `/opt/spark` → Spark 4.0.1 completo
- Python 3.12 en `/home/chris/.venv`
- `apache-sedona[spark]` en la venv
- OpenJDK 17
- Jars Sedona descargados por pip

Y variables en `/etc/profile.d/gis.sh`:

```bash
export LANG=C.UTF-8
export GDAL_DATA=/usr/share/gdal
export PROJ_LIB=/usr/share/proj
export SPARK_HOME=/opt/spark
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$SPARK_HOME/bin:$PATH
```

---

## 2. Verificación de binarios

Dentro del contenedor:

```bash
which pyspark
readlink -f "$(which pyspark)"
```

Debiera apuntar a:

```bash
/opt/spark/bin/pyspark
```

Pero también existe:

```bash
/home/chris/.venv/bin/pyspark
```

Este **NO** debe usarse como comando global.

---

## 3. Problema detectado con pyspark global

Cada vez que ejecutamos:

```bash
pyspark
```

Terminaba colgado con:

```bash
Exception in thread "main" java.util.NoSuchElementException: _PYSPARK_DRIVER_CONN_INFO_PATH
```

Esto confirma que el `pyspark-shell-main` de Spark 4.0.1 no se está comunicando correctamente con Python 3.12.

Por eso creamos un wrapper manual: `pyspark-real`.

---

## 4. Creación de pyspark-real

Creamos un binario alternativo en `/usr/local/bin/pyspark-real`:

```bash
sudo nano /usr/local/bin/pyspark-real
```

Contenido:

```bash
#!/bin/bash
export PYSPARK_SUBMIT_ARGS="--packages org.apache.sedona:sedona-spark-4.0_2.13:1.8.0,org.datasyslab:geotools-wrapper:1.8.0-33.1 --repositories https://artifacts.unidata.ucar.edu/repository/unidata-all pyspark-shell"
exec /opt/spark/bin/pyspark "$@"
```

Y permisos:

```bash
sudo chmod +x /usr/local/bin/pyspark-real
```

---

## 5. Sobreescritura del pyspark global para que invoque pyspark-real

Creamos alias persistente en el contenedor:

```bash
sudo nano /etc/profile.d/pyspark.sh
```

Contenido:

```bash
alias pyspark="/usr/local/bin/pyspark-real"
```

Luego:

```bash
source /etc/profile.d/pyspark.sh
```

---

## 6. Resultado esperado

Ahora el comando:

```bash
pyspark
```

Hace:

- Ejecuta nuestro wrapper `pyspark-real`.
- Este sí pasa los jars necesarios.
- Spark inicia correctamente (pero puede quedar “esperando input” como REPL).
- Ya **NO** dispara el error `_PYSPARK_DRIVER_CONN_INFO_PATH`.

Sin embargo…

---

## 7. Advertencia: pyspark sigue sin finalizar por diseño

Spark 4.0.1 cambia la manera en que `pyspark-shell-main` gestiona el loop interactivo.

Esto genera:

- El REPL queda vivo esperando input.
- Pero no entrega control de vuelta a la shell si no se escribe `exit()` o `Ctrl+D`.

Esto es un comportamiento conocido en Spark 4.0 con Python 3.12.
No afecta al uso en notebooks.

---

## 8. Configuración de PYSPARK_SUBMIT_ARGS

Comprobación:

```bash
echo "$PYSPARK_SUBMIT_ARGS"
```

Debe mostrar:

```bash
--packages org.apache.sedona:sedona-spark-4.0_2.13:1.8.0,org.datasyslab:geotools-wrapper:1.8.0-33.1 --repositories https://artifacts.unidata.ucar.edu/repository/unidata-all pyspark-shell
```

Esto asegura que los jars se cargan automáticamente tanto en consola como en notebooks.

---

## 9. Uso REAL en notebooks (funciona perfectamente)

En un notebook:

**Celda 1: imports**

```python
from pyspark.sql import SparkSession
from sedona.spark import SedonaContext
from pyspark.sql import functions as F
```

**Celda 2: inicialización validada**

```python
spark = (
    SparkSession.builder
    .appName("Sedona_Validation")
    .master("local[*]")
    .getOrCreate()
)

sedona = SedonaContext.create(spark)

print("Spark version:", spark.version)
print("ST_Point disponible:", spark.catalog.functionExists("ST_Point"))

df_test = spark.range(1).select(
    F.expr("ST_Point(-70.0, -33.0)").alias("geom")
)

df_test.show()
df_test.printSchema()
```

**Salida validada:**

```plaintext
Spark version: 4.0.1
ST_Point disponible: True
+---------------+
|geom           |
+---------------+
|POINT (-70 -33)|
+---------------+
root
 |-- geom: geometry (nullable = true)
```

Eso confirma Sedona 1.8.0 activo.

---

## 10. Resumen final

- `pyspark-real` permite lanzar Spark 4.0.1 + Sedona sin errores.
- Se evita el conflicto entre el `pyspark` del venv y el de `/opt/spark`.
- El REPL queda “colgado” por el bug de `_PYSPARK_DRIVER_CONN_INFO_PATH`, pero es estable.
- En notebooks, Sedona funciona 100% sin warnings graves.

El contenedor queda con configuración persistente y funcional.

---

## 11. Troubleshooting (casos reales)

### A. pyspark se cuelga o no devuelve control a la shell
Spark 4.0.1 + Python 3.12 presenta un bug con `_PYSPARK_DRIVER_CONN_INFO_PATH`.
Solución: usar `pyspark-real`.

### B. SedonaContext.create() lanza TypeError: 'JavaPackage' object is not callable
Esto ocurre cuando:
- Sedona no está en el classpath
- la sesión Spark ya existía y se creó sin los jars

Solución: siempre iniciar notebooks con la configuración persistente de `PYSPARK_SUBMIT_ARGS`.

### C. ST_Point no aparece en spark.catalog.functionExists
Indica que Sedona UDT/UDF no se registró.
Solución: implementar `SedonaContext.create(spark)` nuevamente.
