class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido.';
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value)) return 'Ingresa un correo válido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida.';
    if (value.length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es requerido.';
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(value)) return 'Ingresa un teléfono válido.';
    return null;
  }
}
