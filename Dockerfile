# Usamos miniconda como base (incluye Python)
FROM continuumio/miniconda3:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Crear directorio de trabajo
WORKDIR /app

# Copiar requirements (si usas pip para otras librerías)
COPY requirements.txt .

# ACTUALIZAR CONDA
RUN conda update -n base -c defaults conda -y

# INSTALAR DLIB desde conda-forge (precompilado, rápido)
RUN conda install -y -c conda-forge dlib=19.24.4

# INSTALAR face-recognition (vía pip, funciona perfecto con dlib ya instalado)
RUN pip install --no-cache-dir face-recognition==1.3.0 face-recognition-models==0.3.0

# Instalar OpenCV headless u otras dependencias via pip
RUN pip install --no-cache-dir opencv-python-headless==4.12.0.88

# Instalar el resto de dependencias de tu proyecto
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto de la app
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "run.py"]
