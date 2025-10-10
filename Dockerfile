FROM python:3.10-alpine

# Instalar dependencias del sistema necesarias para compilar dlib, face-recognition, etc.
RUN apk update && apk add --no-cache \
    build-base \
    cmake \
    boost-dev \
    linux-headers \
    libffi-dev \
    openssl-dev \
    python3-dev
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
