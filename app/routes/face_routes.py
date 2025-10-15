import traceback 
import hashlib
import numpy as np 
from sqlalchemy import func, union_all, select, cast, DateTime, Date, Time 
from flask import Blueprint, request, jsonify
from app import db 
from app.models.user import User 
from app.models.login import Login 
from app.models.ingreso import Ingreso     
from app.models.salida import Salida       
from app.utilidad.face_recognition import FaceRecognition 
from flask_login import current_user, login_required
from datetime import datetime
from sqlalchemy import literal
from app.utilidad.extensions import db 
import pytz

# Inicialización de instancias 
face_rec_instance = FaceRecognition() 
face_bp = Blueprint('face', __name__)

def find_user_by_document(document):
    """Busca un usuario por su documento en la tabla User."""
    return User.query.filter_by(documentUser=document).first()

# Función auxiliar para añadir un nuevo usuario
def add_new_user(username, password, document, phone, email, horario, face_encoding):
    # 1. Crear el registro de Login
    login_user = Login(usernameLogin=username)
    login_user.set_password(password) # set_password debe hashear la contraseña
    db.session.add(login_user)
    db.session.flush() # Obtiene el idLogin antes de commit

    # 2. Convertir el encoding de numpy array a bytes para guardar como BLOB
    face_encoding_blob = face_encoding.tobytes()

    # 3. Crear el registro de User (con la contraseña hasheada y face_encoding)
    user_obj = User(
        usernameUser=username,
        passwordUser=hashlib.sha1(password.encode('utf-8')).hexdigest(), 
        documentUser=document,
        phoneUser=phone,
        emailUser=email,
        horario=horario,
        login_id=login_user.idLogin,
        face_encoding=face_encoding_blob # Guardamos el BLOB
    )
    db.session.add(user_obj)
    db.session.commit()
    return True

# Ruta para el registro inicial de rostro (YA EXISTENTE)
@face_bp.route('/register_face', methods=['POST'])
def register_face():
    # [ ... Mantener el código existente para /register_face ... ]
    try:
        if 'image' not in request.files:
            return jsonify({'success': False, 'error': 'No se encontró la imagen en la solicitud.'}), 400
        
        image_file = request.files['image']
        
        empleado_id = request.form.get('document') 
        nombre = request.form.get('username') 
        password = request.form.get('password')
        phoneUser = request.form.get('phone') 
        emailUser = request.form.get('email') 
        horario = request.form.get('horario')

        if not empleado_id or not nombre or not password or not phoneUser or not emailUser or not horario:
            return jsonify({'success': False, 'error': 'Faltan datos de empleado.'}), 400

        if find_user_by_document(empleado_id):
            return jsonify({'success': False, 'error': f'El documento {empleado_id} ya se encuentra registrado.'}), 409

        face_encoding = face_rec_instance.get_face_encoding(image_file)

        if face_encoding is None:
            return jsonify({'success': False, 'error': 'No se detectó un rostro en la imagen capturada.'}), 400
        
        user_added = add_new_user(
            username=nombre, 
            password=password,
            document=empleado_id, 
            phone=phoneUser,
            email=emailUser,
            horario=horario,
            face_encoding=face_encoding
        )

        if user_added:
            return jsonify({'success': True, 'message': f'Usuario {nombre} registrado con éxito con ID de rostro.'})
        else:
            return jsonify({'success': False, 'error': 'Error desconocido al guardar el usuario en la base de datos.'}), 500

    except Exception as e:
        print("="*60)
        print(" TRACEBACK COMPLETO DEL ERROR 500 EN /register_face:")
        traceback.print_exc()
        print("="*60)
        db.session.rollback()
        return jsonify({'success': False, 'error': f'Un error interno ocurrió en el servidor durante el registro: {e}'}), 500
# ------------------------------------------------------------------------------------------


@face_bp.route('/check_attendance', methods=['POST'])
def check_attendance():
    """
    Procesa la imagen, identifica al usuario, y registra el evento de ENTRADA (Ingreso)
    o SALIDA (Salida) basándose en el último registro.
    """
    try:
        if 'image' not in request.files:
            return jsonify({'success': False, 'error': 'No se encontró la imagen de asistencia en la solicitud.'}), 400

        image_file = request.files['image']
        captured_encoding = face_rec_instance.get_face_encoding(image_file)

        if captured_encoding is None:
            return jsonify({'success': False, 'error': 'No se detectó un rostro válido para el registro de asistencia.'}), 400

        # 1. Buscar usuario coincidente
        user_id, username = face_rec_instance.find_matching_user(captured_encoding)

        if not user_id:
            return jsonify({'success': False, 'error': 'Rostro no reconocido. Asegúrese de estar registrado.'}), 401

        user_data = User.query.filter_by(idUser=user_id).first()
        if not user_data:
            return jsonify({'success': False, 'error': 'Error: Datos de usuario no encontrados.'}), 500

        rol = 'User'
        motivo = request.form.get('motivo')  # Si quieres permitir motivo desde el frontend

        colombia_tz = pytz.timezone('America/Bogota')
        now_colombia = datetime.now(colombia_tz)
        current_date = now_colombia.date()
        current_time = now_colombia.time()
        
        # Último ingreso de hoy
        ingreso = Ingreso.query.filter_by(user_id=user_id, fecha=current_date).order_by(Ingreso.idIngreso.desc()).first()

        if not ingreso:
            # No tiene ingreso hoy, registrar ingreso
            nuevo_ingreso = Ingreso(
                user_id=user_id,
                rol=rol,
                fecha=current_date,
                hora=current_time,
                horario=user_data.horario,
                estado='Presente',
                motivo=motivo
            )
            db.session.add(nuevo_ingreso)
            db.session.commit()
            return jsonify({'success': True, 'message': f'¡Entrada registrada con éxito para {username}!', 'event_to_register': 'IN'})
        else:
            # Tiene ingreso hoy, buscar salida asociada
            salida = Salida.query.filter_by(user_id=user_id, ingreso_id=ingreso.idIngreso).first()
            if not salida:
                # No tiene salida, registrar salida
                nueva_salida = Salida(
                    user_id=user_id,
                    rol=rol,
                    ingreso_id=ingreso.idIngreso,
                    fecha=current_date,
                    hora_salida=current_time,
                    horario=ingreso.horario
                )
                db.session.add(nueva_salida)
                db.session.commit()
                return jsonify({'success': True, 'message': f'¡Salida registrada con éxito para {username}!', 'event_to_register': 'OUT'})
            else:
                # Ya tiene salida, solo puede registrar nuevo ingreso si pone motivo
                if not motivo:
                    return jsonify({'success': False, 'error': 'Debe ingresar un motivo para volver a entrar.'}), 400
                nuevo_ingreso = Ingreso(
                    user_id=user_id,
                    rol=rol,
                    fecha=current_date,
                    hora=current_time,
                    horario=user_data.horario,
                    estado='Presente',
                    motivo=motivo
                )
                db.session.add(nuevo_ingreso)
                db.session.commit()
                return jsonify({'success': True, 'message': f'¡Nuevo ingreso registrado con motivo: {motivo} para {username}!', 'event_to_register': 'IN'})

    except Exception as e:
        print("="*60)
        print("TRACEBACK COMPLETO DEL ERROR 500 EN /check_attendance:")
        traceback.print_exc()
        print("="*60)
        db.session.rollback()
        return jsonify({'success': False, 'error': f'Error interno del servidor al registrar asistencia: {e}'}), 500