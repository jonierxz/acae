# Imagen base con conda (miniconda + mamba)
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements si usas pip
COPY requirements.txt .

# Instalar dlib desde conda-forge (precompilado = rápido)
RUN micromamba install -y -c conda-forge dlib=19.24.4 && \
    micromamba clean --all --yes

# Instalar face-recognition y modelos con pip (ya funciona porque dlib está instalado)
RUN pip install --no-cache-dir face-recognition==1.3.0 face-recognition-models==0.3.0

# Instalar opencv headless (sin GUI)
RUN pip install --no-cache-dir opencv-python-headless==4.12.0.88

# Instalar el resto de dependencias de tu proyecto
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . .

# Exponer el puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]
