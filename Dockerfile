# Usa una imagen base con micromamba preinstalado
FROM mambaorg/micromamba:latest

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# (1/7) Copia el archivo de requerimientos
COPY requirements.txt .

# --- Etapa 2: Instalación de dependencias del sistema operativo (APT) ---
# CAMBIA A ROOT: Necesario para que apt-get tenga permisos de escritura
USER root

# (2/7) Instalación de build tools
# Esto es esencialmente para compilar dlib (si se necesitara) y para las dependencias de OpenCV y GTK.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libgtk2.0-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# --- Etapa 3: Vuelve al usuario no-root ---
# VUELVE AL USUARIO MICROMAMBA: Esto es crucial para seguir las mejores prácticas de seguridad
# y para que los comandos de micromamba/pip funcionen correctamente con los permisos del entorno.
USER $MAMBA_USER

# (3/7) Configuración de micromamba (Mantenido del anterior)
ENV PATH="/opt/conda/bin:${PATH}"

# (4/7) Instalación de dependencias binarias complejas con Conda (micromamba)
RUN echo "Instalando dlib, numpy y opencv con micromamba..." && \
    micromamba install -y -c conda-forge \
        dlib=19.24.4 \
        opencv \
        numpy \
        python && \
    micromamba clean --all --yes

# (5/7) Instalación de face-recognition (pip)
RUN echo "Instalando face-recognition..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 --no-deps

# (6/7) Instalación de las dependencias restantes (pip)
RUN echo "Instalando dependencias restantes de requirements.txt..." && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# (7/7) Comando por defecto al iniciar el contenedor
CMD ["/bin/bash"]