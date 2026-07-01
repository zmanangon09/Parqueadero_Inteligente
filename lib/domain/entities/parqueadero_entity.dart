class ParqueaderoEntity {
  final String id;
  final String nombre;
  final String direccion;
  final double lat;
  final double lng;
  final int capacidadTotal;
  final int espaciosDisponibles;
  final double tarifaPorHora;
  final String horario;
  final String adminId;

  const ParqueaderoEntity({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.lat,
    required this.lng,
    required this.capacidadTotal,
    required this.espaciosDisponibles,
    required this.tarifaPorHora,
    required this.horario,
    required this.adminId,
  });

  bool get tieneEspacios => espaciosDisponibles > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ParqueaderoEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
