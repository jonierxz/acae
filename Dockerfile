# Imagen base con micromamba
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements.txt.
COPY requirements.txt .

# -------------------------------------------------------------
# --- Etapa 1: Instalación de herramientas del sistema (ROOT) ---
USER root
# Añadimos libgtk2.0-dev, pkg-config, build-essential, y cmake para la compilación de OpenCV y dependencias.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libgtk2.0-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Volvemos al usuario por defecto
USER $MAMBA_USER
# -------------------------------------------------------------

# --- Etapa 2: Instalación de las dependencias difíciles (Conda) ---
# **Instalar solo Dlib (19.24.4), OpenCV y NumPy con Conda.**
RUN micromamba install -y -c conda-forge \
    dlib=19.24.4 \
    opencv \
    numpy \
    python && \
    micromamba clean --all --yes

# --- Etapa 3: Instalación de face-recognition (pip) ---
# **Instalar face-recognition y face-recognition-models.**
# Pip detectará el dlib instalado por Conda y lo usará, sin intentar recompilarlo.
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