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
# HABILITAR SUDO SIN CONTRASEÑA PARA CHRIS (OBLIGATORIO EN DOCKER BUILD)
# ---------------------------------------------------------
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 440 /etc/sudoers.d/${USERNAME}

# ---------------------------------------------------------
# TODO A PARTIR DE AQUÍ SE INSTALA CON EL USUARIO CHRIS
# ---------------------------------------------------------
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ---------------------------------------------------------
# Agregar repositorios deadsnakes (Python) y ubuntugis (GDAL)
# ---------------------------------------------------------
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends software-properties-common && \
    sudo add-apt-repository ppa:deadsnakes/ppa -y && \
    sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable -y && \
    sudo apt-get update

# ---------------------------------------------------------
# Consolidar instalación de dependencias del sistema
# ---------------------------------------------------------
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg git sudo \
    lsb-release dirmngr gnupg2 build-essential pkg-config gettext \
    python3.12 python3.12-dev python3.12-venv python3-pip \
    gdal-bin libgdal-dev libspatialindex-dev proj-bin libproj-dev libgeos-dev \
    libxml2-dev libssl-dev libcurl4-openssl-dev openjdk-17-jdk-headless \
    postgresql-client \
    rsync nano bash-completion && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    sudo rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Instalar R + CRAN + dependencias espaciales (opcional)
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
# Corregir URL y hash de Spark con validación
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
# Configurar log4j.properties
RUN echo "log4j.rootCategory=WARN, console" | sudo tee /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console=org.apache.log4j.ConsoleAppender" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.target=System.err" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.layout=org.apache.log4j.PatternLayout" | sudo tee -a /opt/spark/conf/log4j.properties && \
 echo "log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n" | sudo tee -a /opt/spark/conf/log4j.properties

# ---------------------------------------------------------
# Instalar Python GIS + Spark + Sedona en el entorno virtual (.venv)
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
      pyspark apache-sedona[spark] \
      sshtunnel paramiko \
      earthengine-api && \
    /home/${USERNAME}/.venv/bin/python -c "from sedona.spark import *; import geopandas, shapely, pyspark; print('Paquetes Python instalados en .venv')"

# ---------------------------------------------------------
# VALIDACIÓN DE SPARK Y SEDONA (SE CONSERVA IGUAL)
# ---------------------------------------------------------
## Actualización: Usar configuración explícita de SparkSession y SedonaContext
RUN echo "from sedona.spark import SedonaContext" | sudo tee /opt/validate_spark_sedona.py > /dev/null && \
    echo "from pyspark.sql import SparkSession" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "spark = (" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    SparkSession.builder" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .appName(\"SparkSedonaSession\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .master(\"local[*]\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .config(\"spark.jars.packages\", \"org.apache.sedona:sedona-spark-4.0_2.13:1.8.0,org.datasyslab:geotools-wrapper:1.8.0-33.1\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .config(\"spark.jars.repositories\", \"https://artifacts.unidata.ucar.edu/repository/unidata-all\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .config(\"spark.serializer\", \"org.apache.spark.serializer.KryoSerializer\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .config(\"spark.sql.extensions\", \"org.apache.sedona.sql.SedonaSqlExtensions\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "    .getOrCreate()" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo ")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"Spark iniciado en:\", spark.sparkContext.master)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"Versión de Spark:\", spark.version)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "sedona = SedonaContext.create(spark)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "ext_val = spark.conf.get(\"spark.sql.extensions\", \"\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "fn_ok  = spark.catalog.functionExists(\"st_point\") or spark.catalog.functionExists(\"ST_Point\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "py_ok  = True" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"Sedona package en Spark :\", \"True\")" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"spark.sql.extensions     :\", ext_val)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"Funciones Python (S.*)   :\", py_ok)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"Funciones registradas    :\", fn_ok)" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "print(\"SEDONA_ACTIVO            :\", py_ok and fn_ok and (\"sedona\" in ext_val.lower() or \"SedonaSqlExtensions\" in ext_val))" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null && \
    echo "spark.stop()" | sudo tee -a /opt/validate_spark_sedona.py > /dev/null

RUN echo "Validando Apache Spark y Sedona..." && \
    if [ -x "$SPARK_HOME/bin/spark-submit" ]; then \
        $SPARK_HOME/bin/spark-submit --version; \
    else \
        echo "Error: spark-submit no encontrado en $SPARK_HOME/bin/"; exit 1; \
    fi && \
    python3 /opt/validate_spark_sedona.py

# ---------------------------------------------------------
# Validar claves GPG para R (si se instala)
# ---------------------------------------------------------
RUN if [ "$INSTALL_CRAN" = "1" ]; then \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --list-keys || { echo "Error: clave GPG no válida"; exit 1; }; \
fi

# ---------------------------------------------------------
# Script de entorno (SE CONSERVA IGUAL)
# ---------------------------------------------------------
RUN echo "export LANG=C.UTF-8" | sudo tee /etc/profile.d/gis.sh && \
    echo "export GDAL_DATA=/usr/share/gdal" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export PROJ_LIB=/usr/share/proj" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export SPARK_HOME=/opt/spark" | sudo tee -a /etc/profile.d/gis.sh && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /etc/profile.d/gis.sh && \
    sudo chmod 644 /etc/profile.d/gis.sh

# ---------------------------------------------------------
# CMD por defecto
# ---------------------------------------------------------
CMD ["tail", "-f", "/dev/null"]

# Limpieza (SE CONSERVA)
RUN rm -rf /tmp/pip-cache /tmp/* || true
