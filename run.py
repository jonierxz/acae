from app import create_app, db
import os, hashlib
from app.routes.face_routes import face_bp


# Crear la aplicación
app = create_app()
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

#app.register_blueprint(face_bp)

def crear_tablas_y_usuarios():
    """Crea las tablas y los usuarios por defecto si no existen"""
    from app.models import admin, user, login, ingreso, historial, salida, super
    db.create_all()

    from app.models.user import User
    from app.models.login import Login
    from app.models.admin import Admin
    from app.models.super import Super

    # USUARIO PREDETERMINADO
    if not Login.query.filter_by(usernameLogin='usuario').first():
        login_user = Login(usernameLogin='usuario')
        login_user.set_password('usuario123')
        db.session.add(login_user)
        db.session.commit()

        user_obj = User(
            usernameUser='Usuario',
            passwordUser=hashlib.sha1('usuario123'.encode('utf-8')).hexdigest(),
            documentUser='12345678',
            phoneUser='5555555555',
            emailUser='usuario@demo.com',
            horario='Mañana',
            login_id=login_user.idLogin
        )
        db.session.add(user_obj)
        db.session.commit()

    # ADMIN PREDETERMINADO
    if not Login.query.filter_by(usernameLogin='admin').first():
        login_admin = Login(usernameLogin='admin')
        login_admin.set_password('admin123')
        db.session.add(login_admin)
        db.session.commit()

        admin_obj = Admin(
            usernameAdmin='Admin',
            passwordAdmin=hashlib.sha1('admin123'.encode('utf-8')).hexdigest(),
            documentAdmin='87654321',
            phoneAdmin='5555555556',
            emailAdmin='admin@demo.com',
            horario='Mañana',
            login_id=login_admin.idLogin
        )
        db.session.add(admin_obj)
        db.session.commit()

    # SUPER PREDETERMINADO
    if not Login.query.filter_by(usernameLogin='super').first():
        login_super = Login(usernameLogin='super')
        login_super.set_password('super123')
        db.session.add(login_super)
        db.session.commit()

        super_obj = Super(
            usernameSuper='Super',
            passwordSuper=hashlib.sha1('super123'.encode('utf-8')).hexdigest(),
            documentSuper='11223344',
            phoneSuper='5555555557',
            emailSuper='super@demo.com',
            horario='Mañana',
            login_id=login_super.idLogin
        )
        db.session.add(super_obj)
        db.session.commit()

with app.app_context():
    crear_tablas_y_usuarios()

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
