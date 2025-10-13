
FROM python:3.10-bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Instalar DEPENDENCIAS DEL SISTEMA (BUILDER PHASE)
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libboost-all-dev \
    libboost-python-dev \
    libx11-dev \
    libjpeg-dev \
    libpng-dev \
    liblapack-dev \
    libblas-dev \
    pkg-config \
    python3-dev \
    libsm6 \
    libxext6 \
    libgtk2.0-dev \
    libgomp1 \
    libatlas-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo y copiar requirements
WORKDIR /install
COPY requirements.txt .

# 1. Instalar dlib y sus dependencias críticas *SOLAS* en una capa.
RUN pip install --default-timeout=600 --no-cache-dir \
    dlib==19.24.2 \
    face-recognition-models==0.3.0

# 2. Instalar el resto de dependencias de la aplicación.
RUN pip install --default-timeout=360 --no-cache-dir \
    face-recognition==1.3.0 \
    opencv-python-headless==4.12.0.88 \
    && pip install --default-timeout=360 --no-cache-dir -r requirements.txt

# ----------------------------------------------------------------------
# FASE 2: FINAL - Imagen de Producción (ligera)
# *** CÓDIGO CORREGIDO AQUÍ: SOLO LIBRERÍAS DE EJECUCIÓN ***
# ----------------------------------------------------------------------
FROM python:3.10-slim AS final

# Copiar las librerías compiladas desde la fase 'builder'
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# Instalar las librerías mínimas necesarias en tiempo de ejecución.
# Solo dejamos librerías de runtime.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libssl-dev \
    libgomp1 \
    libatlas-base \
    libboost-python3.10 \
    libjpeg62-turbo \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo de la app
WORKDIR /app

# Copiar el código de tu proyecto
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]