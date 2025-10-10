FROM python:3.10

# Instalar dependencias del sistema necesarias para compilar dlib y opencv
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libopenblas-dev \
        liblapack-dev \
        libx11-dev \
        libgtk2.0-dev \
        libboost-all-dev \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar requirements.txt e instalar dependencias
COPY requirements.txt .
RUN pip install --default-timeout=200 --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . .

EXPOSE 8000

# CMD
CMD ["python", "run.py"]
# Alternativa con gunicorn:
# CMD ["gunicorn", "--bind", "0.0.0.0:8081", "--workers", "4", "--forwarded-allow-ips=*", "wsgi:app"]
