# Imagen base con micromamba
FROM mambaorg/micromamba:latest

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Directorio de trabajo
WORKDIR /app

# Copiar requirements.txt.
# Asegúrate de que este archivo SÓLO contenga las dependencias de tu aplicación
# que NO son dlib, face-recognition, opencv o numpy.
COPY requirements.txt .

# --- Etapa 1: Preparación del Entorno con Conda ---
# Instalamos dlib, opencv y numpy desde conda-forge.
# dlib es la más difícil de construir, por lo que la instalamos con conda-forge.
# numpy y opencv también se instalan con conda-forge para evitar conflictos.
# Usamos una versión específica de dlib como solicitaste.
RUN micromamba install -y -c conda-forge \
    dlib=19.24.4 \
    opencv \
    numpy \
    python-dev \
    gcc \
    g++ && \
    micromamba clean --all --yes

# --- Etapa 2: Instalación de Dependencias con pip ---
# face-recognition y face-recognition-models se instalan con pip.
# La clave es usar --no-deps para face-recognition si ya instalaste dlib con Conda,
# o dejar que pip lo instale, pero Conda ya debería haber satisfecho la dependencia
# si está en el mismo entorno.
# La versión 1.3.0 de face-recognition debería usar la versión de dlib ya instalada.
RUN echo "Instalando face-recognition y dependencias restantes con pip..." && \
    micromamba run -n base pip install --no-cache-dir \
        face-recognition==1.3.0 \
        face-recognition-models==0.3.0 && \
    # Instalamos las dependencias restantes (sin las de Conda)
    micromamba run -n base pip install --no-cache-dir -r requirements.txt

# --- Etapa 3: Código de la Aplicación y Ejecución ---
# Copiar el resto del código
COPY . .

# Exponer el puerto
EXPOSE 8000

# Comando de inicio (IMPORTANTE: usar micromamba run para usar python del entorno)
CMD ["micromamba", "run", "-n", "base", "python", "run.py"]