
FROM python:3.10-bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema necesarias para dlib, face-recognition y opencv-python.
# Se añaden libboost-python-dev (crucial para compilar dlib) y libgomp1 (para rendimiento de OpenCV).
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
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo y copiar requirements
WORKDIR /install
COPY requirements.txt .

# Instalar dependencias de Python.
RUN pip install --default-timeout=360 --no-cache-dir \
    dlib==19.24.2 \
    face-recognition==1.3.0 \
    face-recognition-models==0.3.0 \
    opencv-python-headless==4.12.0.88 \
    && pip install --default-timeout=360 --no-cache-dir -r requirements.txt

# ----------------------------------------------------------------------
# FASE 2: FINAL - Imagen de Producción (ligera)
# ----------------------------------------------------------------------
FROM python:3.10-slim AS final

# Copiar las librerías compiladas desde la fase 'builder'
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# Instalar las librerías mínimas necesarias en tiempo de ejecución.
# Se añade libgomp1 y la librería de ejecución de boost-python.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsm6 \
    libxext6 \
    libboost-all-dev \
    libboost-python3.10 \
    libglib2.0-0 \
    libssl-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo de la app
WORKDIR /app

# Copiar el código de tu proyecto
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]