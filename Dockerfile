# Usa una imagen base con micromamba preinstalado
FROM mambaorg/micromamba:latest

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# (1/7) Copia el archivo de requerimientos para que el proceso de construcción pueda usarlo
# Asegúrate de que este 'requirements.txt' NO contenga la línea de 'dlib'.
COPY requirements.txt .

# (2/7) Instalación de dependencias del sistema operativo (APT)
# Esto es esencialmente para compilar dlib (si se necesitara) y para las dependencias de OpenCV y GTK.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libgtk2.0-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# (3/7) Configuración de micromamba (Opcional, pero buena práctica)
# Crea el entorno base (aunque micromamba a menudo usa un entorno base por defecto)
# La inicialización ya la maneja la imagen base, pero podemos asegurar el PATH
ENV PATH="/opt/conda/bin:${PATH}"

# (4/7) Instalación de dependencias binarias complejas con Conda (micromamba)
# Conda-forge proporciona binarios precompilados de dlib, numpy y opencv,
# lo cual es crucial para evitar errores de compilación de pip.
RUN echo "Instalando dlib, numpy y opencv con micromamba..." && \
    micromamba install -y -c conda-forge \
        dlib=19.24.4 \
        opencv \
        numpy \
        python && \
    micromamba clean --all --yes

# (5/7) Instalación de face-recognition (pip)
# Usamos --no-deps para asegurar que pip NO intente descargar y compilar dlib,
# obligándolo a usar la versión instalada por Conda en el paso anterior.
RUN echo "Instalando face-recognition..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 --no-deps

# (6/7) Instalación de las dependencias restantes (pip)
# Esto instala el resto de paquetes de tu requirements.txt.
RUN echo "Instalando dependencias restantes de requirements.txt..." && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# (7/7) Comando por defecto al iniciar el contenedor (Ejemplo)
CMD ["/bin/bash"] 

# Si tienes un archivo principal (ej. app.py), cópialo aquí y ajusta el CMD/ENTRYPOINT
# COPY app.py .
# CMD ["python", "app.py"]