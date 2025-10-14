# Imagen base con conda (micromamba)
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements.txt.
# IMPORTANTE: NO incluir numpy, opencv o dlib en este archivo.
COPY requirements.txt .

# --- Etapa 1: Preparación del Entorno con Conda ---
# Instalamos dlib y opencv desde conda-forge
RUN micromamba install -y -c conda-forge dlib=19.24.4 opencv && \
    micromamba clean --all --yes

# --- Etapa 2: Instalación de Dependencias con pip ---
# face-recognition depende de dlib, por eso se instala después
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

# Comando de inicio (IMPORTANTE: usar micromamba run para usar python del entorno)
CMD ["micromamba", "run", "-n", "base", "python", "run.py"]

