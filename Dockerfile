FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema necesarias para compilar y ejecutar dlib / face-recognition
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libboost-all-dev \
    libx11-dev \
    libjpeg-dev \
    libpng-dev \
    liblapack-dev \
    libblas-dev \
    libatlas-base-dev \
    pkg-config \
    python3-dev \
    libsm6 \
    libxext6 \
    libgtk2.0-dev \
    libgomp1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar archivo de dependencias
COPY requirements.txt .

# Instalar dlib y face-recognition-models primero (evita errores)
RUN pip install --no-cache-dir --default-timeout=600 \
    dlib==19.24.4 \
    face-recognition-models==0.3.0

# Instalar face-recognition y las demás dependencias
RUN pip install --no-cache-dir --default-timeout=600 \
    face-recognition==1.3.0 \
    && pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY . .

# Exponer puerto si tu app lo usa
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]