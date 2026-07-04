enum EstadoPago { exitoso, fallido }

class PagoEntity {
  final String id;
  final String reservaId;
  final String usuarioId;
  final double monto;
  final String moneda;
  final String metodo;
  final String ultimos4;
  final EstadoPago estado;
  final String? transactionId;
  final DateTime fecha;

  const PagoEntity({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.monto,
    this.moneda = 'usd',
    this.metodo = 'tarjeta',
    required this.ultimos4,
    required this.estado,
    this.transactionId,
    required this.fecha,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PagoEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
