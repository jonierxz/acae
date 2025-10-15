# Imagen base con micromamba
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements.txt.
# (Debe contener SÓLO dependencias que NO sean dlib, opencv, numpy o face-recognition).
COPY requirements.txt .

# --- Etapa 1: Instalación de las dependencias difíciles (Conda) ---
# Instalamos dlib, opencv y numpy desde conda-forge.
# Micromamba/Conda resolverá automáticamente las dependencias de compilación
# (como gcc/g++) necesarias para dlib.
# Se elimina 'python-dev', 'gcc' y 'g++' que estaban causando el error.
RUN micromamba install -y -c conda-forge \
    dlib=19.24.4 \
    opencv \
    numpy \
    python && \
    micromamba clean --all --yes

# --- Etapa 2: Instalación de face-recognition (pip) ---
# face-recognition detectará dlib y numpy ya instalados por Conda y no los reinstalará.
RUN echo "Instalando face-recognition y dependencias restantes..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# --- Etapa 3: Código de la Aplicación y Ejecución ---
# Copiar el resto del código
COPY . .

# Exponer el puerto
EXPOSE 8000

# Comando de inicio
CMD ["micromamba", "run", "-n", "base", "python", "run.py"]