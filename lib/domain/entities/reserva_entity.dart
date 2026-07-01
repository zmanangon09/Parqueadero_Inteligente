enum EstadoReserva { pendiente, activa, completada, cancelada }

class ReservaEntity {
  final String id;
  final String usuarioId;
  final String espacioId;
  final String parqueaderoId;
  final String placa;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double montoTotal;
  final EstadoReserva estado;
  final DateTime limiteCheckIn;
  final bool checkInRealizado;
  final String? qrCode;

  const ReservaEntity({
    required this.id,
    required this.usuarioId,
    required this.espacioId,
    required this.parqueaderoId,
    required this.placa,
    required this.fechaInicio,
    required this.fechaFin,
    required this.montoTotal,
    required this.estado,
    required this.limiteCheckIn,
    this.checkInRealizado = false,
    this.qrCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReservaEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
