enum UserRole { admin, cliente }

class UserEntity {
  final String uid;
  final String nombre;
  final String email;
  final UserRole rol;
  final String telefono;
  final DateTime fechaRegistro;
  final List<String> vehiculos;
  final String? fotoUrl;

  const UserEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.telefono,
    required this.fechaRegistro,
    this.vehiculos = const [],
    this.fotoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
