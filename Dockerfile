FROM python:3.10-slim

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias para dlib, face-recognition y opencv-python
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libboost-all-dev \
    libx11-dev \
    libjpeg-dev \
    libpng-dev \
    liblapack-dev \
    libatlas-base-dev \
    libgtk2.0-dev \
    pkg-config \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar e instalar dependencias de Python
COPY requirements.txt .
RUN pip install --default-timeout=200 --no-cache-dir -r requirements.txt

# Copiar el resto del proyecto
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]
# Alternativa:
# CMD ["gunicorn", "--bind", "0.0.0.0:8081", "--workers", "4", "--forwarded-allow-ips=*", "wsgi:app"]
