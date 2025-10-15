# Usa una imagen base con micromamba preinstalado
FROM mambaorg/micromamba:latest

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# (1/6) Copia el archivo de requerimientos (ASEGÚRATE DE QUE NO TIENE numpy, opencv, o dlib)
COPY requirements.txt .

# --- Instalación de dependencias del sistema operativo (APT) ---
# CAMBIA A ROOT: Necesario para que apt-get tenga permisos
USER root

# (2/6) Instalación de build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libgtk2.0-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# VUELVE AL USUARIO MICROMAMBA: Crucial para el resto de la construcción
USER $MAMBA_USER

# (3/6) Configuración del entorno
ENV PATH="/opt/conda/bin:${PATH}"

# (4/6) Instalación de dependencias binarias complejas con Conda (micromamba)
# Conda maneja dlib, numpy, y opencv para evitar problemas de compilación.
RUN echo "Instalando dependencias binarias con micromamba..." && \
    micromamba install -y -c conda-forge \
        dlib=19.24.4 \
        opencv \
        numpy \
        python && \
    micromamba clean --all --yes

# (5/6) Instalación de face-recognition (pip)
# Esto es necesario si 'face-recognition' está fuera de requirements.txt, y la bandera --no-deps es vital.
# Si 'face-recognition' está en requirements.txt, omite este paso y confía en el paso 6.
RUN echo "Instalando face-recognition..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 --no-deps

# (6/6) Instalación de las dependencias restantes (pip)
# Esto instala el resto de tu requirements.txt (Flask, SQLAlchemy, etc.).
RUN echo "Instalando dependencias restantes de requirements.txt..." && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt
    
COPY . /app
# Comando por defecto al iniciar el contenedor
CMD ["python", "run.py"]