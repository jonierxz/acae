# Imagen base con conda (miniconda + mamba)
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements antes para aprovechar cache
COPY requirements.txt .

# --- Etapa 1: Preparación del Entorno (dlib) ---
# Instalar dlib desde conda-forge (esto ya trae python y pip)
RUN micromamba install -y -c conda-forge dlib=19.24.4 && \
    micromamba clean --all --yes

# --- Etapa 2: Instalación de dependencias con pip ---
RUN echo "Instalando face-recognition, opencv y requirements.txt..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 \
        opencv-python-headless==4.12.0.88 && \
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# --- Etapa 3: Copiar el código ---
COPY . .

# Exponer el puerto
EXPOSE 8000

# Comando de inicio (usar micromamba run para usar python del entorno)
CMD ["micromamba", "run", "-n", "base", "python", "run.py"]
