import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.nombre,
    required super.email,
    required super.rol,
    required super.telefono,
    required super.fechaRegistro,
    super.vehiculos,
    super.fotoUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      nombre: data['nombre'] as String,
      email: data['email'] as String,
      rol: data['rol'] == 'admin' ? UserRole.admin : UserRole.cliente,
      telefono: data['telefono'] as String,
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      vehiculos: List<String>.from(data['vehiculos'] ?? []),
      fotoUrl: data['fotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'email': email,
        'rol': rol.name,
        'telefono': telefono,
        'fechaRegistro': Timestamp.fromDate(fechaRegistro),
        'vehiculos': vehiculos,
        'fotoUrl': fotoUrl,
      };

  factory UserModel.fromFirebaseUser(
    User user, {
    required String nombre,
    required String telefono,
  }) =>
      UserModel(
        uid: user.uid,
        nombre: nombre,
        email: user.email!,
        rol: UserRole.cliente,
        telefono: telefono,
        fechaRegistro: DateTime.now(),
        vehiculos: const [],
      );
}
