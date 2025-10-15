# Imagen base con micromamba
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements.txt.
COPY requirements.txt .

# --- Etapa 1: Instalación de herramientas del sistema (¡NUEVO!) ---
# Instalamos las herramientas de compilación del sistema (build-essential, cmake)
# Esto es necesario para que 'pip install' compile y vincule correctamente
# face-recognition y dlib, incluso si dlib ya fue pre-instalado por Conda.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake && \
    rm -rf /var/lib/apt/lists/*

# --- Etapa 2: Instalación de las dependencias difíciles (Conda) ---
# Instalamos dlib, opencv y numpy desde conda-forge.
RUN micromamba install -y -c conda-forge \
    dlib=19.24.4 \
    opencv \
    numpy \
    python && \
    micromamba clean --all --yes

# --- Etapa 3: Instalación de face-recognition (pip) ---
# face-recognition detectará dlib, numpy, y opencv ya instalados por Conda y los usará.
RUN echo "Instalando face-recognition y dependencias restantes..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# --- Etapa 4: Código de la Aplicación y Ejecución ---
# Copiar el resto del código
COPY . .

# Exponer el puerto
EXPOSE 8000

# Comando de inicio
CMD ["micromamba", "run", "-n", "base", "python", "run.py"]