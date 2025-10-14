FROM python:3.10-slim-bullseye

# 1. Instalar dependencias necesarias para dlib wheels
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Copiar requirements.txt
COPY requirements.txt .

# 3. Instalar dlib y face-recognition-models usando wheels disponibles
RUN pip install --no-cache-dir --only-binary :all: dlib==19.24.4
RUN pip install --no-cache-dir face-recognition-models==0.3.0

# 4. Instalar el resto de dependencias
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiar el código
COPY . .

CMD ["python", "run.py"]
