import numpy as np
from app.models.user import User
import face_recognition

class FaceRecognition:
    """
    Clase base para manejar las operaciones de reconocimiento facial.
    """
    def __init__(self):
        print("INFO: Servicio FaceRecognition inicializado (modo real).")

    def get_face_encoding(self, image_file):
        """
        Obtiene el encoding facial real a partir de una imagen.
        """
        if not image_file:
            return None

        # Leer imagen en bytes y convertir a matriz NumPy
        file_bytes = image_file.read()
        np_img = np.frombuffer(file_bytes, np.uint8)
        import cv2
        img_bgr = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
        if img_bgr is None:
            return None
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        img_final = np.array(np.ascontiguousarray(img_rgb)).copy()

        # Detectar rostros y obtener encoding
        face_locations = face_recognition.face_locations(img_final)
        if not face_locations:
            return None
        encodings = face_recognition.face_encodings(img_final, face_locations)
        if not encodings:
            return None
        # Solo usamos el primer rostro detectado
        return encodings[0]

    def find_matching_user(self, captured_encoding):
        """
        Busca el usuario en la base de datos que coincida con el encoding capturado.
        """
        users = User.query.filter(User.face_encoding.isnot(None)).all()
        for user in users:
            db_encoding = np.frombuffer(user.face_encoding, dtype=np.float64)
            matches = face_recognition.compare_faces([db_encoding], captured_encoding)
            if matches[0]:
                return user.idUser, user.usernameUser
        return None, None