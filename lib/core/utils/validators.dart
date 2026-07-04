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

  static String? placa(String? value) {
    if (value == null || value.trim().isEmpty) return 'La placa es requerida.';
    final regex = RegExp(r'^[A-Za-z]{3}-?[0-9]{3,4}$');
    if (!regex.hasMatch(value.trim())) return 'Ingresa una placa válida.';
    return null;
  }

  static String? numeroTarjeta(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de tarjeta es requerido.';
    }
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[0-9]{16}$').hasMatch(digits)) {
      return 'La tarjeta debe tener 16 dígitos.';
    }
    return null;
  }

  static String? expiracionTarjeta(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La expiración es requerida.';
    }
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value.trim());
    if (match == null) return 'Usa el formato MM/YY.';
    final mes = int.parse(match.group(1)!);
    final anio = 2000 + int.parse(match.group(2)!);
    if (mes < 1 || mes > 12) return 'Mes inválido.';
    final ahora = DateTime.now();
    final ultimoDiaMes = DateTime(anio, mes + 1, 0);
    if (ultimoDiaMes.isBefore(DateTime(ahora.year, ahora.month, 1))) {
      return 'La tarjeta está vencida.';
    }
    return null;
  }

  static String? cvc(String? value) {
    if (value == null || value.trim().isEmpty) return 'El CVC es requerido.';
    if (!RegExp(r'^[0-9]{3}$').hasMatch(value.trim())) {
      return 'El CVC debe tener 3 dígitos.';
    }
    return null;
  }
}
