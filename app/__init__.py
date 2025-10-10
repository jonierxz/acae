from flask import Flask
from app.utilidad.extensions import db
from app.routes.user_routes import registrar_ausencias_global
from flask_migrate import Migrate

# 🚨 IMPORTA EL BLUEPRINT DE CARAS AQUÍ
from .routes.face_routes import face_bp 

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')

    db.init_app(app)
    
    # Activa el comando 'db'
    migrate = Migrate(app, db)

    # Importar Blueprints después de inicializar db
    from .routes.user_routes import user_bp
    
    # Registro de Blueprints
    app.register_blueprint(user_bp)

    # 🚀 SOLUCIÓN AL 404: REGISTRAR EL BLUEPRINT DE CARAS CON EL PREFIJO '/face'
    app.register_blueprint(face_bp, url_prefix='/face')
    
    # 👇 Aquí creas las tablas
    with app.app_context():
        db.create_all()  # Esto crea todas las tablas según tus modelos
        # registrar_ausencias_global() # Esta línea debe seguir COMENTADA si no la estás usando

    # NOTA: Debes retornar solo 'app' si la estructura de tu run.py lo espera, 
    # pero como pusiste el retorno de 'app' solo, lo mantengo así.
    return app 
