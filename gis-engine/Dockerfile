# ---------------------------------------------------------
# BASE: Ubuntu 24.04 — Ubuntu + Python 3.12 + GDAL + OpenJDK17 + Spark + Sedona + R
# WORKDIR final: /home/${USERNAME}
# ---------------------------------------------------------
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG SPARK_VERSION=4.0.1
ARG HADOOP_VERSION=3
ARG SEDONA_VERSION=1.8.0
ARG INSTALL_CRAN=1
ARG USERNAME=chris
ARG USER_UID=1001
ARG USER_GID=1001

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV SPARK_HOME=/opt/spark
ENV SEDONA_HOME=/opt/sedona
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV GDAL_DATA=/usr/share/gdal
ENV PROJ_LIB=/usr/share/proj

# ---------------------------------------------------------
# CREAR USUARIO CHRIS AL INICIO
# ---------------------------------------------------------
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME}:root" | chpasswd

RUN apt-get update && apt-get install -y sudo && \
    usermod -aG sudo ${USERNAME}

# ---------------------------------------------------------
# HABILITAR SUDO SIN CONTRASEÑA PARA CHRIS
# ---------------------------------------------------------
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 440 /etc/sudoers.d/${USERNAME}

# ---------------------------------------------------------
# TODO A PARTIR DE AQUÍ COMO USUARIO CHRIS
# ---------------------------------------------------------
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ---------------------------------------------------------
# Repositorios Python (deadsnakes) y GDAL (ubuntugis)
# ---------------------------------------------------------
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends software-properties-common && \
    sudo add-apt-repository ppa:deadsnakes/ppa -y && \
    sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable -y && \
    sudo apt-get update

# ---------------------------------------------------------
# Consolidar dependencias
# ---------------------------------------------------------
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg git sudo \
    lsb-release dirmngr gnupg2 build-essential pkg-config gettext \
    python3.12 python3.12-dev python3.12-venv python3-pip \
    gdal-bin libgdal-dev libspatialindex-dev proj-bin libproj-dev libgeos-dev \
    libxml2-dev libssl-dev libcurl4-openssl-dev openjdk-17-jdk-headless \
    postgresql-client \
    rsync nano bash-completion \
    libxext6 libxrender1 libxtst6 \
    && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    sudo rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Instalar R + CRAN (opcional)
# ---------------------------------------------------------
RUN if [ "$INSTALL_CRAN" = "1" ]; then \
    sudo apt-get update && sudo apt-get install -y --no-install-recommends \
      dirmngr gnupg apt-transport-https software-properties-common && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
      | sudo gpg --dearmor -o /usr/share/keyrings/cran-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cran-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
      | sudo tee /etc/apt/sources.list.d/cran-r.list && \
    sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
      r-base r-base-dev \
      libcurl4-openssl-dev libxml2-dev libssl-dev \
      gfortran libcairo2-dev libxt-dev libfontconfig1-dev \
      libgdal-dev libproj-dev libgeos-dev && \
    sudo rm -rf /var/lib/apt/lists/*; \
fi

# ---------------------------------------------------------
# SPARK 4.0.1
# ---------------------------------------------------------
ENV SPARK_URL=https://archive.apache.org/dist/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3.tgz
ENV SPARK_HASH=9198602c6b931b46686f32a25793b3bb58b522cd98a5b6a94d2484bae32e3e7b520d60f4bffe72ba29ff5c9ecd862443841ee47dde0f2f9e1bf52539f7baef41

RUN sudo mkdir -p /opt/spark /opt/spark/conf && \
    curl --progress-bar -fsSL "$SPARK_URL" -o spark.tgz && \
    echo "$SPARK_HASH spark.tgz" | sha512sum -c - && \
    sudo tar -xzf spark.tgz -C /opt/ && \
    sudo rsync -a /opt/spark-4.0.1-bin-hadoop3/ /opt/spark/ && \
    sudo rm -rf spark.tgz /opt/spark-4.0.1-bin-hadoop3 && \
    sudo chown -R ${USERNAME}:${USERNAME} /opt/spark

# ---------------------------------------------------------
# log4j
# ---------------------------------------------------------
RUN echo "log4j.rootCategory=WARN, console" | sudo tee /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console=org.apache.log4j.ConsoleAppender" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.target=System.err" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.layout=org.apache.log4j.PatternLayout" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n" | sudo tee -a /opt/spark/conf/log4j.properties

# ---------------------------------------------------------
# Python venv con Spark + Sedona + GIS + Jupyter
# ---------------------------------------------------------
ENV VIRTUAL_ENV=/home/${USERNAME}/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m venv /home/${USERNAME}/.venv && \
    /home/${USERNAME}/.venv/bin/pip install --upgrade pip setuptools wheel && \
    /home/${USERNAME}/.venv/bin/pip install \
      numpy pandas scipy scikit-learn \
      sqlalchemy psycopg2-binary \
      geopandas fiona shapely pyproj rtree \
      rasterio matplotlib seaborn plotly \
      notebook ipywidgets \
      pyspark apache-sedona[spark] \
      sshtunnel paramiko \
      earthengine-api && \
    /home/${USERNAME}/.venv/bin/python -c "from sedona.spark import *; import geopandas, shapely, pyspark; print('Paquetes Python instalados en .venv')"

# Usar SIEMPRE Python del venv para PySpark
ENV PYSPARK_PYTHON=/home/${USERNAME}/.venv/bin/python
ENV PYSPARK_DRIVER_PYTHON=/home/${USERNAME}/.venv/bin/python

# ---------------------------------------------------------
# PYSPARK_SUBMIT_ARGS global — Sedona + Geotools coherentes
# ---------------------------------------------------------
ENV PYSPARK_SUBMIT_ARGS="--packages org.apache.sedona:sedona-spark-4.0_2.13:${SEDONA_VERSION},org.datasyslab:geotools-wrapper:${SEDONA_VERSION}-33.1 pyspark-shell"

# ---------------------------------------------------------
# WRAPPER pyspark-real (CLI usando .venv + Sedona)
# ---------------------------------------------------------
RUN echo '#!/bin/bash' | sudo tee /usr/local/bin/pyspark-real > /dev/null && \
    echo 'export PYSPARK_PYTHON="'$VIRTUAL_ENV'/bin/python"' | sudo tee -a /usr/local/bin/pyspark-real > /dev/null && \
    echo 'export PYSPARK_DRIVER_PYTHON="'$VIRTUAL_ENV'/bin/python"' | sudo tee -a /usr/local/bin/pyspark-real > /dev/null && \
    echo 'export PYSPARK_SUBMIT_ARGS="--packages org.apache.sedona:sedona-spark-4.0_2.13:'${SEDONA_VERSION}',org.datasyslab:geotools-wrapper:'${SEDONA_VERSION}'-33.1 pyspark-shell"' | sudo tee -a /usr/local/bin/pyspark-real > /dev/null && \
    echo 'exec /opt/spark/bin/pyspark "$@"' | sudo tee -a /usr/local/bin/pyspark-real > /dev/null && \
    sudo chmod +x /usr/local/bin/pyspark-real && \
    echo "alias pyspark='/usr/local/bin/pyspark-real'" >> /home/${USERNAME}/.bashrc

# ---------------------------------------------------------
# Kernel Jupyter preconfigurado con PYSPARK_SUBMIT_ARGS
# ---------------------------------------------------------
RUN /home/${USERNAME}/.venv/bin/python -m ipykernel install --user --name gis-engine --display-name "Python 3 (GIS-Engine)" && \
    KDIR=$(/home/${USERNAME}/.venv/bin/jupyter --data-dir)/kernels/gis-engine && \
    sed -i 's|"argv": \[|"env": {"PYSPARK_SUBMIT_ARGS": "--packages org.apache.sedona:sedona-spark-4.0_2.13:'${SEDONA_VERSION}',org.datasyslab:geotools-wrapper:'${SEDONA_VERSION}'-33.1 pyspark-shell"},\n  "argv": \[|g' "$KDIR/kernel.json"

# ---------------------------------------------------------
# Claves GPG R (si aplica)
# ---------------------------------------------------------
RUN if [ "$INSTALL_CRAN" = "1" ]; then \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --list-keys || { echo "Error: clave GPG no válida"; exit 1; }; \
fi

# ---------------------------------------------------------
# Script de entorno
# ---------------------------------------------------------
RUN echo "export LANG=C.UTF-8" | sudo tee /etc/profile.d/gis.sh && \
    echo "export GDAL_DATA=/usr/share/gdal" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PROJ_LIB=/usr/share/proj" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export SPARK_HOME=/opt/spark" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export VIRTUAL_ENV=/home/${USERNAME}/.venv" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PATH=/home/${USERNAME}/.venv/bin:\$PATH" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PYSPARK_PYTHON=/home/${USERNAME}/.venv/bin/python" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PYSPARK_DRIVER_PYTHON=/home/${USERNAME}/.venv/bin/python" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PYSPARK_SUBMIT_ARGS='--packages org.apache.sedona:sedona-spark-4.0_2.13:${SEDONA_VERSION},org.datasyslab:geotools-wrapper:${SEDONA_VERSION}-33.1 pyspark-shell'" | sudo tee -a /etc/profile.d/gis.sh && \
    sudo chmod 644 /etc/profile.d/gis.sh

# ---------------------------------------------------------
# Script de validación de Spark + Sedona
# ---------------------------------------------------------
RUN sudo tee /opt/validate_sedona.py > /dev/null << 'EOF'
from pyspark.sql import SparkSession
from sedona.spark import SedonaContext

# Sesión idéntica a tu script standalone
spark = (
    SparkSession.builder
    .appName("Sedona_Check")
    .master("local[*]")
    .config(
        "spark.jars.packages",
        "org.apache.sedona:sedona-spark-4.0_2.13:1.8.0,"
        "org.datasyslab:geotools-wrapper:1.8.0-33.1"
    )
    .config("spark.jars.repositories", "https://artifacts.unidata.ucar.edu/repository/unidata-all")
    .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
    .config("spark.kryo.registrator", "org.apache.sedona.core.serde.SedonaKryoRegistrator")
    .getOrCreate()
)

sedona = SedonaContext.create(spark)

print("Spark version:", spark.version)
print("ST_Point disponible:", spark.catalog.functionExists("ST_Point"))

raster_funcs = [
    "RS_FromGeoTiff",
    "RS_GDALRead",
    "RS_Tile",
    "RS_Resample",
    "RS_Add",
    "RS_Subtract",
    "RS_Multiply",
    "RS_Divide",
    "RS_Normalize",
    "RS_ConvertToFloat",
    "RS_ConvertToInt",
    "RS_ConvertToDouble",
    "RS_SetValue",
    "RS_ToGeoTiff"
]

print("\nValidación de funciones Raster en Sedona 1.8.0:\n")
for f in raster_funcs:
    print(f"{f:20}: {spark.catalog.functionExists(f)}")

spark.stop()
EOF

RUN echo "Ejecutando validación Sedona..." && \
    /home/${USERNAME}/.venv/bin/python /opt/validate_sedona.py

    # ---------------------------------------------------------
# CMD
# ---------------------------------------------------------
CMD ["tail", "-f", "/dev/null"]

# Limpieza
RUN rm -rf /tmp/pip-cache /tmp/* || true
